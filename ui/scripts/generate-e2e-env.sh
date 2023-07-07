#!/bin/bash

set -euo pipefail

ENV=$1

cp tests/environments/.e2e.template.${ENV}.env .env.e2e