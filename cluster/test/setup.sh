#!/usr/bin/env bash
set -aeuo pipefail

echo "Running setup.sh"
echo "Current directory: $(pwd)"

# Set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="${SCRIPT_DIR}"

# Set default credentials if not provided
if [ -z "${UPTEST_CLOUD_CREDENTIALS:-}" ]; then
  echo "UPTEST_CLOUD_CREDENTIALS not set, using default RedisCloud credentials from environment"
  UPTEST_CLOUD_CREDENTIALS="{\"api_key\":\"${REDISCLOUD_API_KEY:-}\",\"secret_key\":\"${REDISCLOUD_SECRET_KEY:-}\",\"url\":\"${REDISCLOUD_URL:-https://api.redislabs.com/v1}\"}"
fi

echo "Creating cloud credential secret..."
${KUBECTL} -n crossplane-system create secret generic provider-secret --from-literal=credentials="${UPTEST_CLOUD_CREDENTIALS}" --dry-run=client -o yaml | ${KUBECTL} apply -f -

echo "Creating a default provider config..."
cat <<EOF | ${KUBECTL} apply -f -
apiVersion: rediscloud.redis.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      name: provider-secret
      namespace: crossplane-system
      key: credentials
EOF

echo "Waiting until provider is installed..."
${KUBECTL} wait provider.pkg --all --for condition=Installed --timeout 5m

echo "Checking provider status..."
${KUBECTL} get providers

echo "Waiting for all pods to come online..."
${KUBECTL} -n crossplane-system wait --for=condition=Available deployment --all --timeout=5m

# Fetch payment method ID if not provided
if [ -z "${REDISCLOUD_PAYMENT_METHOD_ID:-}" ]; then
  if [ -n "${REDISCLOUD_API_KEY:-}" ] && [ -n "${REDISCLOUD_SECRET_KEY:-}" ]; then
    echo "Fetching payment method ID from RedisCloud API..."
    PAYMENT_ID=$(curl -s -X GET "${REDISCLOUD_URL:-https://api.redislabs.com/v1}/payment-methods" \
      -H "x-api-key: ${REDISCLOUD_API_KEY}" \
      -H "x-api-secret-key: ${REDISCLOUD_SECRET_KEY}" | jq -r '.paymentMethods[0].id // empty')

    if [ -n "${PAYMENT_ID}" ]; then
      export REDISCLOUD_PAYMENT_METHOD_ID="${PAYMENT_ID}"
      echo "Found payment method ID: ${REDISCLOUD_PAYMENT_METHOD_ID}"
    else
      echo "Warning: Could not fetch payment method ID from RedisCloud API"
      echo "Tests requiring payment method ID may fail"
      export REDISCLOUD_PAYMENT_METHOD_ID="1"  # Default fallback
    fi
  else
    echo "Warning: No RedisCloud credentials provided, using default payment method ID"
    export REDISCLOUD_PAYMENT_METHOD_ID="1"  # Default fallback
  fi
else
  echo "Using provided payment method ID: ${REDISCLOUD_PAYMENT_METHOD_ID}"
fi

# Export payment method ID for logging purposes
echo "Using payment method ID: ${REDISCLOUD_PAYMENT_METHOD_ID}"

# Create datasource file for uptest
echo "Creating datasource file for uptest..."
cat > "${TEST_DIR}/datasource.yaml" <<EOF
# Generated datasource file for uptest
payment_method_id: "${REDISCLOUD_PAYMENT_METHOD_ID}"
api_key: "${REDISCLOUD_API_KEY:-}"
secret_key: "${REDISCLOUD_SECRET_KEY:-}"
url: "${REDISCLOUD_URL:-https://api.redislabs.com/v1}"
EOF

echo "Datasource file created at ${TEST_DIR}/datasource.yaml"
