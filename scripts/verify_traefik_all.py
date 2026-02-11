#!/usr/bin/env python3
"""
Verify all Traefik backend services are accessible
Tests each service URL from Traefik configuration
"""

import re
import subprocess
import sys
from collections import defaultdict

# Colors
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    BOLD = '\033[1m'
    NC = '\033[0m'

def test_url(url, timeout=5):
    """Test if a URL is accessible"""
    try:
        result = subprocess.run(
            ['curl', '-s', '-o', '/dev/null', '-w', '%{http_code}',
             '--max-time', str(timeout), url],
            capture_output=True,
            text=True,
            timeout=timeout + 1
        )
        return result.stdout.strip()
    except:
        return "000"

def is_success(http_code):
    """Check if HTTP code indicates success"""
    code = int(http_code) if http_code.isdigit() else 0
    # 200-299 (success), 300-399 (redirect), 401/403 (auth - service is up)
    return code in range(200, 400) or code in [401, 403]

def parse_traefik_config():
    """Download and parse Traefik config"""
    print(f"{Colors.BLUE}[INFO]{Colors.NC} Downloading Traefik configuration from 192.168.0.2...")

    result = subprocess.run(
        ['ssh', '-o', 'StrictHostKeyChecking=no', 'root@192.168.0.2',
         'cat /etc/traefik/conf.d/primary-host.yml'],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        print(f"{Colors.RED}[ERROR]{Colors.NC} Failed to download config")
        sys.exit(1)

    return result.stdout

def extract_services(config):
    """Extract service URLs from config"""
    services = {}
    current_service = None
    in_services = False

    for line in config.split('\n'):
        # Detect services section
        if line.strip() == 'services:':
            in_services = True
            continue

        if in_services:
            # Service name (indented with 4 spaces)
            service_match = re.match(r'^    (\w+):', line)
            if service_match:
                current_service = service_match.group(1)
                continue

            # URL line
            url_match = re.search(r'url:\s*["\']?(http://[^"\']+)["\']?', line)
            if url_match and current_service:
                services[current_service] = url_match.group(1)
                current_service = None

    return services

def main():
    print(f"\n{Colors.BOLD}{'='*70}{Colors.NC}")
    print(f"{Colors.BOLD}Traefik Backend Service Verification{Colors.NC}")
    print(f"{Colors.BOLD}{'='*70}{Colors.NC}\n")

    # Parse config
    config = parse_traefik_config()
    services = extract_services(config)

    if not services:
        print(f"{Colors.RED}[ERROR]{Colors.NC} No services found in config")
        sys.exit(1)

    print(f"{Colors.GREEN}[OK]{Colors.NC} Found {len(services)} services\n")
    print(f"{Colors.BOLD}Testing all backend services...{Colors.NC}\n")

    # Test each service
    working = []
    failed = []

    for service_name, url in sorted(services.items()):
        http_code = test_url(url)

        if is_success(http_code):
            status = f"{Colors.GREEN}✓{Colors.NC}"
            working.append((service_name, url, http_code))
            print(f"{status} {service_name:20s} {url:40s} [{http_code}]")
        else:
            status = f"{Colors.RED}✗{Colors.NC}"
            failed.append((service_name, url, http_code))
            print(f"{status} {service_name:20s} {url:40s} [{http_code}]")

    # Summary
    print(f"\n{Colors.BOLD}{'='*70}{Colors.NC}")
    print(f"{Colors.BOLD}SUMMARY{Colors.NC}")
    print(f"{Colors.BOLD}{'='*70}{Colors.NC}")
    print(f"Total services: {len(services)}")
    print(f"{Colors.GREEN}Working: {len(working)}{Colors.NC}")
    print(f"{Colors.RED}Failed: {len(failed)}{Colors.NC}")
    print()

    if failed:
        print(f"{Colors.YELLOW}{Colors.BOLD}Services with issues:{Colors.NC}\n")
        for service_name, url, http_code in failed:
            print(f"  • {service_name}: {url} (code: {http_code})")
        print()
        print(f"{Colors.YELLOW}These services need attention!{Colors.NC}")
        sys.exit(1)
    else:
        print(f"{Colors.GREEN}{Colors.BOLD}✓ All services are accessible!{Colors.NC}")
        sys.exit(0)

if __name__ == "__main__":
    main()
