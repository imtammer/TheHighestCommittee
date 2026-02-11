#!/usr/bin/env python3
"""
npm_traefik_sync.py
Advanced synchronization between NPM Plus and Traefik configurations
with automatic mismatch detection and reporting.
"""

import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import subprocess

# Colors for terminal output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    BOLD = '\033[1m'
    NC = '\033[0m'

class Service:
    """Represents a hosted service"""
    def __init__(self, name: str, ip: str, port: int, domain: Optional[str] = None):
        self.name = name
        self.ip = ip
        self.port = port
        self.domain = domain
        self.url = f"http://{ip}:{port}"

    def __repr__(self):
        return f"Service({self.name}, {self.ip}:{self.port}, {self.domain})"

    def __eq__(self, other):
        if not isinstance(other, Service):
            return False
        return self.ip == other.ip and self.port == other.port

class ProxyHost:
    """Represents an NPM proxy host"""
    def __init__(self, domain: str, target_ip: str, target_port: int, host_label: str):
        self.domain = domain
        self.target_ip = target_ip
        self.target_port = target_port
        self.host_label = host_label

    def __repr__(self):
        return f"ProxyHost({self.domain} -> {self.target_ip}:{self.target_port})"

class TraefikRoute:
    """Represents a Traefik route"""
    def __init__(self, router_name: str, domain: str, service_name: str, service_url: str):
        self.router_name = router_name
        self.domain = domain
        self.service_name = service_name
        self.service_url = service_url

        # Parse IP and port from URL
        clean_url = service_url.replace("http://", "").replace("https://", "")
        parts = clean_url.split(":")
        self.ip = parts[0]
        self.port = int(parts[1].split("/")[0]) if len(parts) > 1 else 80

    def __repr__(self):
        return f"TraefikRoute({self.domain} -> {self.ip}:{self.port})"

