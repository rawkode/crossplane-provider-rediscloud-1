# Testing the RedisCloud Crossplane Provider

This guide explains how to test the RedisCloud Crossplane provider using standard Crossplane workflows.

## Prerequisites

- Docker or Podman installed and running
- Go 1.21+ installed
- Access to RedisCloud API credentials
- Make installed
- Kind (Kubernetes in Docker) installed

## Quick Start

1. **Get RedisCloud Credentials**
   ```bash
   # Visit https://app.redislabs.com/#/login
   # Go to Account Settings → API Keys
   # Create a new API key or use existing one
   ```

2. **Set Credentials as Environment Variables**

   Copy `.envrc.example` to `.envrc` and update with your credentials:
   ```bash
   cp .envrc.example .envrc
   # Edit .envrc with your actual API credentials
   source .envrc
   ```

   Or set directly:
   ```bash
   # For Pro subscriptions, set RedisCloud API credentials
   # These are used to automatically fetch payment method IDs
   export REDISCLOUD_API_KEY="your-api-key"
   export REDISCLOUD_SECRET_KEY="your-secret-key"
   export REDISCLOUD_URL="https://api.redislabs.com/v1"

   # Optionally specify a payment method ID directly
   # export REDISCLOUD_PAYMENT_METHOD_ID=47739
   ```

   For 1Password users:
   ```bash
   # Store your op:// references in .envrc.local
   echo 'export REDISCLOUD_API_KEY="op://Private/Redis Cloud/api-tokens/api-account-key"' >> .envrc.local
   echo 'export REDISCLOUD_SECRET_KEY="op://Private/Redis Cloud/api-tokens/api-user-key"' >> .envrc.local
   ```

3. **Run Tests**
   ```bash
   # Run unit tests
   make test

   # Run end-to-end tests with local deployment
   make e2e

   # Or with 1Password (if credentials are stored there)
   op run -- make e2e
   ```

## Testing Workflows

### Unit Tests

Run unit tests for all packages:
```bash
make test
```

View test coverage:
```bash
make test
go tool cover -html=_output/tests/linux_amd64/coverage.txt
```

### Local Development Testing

1. **Start local Crossplane control plane**
   ```bash
   make local-deploy
   ```

   This will:
   - Start a Kind cluster
   - Install Crossplane
   - Build and install the provider locally
   - Wait for all components to be ready

2. **Apply test resources**
   ```bash
   kubectl apply -f examples/essentials/subscription.yaml
   kubectl get subscription -w
   ```

3. **Check provider logs**
   ```bash
   kubectl logs -n crossplane-system -l pkg.crossplane.io/provider=provider-rediscloud -f
   ```

### End-to-End Testing with Uptest

The provider uses Crossplane's `uptest` tool for automated e2e testing:

```bash
# Run e2e tests with default examples (subscription + database)
make e2e

# Run e2e tests with specific examples
export UPTEST_EXAMPLE_LIST="examples/essentials/subscription.yaml"
make e2e

# Or specify inline
UPTEST_EXAMPLE_LIST="examples/rediscloud/acl-user.yaml" make e2e
```

**Default test examples**: `examples/rediscloud/subscription.yaml,examples/rediscloud/database.yaml`

#### Payment Method Configuration for Pro Subscriptions

Pro subscriptions require a valid payment method ID. The test setup script automatically handles this by:

1. **Automatic Fetching**: If RedisCloud API credentials are provided, the setup script fetches the first available payment method ID from your account
2. **Manual Override**: You can specify a payment method ID directly using `REDISCLOUD_PAYMENT_METHOD_ID`
3. **Fallback**: If no credentials are provided, a default ID (1) is used, which may cause tests to fail

```bash
# List available payment methods
make rediscloud-payment-methods

# Get the first payment method ID
make rediscloud-first-payment-method-id

# Run e2e tests with automatic payment method fetching
make e2e

# Or with 1Password
op run -- make e2e
```

### Manual Testing

1. **Build the provider**
   ```bash
   make build
   ```

2. **Start Crossplane locally**
   ```bash
   # In one terminal, start the control plane
   make controlplane.up
   ```

