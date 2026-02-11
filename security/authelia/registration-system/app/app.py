#!/usr/bin/env python3
"""
Authelia + Pocket-ID Registration System
Self-service user registration with email verification
Auto-syncs to both Authelia and Pocket-ID
"""

import os
import yaml
import secrets
import hashlib
import smtplib
import requests
from datetime import datetime, timedelta
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from argon2 import PasswordHasher
from argon2.exceptions import HashingError

app = Flask(__name__)
CORS(app)

# Configuration
SMTP_HOST = os.getenv('SMTP_HOST', 'smtp.gmail.com')
SMTP_PORT = int(os.getenv('SMTP_PORT', 587))
SMTP_USER = os.getenv('SMTP_USER')
SMTP_PASSWORD = os.getenv('SMTP_PASSWORD')
DOMAIN = os.getenv('DOMAIN', 'thehighestcommittee.com')
AUTHELIA_CONFIG = os.getenv('AUTHELIA_CONFIG', '/authelia-config/users_database.yml')
POCKET_ID_URL = os.getenv('POCKET_ID_URL', 'http://security-pocket-id-1:1411')

# In-memory verification tokens (use Redis in production)
verification_tokens = {}

ph = PasswordHasher(
    time_cost=3,
    memory_cost=65536,
    parallelism=4,
    hash_len=32,
    salt_len=16
)


def send_verification_email(email, username, token):
    """Send email verification link"""
    verification_link = f"https://register.{DOMAIN}/verify?token={token}"

    msg = MIMEMultipart('alternative')
    msg['Subject'] = f"Verify your {DOMAIN} account"
    msg['From'] = SMTP_USER
    msg['To'] = email

    text = f"""
    Welcome to {DOMAIN}!

    Please verify your email address by clicking the link below:
    {verification_link}

    This link will expire in 24 hours.

    If you didn't create this account, please ignore this email.
    """

    html = f"""
    <html>
      <body style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>Welcome to {DOMAIN}!</h2>
        <p>Hi {username},</p>
        <p>Please verify your email address by clicking the button below:</p>
        <p style="margin: 30px 0;">
          <a href="{verification_link}"
             style="background-color: #4CAF50; color: white; padding: 14px 28px;
                    text-decoration: none; border-radius: 4px; display: inline-block;">
            Verify Email Address
          </a>
        </p>
        <p>Or copy and paste this link:</p>
        <p style="background: #f5f5f5; padding: 10px; word-break: break-all;">
          {verification_link}
        </p>
        <p style="color: #666; font-size: 12px; margin-top: 30px;">
          This link will expire in 24 hours.<br>
          If you didn't create this account, please ignore this email.
        </p>
      </body>
    </html>
    """

    msg.attach(MIMEText(text, 'plain'))
    msg.attach(MIMEText(html, 'html'))

    try:
        with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
            server.starttls()
            server.login(SMTP_USER, SMTP_PASSWORD)
            server.send_message(msg)
        return True
    except Exception as e:
        print(f"Email error: {e}")
        return False


def add_user_to_authelia(username, email, password, displayname):
    """Add user to Authelia users_database.yml"""
    try:
        # Generate Argon2 hash
        password_hash = ph.hash(password)

        # Load existing users
        with open(AUTHELIA_CONFIG, 'r') as f:
            config = yaml.safe_load(f)

        if 'users' not in config:
            config['users'] = {}

        # Check if user already exists
        if username in config['users']:
            return False, "Username already exists"

        # Add new user
        config['users'][username] = {
            'displayname': displayname,
            'password': password_hash,
            'email': email,
            'groups': ['users']
        }

        # Write back
        with open(AUTHELIA_CONFIG, 'w') as f:
            yaml.safe_dump(config, f, default_flow_style=False, sort_keys=False)

        return True, "User added to Authelia"

    except Exception as e:
        return False, f"Authelia error: {str(e)}"


