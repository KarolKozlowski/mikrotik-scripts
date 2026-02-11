#!/usr/bin/env python3
"""
Generate NAT rules for MikroTik RouterOS.

This script generates both dst-nat and src-nat rules for port forwarding and hairpin NAT.

Example:
    ./gen-nat.py --public-ip 195.136.68.11 --dest-ip 172.16.1.10 --ports 32400/tcp
    ./gen-nat.py --public-ip 195.136.68.11 --dest-ip 172.16.1.10 --ports 21/tcp,40000-40010/tcp
"""

import argparse
import os
import sys
from typing import List, Tuple

# ============================================================================
# CONFIGURATION - Edit these defaults to match your environment
# ============================================================================

# Default public IP (can be overridden with --public-ip)
DEFAULT_PUBLIC_IP = os.environ.get('MIKROTIK_PUBLIC_IP', None)

# Default destination IP (can be overridden with --dest-ip)
DEFAULT_DEST_IP = os.environ.get('MIKROTIK_DEST_IP', None)

# Default gateway IP (can be overridden with --gateway-ip)
# Set to None to auto-calculate as .1 in the dest-ip subnet
DEFAULT_GATEWAY_IP = os.environ.get('MIKROTIK_GATEWAY_IP', None)

# Default application name (can be overridden with --app)
# Leave empty string for no application name in comments
DEFAULT_APP = os.environ.get('MIKROTIK_APP', '')

# Generate hairpin NAT rules (can be disabled with --no-hairpin)
GENERATE_HAIRPIN_RULES = True

# ============================================================================


def parse_ports(ports_str: str) -> List[Tuple[str, str]]:
    """
    Parse port specification in firewall-cmd format.

    Args:
        ports_str: Port specification (e.g., "123/tcp,456-789/udp")

    Returns:
        List of (port_spec, protocol) tuples

    Raises:
        ValueError: If port format is invalid
    """
    ports = []
    for spec in ports_str.split(','):
        spec = spec.strip()
        if '/' not in spec:
            raise ValueError(f"Invalid port format: {spec}. Expected 'port/protocol' or 'port-range/protocol'")

        port_part, protocol = spec.rsplit('/', 1)
        protocol = protocol.lower()

        if protocol not in ('tcp', 'udp'):
            raise ValueError(f"Invalid protocol: {protocol}. Must be 'tcp' or 'udp'")

        # Validate port part (can be single port or range)
        if '-' in port_part:
            parts = port_part.split('-')
            if len(parts) != 2:
                raise ValueError(f"Invalid port range: {port_part}")
            try:
                start, end = int(parts[0]), int(parts[1])
                if not (1 <= start <= 65535 and 1 <= end <= 65535 and start <= end):
                    raise ValueError(f"Port out of valid range (1-65535): {port_part}")
            except ValueError as e:
                raise ValueError(f"Invalid port range: {port_part}") from e
        else:
            try:
                port = int(port_part)
                if not (1 <= port <= 65535):
                    raise ValueError(f"Port out of valid range (1-65535): {port_part}")
            except ValueError as e:
                raise ValueError(f"Invalid port: {port_part}") from e

        ports.append((port_part, protocol))

    return ports