3. **Install the provider**
   ```bash
   # In another terminal
   make local.xpkg.deploy.provider.provider-rediscloud
   ```

4. **Create provider config with credentials**
   ```bash
   kubectl create secret generic rediscloud-creds \
     --namespace=crossplane-system \
     --from-literal=credentials='{
       "api_key": "your-api-key",
       "secret_key": "your-secret-key",
       "url": "https://api.redislabs.com/v1"
     }'

   kubectl apply -f examples/providerconfig/providerconfig.yaml
   ```

5. **Create resources**
   ```bash
   kubectl apply -f examples/essentials/subscription.yaml
   ```

## Available Make Targets

```bash
make help              # Show all available targets
make test             # Run unit tests
make e2e              # Run end-to-end tests
make build            # Build the provider binary
make local-deploy     # Deploy provider to local Kind cluster
make run              # Run provider locally (out of cluster)
```

## Example Resources

### Create an Essentials Subscription
```yaml
apiVersion: essentials.redis.io/v1alpha1
kind: Subscription
metadata:
  name: my-essentials-sub
spec:
  forProvider:
    name: "My Redis Subscription"
    planId: 1  # Free plan
  providerConfigRef:
    name: default
```

### Create a Pro Subscription with Database
```yaml
apiVersion: rediscloud.redis.io/v1alpha1
kind: Subscription
metadata:
  name: my-pro-sub
spec:
  forProvider:
    name: "My Pro Subscription"
    memoryStorage: "ram"
    paymentMethod: "credit-card"
    paymentMethodId: 1  # Required for credit-card payment method
    cloudProvider:
    - provider: "AWS"
      region:
      - region: "us-east-1"
        networkingDeploymentCidr: "10.0.0.0/24"
    creationPlan:
    - quantity: 1
      replication: true
      throughputMeasurementBy: "number-of-shards"
      throughputMeasurementValue: 1
  providerConfigRef:
    name: default
```

## Troubleshooting

### Provider Not Installing
```bash
# Check provider status
kubectl get providers
kubectl describe provider provider-rediscloud

# Check provider pod logs
kubectl logs -n crossplane-system -l pkg.crossplane.io/provider=provider-rediscloud
```

### Credentials Issues
```bash
# Verify secret exists
kubectl get secret rediscloud-creds -n crossplane-system -o yaml

# Check ProviderConfig
kubectl get providerconfig default -o yaml
```

### Resource Creation Fails
```bash
# Check resource status
kubectl describe subscription my-subscription

# Check provider logs
kubectl logs -n crossplane-system -l pkg.crossplane.io/provider=provider-rediscloud -f

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Clean Up
```bash
# Remove test resources
kubectl delete -f examples/

# Tear down local development environment
make controlplane.down

# Delete entire Kind cluster
kind delete cluster --name kind
```

## CI/CD Integration

The project uses GitHub Actions for continuous integration:

- **Unit tests** run on every pull request
- **E2E tests** run on every pull request
- **Code coverage** is reported to Codecov
- **Linting** enforces code quality standards

To run the same checks locally before pushing:
```bash
make reviewable
```

## Development Workflow

1. Make changes to the provider code
2. Run unit tests: `make test`
3. Build provider: `make build`
4. Deploy locally: `make local-deploy`
5. Test your changes with example resources
6. Run full e2e suite: `make e2e`
7. Submit PR - CI will run all tests automatically

## Environment Variables

The following environment variables can be used to configure testing:

- `UPTEST_CLOUD_CREDENTIALS` - JSON string with RedisCloud credentials
- `UPTEST_EXAMPLE_LIST` - Comma-separated list of example files to test
- `UPTEST_DATASOURCE_PATH` - Path to datasource file for dynamic values
- `CROSSPLANE_NAMESPACE` - Namespace for Crossplane (default: crossplane-system)

## Additional Resources

- [Crossplane Testing Guide](https://crossplane.io/docs/latest/contributing/testing.html)
- [Uptest Documentation](https://github.com/crossplane/uptest)
- [RedisCloud API Documentation](https://api.redislabs.com/v1/swagger-ui.html)