class CrossReferenceValidator:
    """Main validator class"""

    def __init__(self, hosted_apps_path: str):
        self.hosted_apps_path = Path(hosted_apps_path)
        self.services: Dict[str, Service] = {}
        self.npm_hosts: List[ProxyHost] = []
        self.traefik_routes: List[TraefikRoute] = []

    def parse_hosted_apps(self) -> None:
        """Parse HOSTED_APPS.md for services"""
        print(f"{Colors.BLUE}[INFO]{Colors.NC} Parsing {self.hosted_apps_path}...")

        content = self.hosted_apps_path.read_text()

        # More flexible regex - matches service table entries
        # Format: | emoji | **Service** | [port](http://ip:port) | [domain](url) or — | ...
        # Match any emoji/unicode character including variation selectors
        service_pattern = r'\|\s*[\U0001F000-\U0001FAFF\u2600-\u27BF\u2B50\uFE0F]+\s*\|\s*\*\*([^*]+)\*\*\s*\|\s*\[(\d+)\]\(http://([0-9.]+):(\d+)\)'

        for match in re.finditer(service_pattern, content):
            name = match.group(1).strip()
            port = int(match.group(2))
            ip = match.group(3)

            # Try to find external domain in the same line
            line_start = match.start()
            line_end = content.find('\n', line_start)
            if line_end == -1:
                line_end = len(content)
            line = content[line_start:line_end]

            domain_match = re.search(r'\[([a-z0-9.-]+\.thehighestcommittee\.com)\]', line)
            domain = domain_match.group(1) if domain_match else None

            service = Service(name, ip, port, domain)
            # Use full name as key to avoid collisions
            key = f"{name.lower()}_{ip}_{port}"
            self.services[key] = service

        print(f"{Colors.GREEN}[OK]{Colors.NC} Found {len(self.services)} services")

    def parse_npm_hosts(self) -> None:
        """Parse NPM proxy hosts from HOSTED_APPS.md"""
        print(f"{Colors.BLUE}[INFO]{Colors.NC} Parsing NPM proxy hosts...")

        content = self.hosted_apps_path.read_text()

        # Find NPM section
        npm_section = re.search(
            r'## 🌐 NPM Plus Proxy Hosts.*?^---',
            content,
            re.MULTILINE | re.DOTALL
        )

        if not npm_section:
            print(f"{Colors.YELLOW}[WARN]{Colors.NC} NPM section not found")
            return

        # Parse proxy host entries
        host_pattern = r'\|\s*([a-z0-9.-]+\.thehighestcommittee\.com)\s*\|\s*([0-9.]+):(\d+)\s*\|\s*([^|]+)\s*\|'

        for match in re.finditer(host_pattern, npm_section.group(0)):
            domain = match.group(1)
            ip = match.group(2)
            port = int(match.group(3))
            host_label = match.group(4).strip()

            proxy = ProxyHost(domain, ip, port, host_label)
            self.npm_hosts.append(proxy)

        print(f"{Colors.GREEN}[OK]{Colors.NC} Found {len(self.npm_hosts)} NPM proxy hosts")

    def query_traefik_config(self, traefik_host: str = "192.168.0.2") -> None:
        """Query Traefik configuration via SSH"""
        print(f"{Colors.BLUE}[INFO]{Colors.NC} Querying Traefik on {traefik_host}...")

        try:
            # SSH command to get Traefik config
            cmd = [
                "ssh", "-o", "StrictHostKeyChecking=no",
                f"root@{traefik_host}",
                "find /etc/traefik/dynamic -type f \\( -name '*.yml' -o -name '*.yaml' \\) -exec cat {} \\;"
            ]

            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)

            if result.returncode != 0:
                print(f"{Colors.RED}[ERROR]{Colors.NC} Failed to query Traefik")
                return

            # Parse YAML (basic parsing without PyYAML dependency)
            self._parse_traefik_yaml(result.stdout)

        except Exception as e:
            print(f"{Colors.RED}[ERROR]{Colors.NC} Traefik query failed: {e}")

    def _parse_traefik_yaml(self, yaml_content: str) -> None:
        """Basic YAML parsing for Traefik config"""
        # This is a simplified parser - for production use PyYAML
        routers = {}
        services = {}

        current_section = None
        current_item = None

        for line in yaml_content.split('\n'):
            line = line.rstrip()

            # Detect routers section
            if 'routers:' in line:
                current_section = 'routers'
                continue
            # Detect services section
            elif 'services:' in line:
                current_section = 'services'
                continue

            # Parse router entries
            if current_section == 'routers':
                if re.match(r'^\s{4}\w+:', line):
                    current_item = line.strip().rstrip(':')
                    routers[current_item] = {}
                elif current_item and 'rule:' in line.lower():
                    match = re.search(r'Host\(`([^`]+)`\)', line)
                    if match:
                        routers[current_item]['domain'] = match.group(1)
                elif current_item and 'service:' in line.lower():
                    match = re.search(r'service:\s*(\S+)', line)
                    if match:
                        routers[current_item]['service'] = match.group(1)

            # Parse service entries
            elif current_section == 'services':
                if re.match(r'^\s{4}\w+:', line):
                    current_item = line.strip().rstrip(':')
                    services[current_item] = []
                elif current_item and 'url:' in line.lower():
                    match = re.search(r'url:\s*["\']?([^"\']+)["\']?', line)
                    if match:
                        services[current_item].append(match.group(1))

        # Build TraefikRoute objects
        for router_name, router_config in routers.items():
            domain = router_config.get('domain')
            service_name = router_config.get('service')

            if domain and service_name and service_name in services:
                service_urls = services[service_name]
                if service_urls:
                    route = TraefikRoute(router_name, domain, service_name, service_urls[0])
                    self.traefik_routes.append(route)

        print(f"{Colors.GREEN}[OK]{Colors.NC} Found {len(self.traefik_routes)} Traefik routes")

    def validate_npm_hosts(self) -> Tuple[int, int]:
        """Validate NPM hosts against services"""
        print(f"\n{Colors.BOLD}=== NPM Proxy Host Validation ==={Colors.NC}\n")

        matches = 0
        mismatches = 0

        for proxy in self.npm_hosts:
            # Find matching service by IP:port (search through all services)
            matching_services = [s for s in self.services.values()
                               if s.ip == proxy.target_ip and s.port == proxy.target_port]

            if matching_services:
                matching_service = matching_services[0]
                # Check domain match
                if matching_service.domain == proxy.domain or matching_service.domain is None:
                    print(f"{Colors.GREEN}✓{Colors.NC} {proxy.domain} -> {proxy.target_ip}:{proxy.target_port} ({matching_service.name})")
                    matches += 1
                else:
                    print(f"{Colors.YELLOW}⚠{Colors.NC} {proxy.domain} -> {proxy.target_ip}:{proxy.target_port} ({matching_service.name})")
                    print(f"  Domain mismatch! Expected: {matching_service.domain}")
                    mismatches += 1
            else:
                print(f"{Colors.RED}✗{Colors.NC} {proxy.domain} -> {proxy.target_ip}:{proxy.target_port}")
                print(f"  No matching service found in HOSTED_APPS.md!")
                mismatches += 1

        print(f"\n{Colors.BLUE}[INFO]{Colors.NC} NPM Validation: {matches} matches, {mismatches} issues\n")
        return matches, mismatches

    def validate_traefik_routes(self) -> Tuple[int, int]:
        """Validate Traefik routes against services"""
        print(f"\n{Colors.BOLD}=== Traefik Route Validation ==={Colors.NC}\n")

        matches = 0
        mismatches = 0

        for route in self.traefik_routes:
            # Find matching service by IP:port (search through all services)
            matching_services = [s for s in self.services.values()
                               if s.ip == route.ip and s.port == route.port]

            if matching_services:
                matching_service = matching_services[0]
                # Check domain match
                if matching_service.domain == route.domain or matching_service.domain is None:
                    print(f"{Colors.GREEN}✓{Colors.NC} {route.domain} -> {route.ip}:{route.port} ({matching_service.name})")
                    matches += 1
                else:
                    print(f"{Colors.YELLOW}⚠{Colors.NC} {route.domain} -> {route.ip}:{route.port} ({matching_service.name})")
                    print(f"  Domain mismatch! Expected: {matching_service.domain}")
                    mismatches += 1
            else:
                print(f"{Colors.YELLOW}⚠{Colors.NC} {route.domain} -> {route.ip}:{route.port}")
                print(f"  Service not found in HOSTED_APPS.md (may be valid)")
                mismatches += 1

        print(f"\n{Colors.BLUE}[INFO]{Colors.NC} Traefik Validation: {matches} matches, {mismatches} issues\n")
        return matches, mismatches

    def generate_report(self, npm_results: Tuple[int, int], traefik_results: Tuple[int, int]) -> None:
        """Generate summary report"""
        npm_matches, npm_issues = npm_results
        traefik_matches, traefik_issues = traefik_results

        print(f"\n{Colors.BOLD}{'='*50}{Colors.NC}")
        print(f"{Colors.BOLD}SUMMARY{Colors.NC}")
        print(f"{Colors.BOLD}{'='*50}{Colors.NC}")
        print(f"Services in HOSTED_APPS.md: {len(self.services)}")
        print(f"NPM Plus Proxy Hosts: {len(self.npm_hosts)}")
        print(f"Traefik Routes: {len(self.traefik_routes)}")
        print()
        print(f"NPM Validation: {Colors.GREEN}{npm_matches} OK{Colors.NC}, {Colors.RED}{npm_issues} issues{Colors.NC}")
        print(f"Traefik Validation: {Colors.GREEN}{traefik_matches} OK{Colors.NC}, {Colors.RED}{traefik_issues} issues{Colors.NC}")
        print()

        total_issues = npm_issues + traefik_issues
        if total_issues == 0:
            print(f"{Colors.GREEN}{Colors.BOLD}✓ All validations passed!{Colors.NC}")
        else:
            print(f"{Colors.YELLOW}{Colors.BOLD}⚠ Found {total_issues} total issues{Colors.NC}")
        print()

