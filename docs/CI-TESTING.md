# CI and Testing Infrastructure

This document describes the CI/CD pipeline and testing infrastructure for the Crossplane Provider RedisCloud.

## CI/CD Workflows

### Main CI Pipeline (`.github/workflows/ci.yml`)

The main CI pipeline runs on every push to main/release branches and on pull requests. It includes:

- **detect-noop**: Skips CI for documentation-only changes
- **report-breaking-changes**: Detects breaking CRD OpenAPI schema changes
- **lint**: Runs golangci-lint with caching for faster runs
- **check-diff**: Verifies generated code is up-to-date
- **unit-tests**: Runs Go unit tests with coverage reporting
- **local-deploy**: Tests local deployment of the provider
- **check-examples**: Validates example manifests against CRDs
- **publish-artifacts**: Builds and publishes provider artifacts

All resource-intensive jobs include disk cleanup for optimal performance.

### End-to-End Testing (`.github/workflows/uptest-trigger.yaml`)

Triggered via PR comments with `/test-examples="<path>"`:

- Permission-based access control (write/admin only)
- Dynamic example selection based on paths
- Creates GitHub status checks for test results
- Captures cluster dumps on failure for debugging
- Uses `uptest` framework for automated testing

Example usage:
```
/test-examples="examples/rediscloud"
```

### Stale Issue Management (`.github/workflows/stale.yml`)

Automatically manages stale issues and PRs:
- Marks issues/PRs as stale after 90 days of inactivity
- Closes them after 14 additional days without activity
- Users can use `/fresh` comment to remove stale label

## Testing

### Unit Tests

Unit tests are located throughout the codebase in `*_test.go` files:

- `config/provider_test.go`: Tests provider configuration
- `config/external_name_test.go`: Tests external name configuration
- `internal/clients/rediscloud_test.go`: Tests client setup

Run unit tests:
```bash
make test
```

### Example Validation

The `scripts/check-examples.py` script validates all example manifests against their CRDs:

```bash
make check-examples
```

Or directly:
```bash
python3 scripts/check-examples.py package/crds examples
```

Requirements:
- Python 3.x
- PyYAML (`pip install pyyaml`)

### End-to-End Tests

Run e2e tests with uptest:
```bash
make e2e
```

Required environment variables:
- `UPTEST_EXAMPLE_LIST`: Comma-separated list of example files
- `UPTEST_CLOUD_CREDENTIALS`: Cloud provider credentials

## Code Coverage

Code coverage is automatically reported to Codecov on every CI run. Configuration is in `codecov.yml`.

Coverage requirements:
- Project: Auto-target with 2% threshold
- Patch: 80% target with 5% threshold

## Example Manifests

Example manifests are located in `examples/` directory:

- `examples/rediscloud/`: Resource examples
  - `subscription.yaml`: Redis subscription
  - `database.yaml`: Subscription database
  - `subscription-peering.yaml`: VPC peering
  - `acl-user.yaml`: ACL user
  - `acl-rule.yaml`: ACL rule
  - `cloud-account.yaml`: Cloud account
- `examples/compositions/`: Crossplane compositions
  - `redis-cluster.yaml`: Complete Redis cluster composition
- `examples/providerconfig/`: Provider configuration
- `examples/storeconfig/`: Store configuration

## Make Targets

Testing-related Make targets:

```bash
make test              # Run unit tests
make e2e               # Run end-to-end tests
make uptest            # Run uptest framework
make check-examples    # Validate example manifests
make lint              # Run linting
make check-diff        # Verify generated code
make crddiff           # Check for breaking CRD changes
```

## Contributing

When submitting PRs:

1. Ensure all tests pass: `make test`
2. Validate examples: `make check-examples`
3. Run linting: `make lint`
4. Verify generated code: `make check-diff`
5. Test your changes with: `/test-examples="<path>"` comment on PR

## Dependencies

- Go 1.21+
- Python 3.x (for check-examples.py)
- PyYAML (`pip install pyyaml`)
- Docker (for local deployment)
- Kind (for local Kubernetes cluster)