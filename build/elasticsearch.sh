#!/usr/bin/env bash

set -eo pipefail

echo "[elasticsearch] starting elasticsearch service..."
exec /opt/elasticsearch/bin/elasticsearch