def main():
    parser = argparse.ArgumentParser(
        description="Cross-reference NPM Plus and Traefik with HOSTED_APPS.md"
    )
    parser.add_argument(
        "--hosted-apps",
        default="/opt/stacks/HOSTED_APPS.md",
        help="Path to HOSTED_APPS.md"
    )
    parser.add_argument(
        "--traefik-host",
        default="192.168.0.2",
        help="Traefik host IP"
    )
    parser.add_argument(
        "--no-traefik",
        action="store_true",
        help="Skip Traefik validation"
    )

    args = parser.parse_args()

    validator = CrossReferenceValidator(args.hosted_apps)

    # Parse all sources
    validator.parse_hosted_apps()
    validator.parse_npm_hosts()

    if not args.no_traefik:
        validator.query_traefik_config(args.traefik_host)

    # Run validations
    npm_results = validator.validate_npm_hosts()

    if not args.no_traefik and validator.traefik_routes:
        traefik_results = validator.validate_traefik_routes()
    else:
        traefik_results = (0, 0)

    # Generate report
    validator.generate_report(npm_results, traefik_results)

    # Exit with error code if issues found
    total_issues = npm_results[1] + traefik_results[1]
    sys.exit(1 if total_issues > 0 else 0)

if __name__ == "__main__":
    main()
