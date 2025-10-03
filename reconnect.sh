#!/bin/bash
set -euo pipefail

# Run Tailscale with SSH enabled and auth key
sudo tailscale up --auth-key="tskey-auth-k3RNPr2xnB21CNTRL-hJp29f5WG1QUWkwF3ETX1QLweFUwwALF" --ssh