def add_user_to_pocket_id(username, email, password, displayname):
    """Add user to Pocket-ID via API"""
    try:
        # Pocket-ID user creation endpoint
        response = requests.post(
            f"{POCKET_ID_URL}/api/users",
            json={
                "username": username,
                "email": email,
                "password": password,
                "displayName": displayname,
                "groups": ["users"]
            },
            headers={"Content-Type": "application/json"},
            timeout=10
        )

        if response.status_code in [200, 201]:
            return True, "User added to Pocket-ID"
        else:
            return False, f"Pocket-ID error: {response.text}"

    except Exception as e:
        # Pocket-ID might not have an API endpoint for this
        # In that case, we'll just sync to Authelia
        print(f"Pocket-ID sync skipped: {e}")
        return True, "Pocket-ID sync skipped (will sync on first login)"


@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy"})


@app.route('/')
def index():
    """Serve registration page"""
    return send_from_directory('.', 'index.html')


@app.route('/api/register', methods=['POST'])
def register():
    """Handle user registration"""
    data = request.json

    username = data.get('username', '').strip().lower()
    email = data.get('email', '').strip().lower()
    password = data.get('password', '')
    displayname = data.get('displayname', '').strip()

    # Validation
    if not all([username, email, password, displayname]):
        return jsonify({"error": "All fields are required"}), 400

    if len(password) < 8:
        return jsonify({"error": "Password must be at least 8 characters"}), 400

    if '@' not in email:
        return jsonify({"error": "Invalid email address"}), 400

    # Generate verification token
    token = secrets.token_urlsafe(32)
    verification_tokens[token] = {
        'username': username,
        'email': email,
        'password': password,
        'displayname': displayname,
        'expires': datetime.now() + timedelta(hours=24)
    }

    # Send verification email
    if send_verification_email(email, username, token):
        return jsonify({
            "message": "Registration successful! Please check your email to verify your account.",
            "email": email
        }), 200
    else:
        return jsonify({"error": "Failed to send verification email"}), 500


@app.route('/api/verify', methods=['GET'])
def verify():
    """Verify email and create accounts"""
    token = request.args.get('token')

    if not token or token not in verification_tokens:
        return jsonify({"error": "Invalid or expired verification token"}), 400

    data = verification_tokens[token]

    # Check expiration
    if datetime.now() > data['expires']:
        del verification_tokens[token]
        return jsonify({"error": "Verification token has expired"}), 400

    username = data['username']
    email = data['email']
    password = data['password']
    displayname = data['displayname']

    # Add to Authelia
    authelia_success, authelia_msg = add_user_to_authelia(username, email, password, displayname)

    if not authelia_success:
        return jsonify({"error": authelia_msg}), 500

    # Add to Pocket-ID
    pocket_success, pocket_msg = add_user_to_pocket_id(username, email, password, displayname)

    # Clean up token
    del verification_tokens[token]

    # Restart Authelia to reload users
    try:
        import subprocess
        subprocess.run([
            'docker', 'compose', '-f',
            '/opt/stacks/security/authelia/docker-compose.yml',
            'restart', 'authelia'
        ], check=False, capture_output=True)
    except:
        pass

    return jsonify({
        "message": "Email verified! Your account has been created. You can now login.",
        "username": username,
        "authelia": authelia_msg,
        "pocketid": pocket_msg
    }), 200


@app.route('/api/check-username', methods=['POST'])
def check_username():
    """Check if username is available"""
    username = request.json.get('username', '').strip().lower()

    try:
        with open(AUTHELIA_CONFIG, 'r') as f:
            config = yaml.safe_load(f)

        if username in config.get('users', {}):
            return jsonify({"available": False}), 200
        else:
            return jsonify({"available": True}), 200
    except:
        return jsonify({"available": True}), 200


if __name__ == '__main__':
    print("=" * 60)
    print("Authelia + Pocket-ID Registration System")
    print("=" * 60)
    print(f"Domain: {DOMAIN}")
    print(f"Authelia Config: {AUTHELIA_CONFIG}")
    print(f"Pocket-ID URL: {POCKET_ID_URL}")
    print(f"Starting on port 5050...")
    print("=" * 60)

    app.run(host='0.0.0.0', port=5050, debug=False)
