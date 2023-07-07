#! /bin/bash

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
ENVIRONMENTS_DIR="${PROJECT_DIR}/environments"


ENV=$1

( cd $PROJECT_DIR ; env-cmd -f "${ENVIRONMENTS_DIR}/${ENV}.env" npm run build )