def generate_nat_rules(
    public_ip: str,
    dest_ip: str,
    ports: List[Tuple[str, str]],
    gateway_ip: str = None,
    generate_hairpin: bool = True,
    app: str = '',
) -> str:
    """
    Generate NAT rules for MikroTik.

    Args:
        public_ip: Public IP address
        dest_ip: Destination IP address (internal)
        ports: List of (port_spec, protocol) tuples
        gateway_ip: Gateway IP for src-nat (defaults to first octet of dest_ip network)
        generate_hairpin: Whether to generate hairpin NAT rules
        app: Application name for comments (optional)

    Returns:
        RouterOS script with NAT rules
    """
    if gateway_ip is None:
        # Default gateway is .1 in the same subnet
        octets = dest_ip.split('.')
        gateway_ip = '.'.join(octets[:-1]) + '.1'

    rules = []

    for port_spec, protocol in ports:
        # Format port spec for display
        port_display = port_spec.replace('-', '-')
        
        # Build comment with app name if provided
        app_prefix = f"{app}: " if app else ""
        dstnat_comment = f"{app_prefix}dstnat {dest_ip}:{port_display}/{protocol}"
        hairpin_dstnat_comment = f"{app_prefix}hairpin dstnat {dest_ip}:{port_display}/{protocol}"
        hairpin_srcnat_comment = f"{app_prefix}hairpin srcnat {dest_ip}:{port_display}/{protocol}"

        # dst-nat rule (public to internal)
        rules.append(f"/ip firewall nat add chain=dstnat action=dst-nat protocol={protocol} \\")
        rules.append(f"  dst-address={public_ip} dst-port={port_spec} \\")
        rules.append(f"  to-addresses={dest_ip} to-ports={port_spec} \\")
        rules.append(f"  comment=\"{dstnat_comment}\"")
        rules.append("")

        if generate_hairpin:
            # hairpin dst-nat rule (internal to internal via public IP)
            rules.append(f"/ip firewall nat add chain=dstnat action=dst-nat protocol={protocol} \\")
            rules.append(f"  dst-address={public_ip} dst-port={port_spec} \\")
            rules.append(f"  to-addresses={dest_ip} to-ports={port_spec} \\")
            rules.append(f"  comment=\"{hairpin_dstnat_comment}\"")
            rules.append("")

            # hairpin src-nat rule (masquerade internal traffic)
            rules.append(f"/ip firewall nat add chain=srcnat action=src-nat protocol={protocol} \\")
            rules.append(f"  dst-address={dest_ip} dst-port={port_spec} \\")
            rules.append(f"  to-addresses={gateway_ip} \\")
            rules.append(f"  comment=\"{hairpin_srcnat_comment}\"")
            rules.append("")

    return '\n'.join(rules)


def main():
    parser = argparse.ArgumentParser(
        description='Generate NAT rules for MikroTik RouterOS',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --public-ip 195.136.68.11 --dest-ip 172.16.1.10 --ports 32400/tcp
  %(prog)s --public-ip 195.136.68.11 --dest-ip 172.16.1.10 --ports 21/tcp,40000-40010/tcp,2001/udp
  %(prog)s --public-ip 195.136.68.11 --dest-ip 172.16.1.10 --ports 80/tcp,443/tcp --gateway-ip 172.16.1.1

Environment Variables:
  MIKROTIK_PUBLIC_IP   - Set default public IP
  MIKROTIK_DEST_IP     - Set default destination IP
  MIKROTIK_GATEWAY_IP  - Set default gateway IP
  MIKROTIK_APP         - Set default application name
        """
    )

    parser.add_argument(
        '--public-ip',
        default=DEFAULT_PUBLIC_IP,
        help='Public IP address' + (f' (default: {DEFAULT_PUBLIC_IP})' if DEFAULT_PUBLIC_IP else '')
    )
    parser.add_argument(
        '--dest-ip',
        default=DEFAULT_DEST_IP,
        help='Destination IP address (internal)' + (f' (default: {DEFAULT_DEST_IP})' if DEFAULT_DEST_IP else '')
    )
    parser.add_argument(
        '--ports',
        default=None,
        help='Ports in firewall-cmd format (e.g., 80/tcp,443/tcp,8000-8100/udp)'
    )
    parser.add_argument(
        '--gateway-ip',
        default=DEFAULT_GATEWAY_IP,
        help='Gateway IP for src-nat (defaults to .1 in dest-ip subnet)' + (f' (default: {DEFAULT_GATEWAY_IP})' if DEFAULT_GATEWAY_IP else '')
    )
    parser.add_argument(
        '--no-hairpin',
        action='store_true',
        default=not GENERATE_HAIRPIN_RULES,
        help='Do not generate hairpin NAT rules'
    )
    parser.add_argument(
        '--app',
        default=DEFAULT_APP,
        help='Application name to include in comments' + (f' (default: {DEFAULT_APP})' if DEFAULT_APP else '')
    )

    args = parser.parse_args()

    # Validate required arguments
    if not args.public_ip:
        print("Error: --public-ip is required (or set MIKROTIK_PUBLIC_IP environment variable)", file=sys.stderr)
        sys.exit(1)
    if not args.dest_ip:
        print("Error: --dest-ip is required (or set MIKROTIK_DEST_IP environment variable)", file=sys.stderr)
        sys.exit(1)
    if not args.ports:
        print("Error: --ports is required", file=sys.stderr)
        sys.exit(1)

    try:
        ports = parse_ports(args.ports)
    except ValueError as e:
        print(f"Error parsing ports: {e}", file=sys.stderr)
        sys.exit(1)

    rules = generate_nat_rules(
        args.public_ip,
        args.dest_ip,
        ports,
        args.gateway_ip,
        generate_hairpin=not args.no_hairpin,
        app=args.app
    )

    print(rules)


if __name__ == '__main__':
    main()
