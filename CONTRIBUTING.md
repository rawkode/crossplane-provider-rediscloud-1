# Contributing to provider-rediscloud

We welcome contributions to the RedisCloud Crossplane Provider! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally
3. Create a new branch for your feature or fix
4. Make your changes
5. Test your changes
6. Submit a pull request

## Development Setup

See the [README.md](README.md#developing) for development setup instructions.

## Code Standards

- Follow Go best practices and idioms
- Run `go fmt` and `go vet` before committing
- Add tests for new functionality
- Update documentation as needed

## Testing

Before submitting a pull request:

1. Run the full test suite: `make test`
2. Test your changes locally: `make local-deploy`
3. Run end-to-end tests: `make e2e`
4. Ensure all CRDs generate properly: `make generate`
5. Run all pre-submit checks: `make reviewable`

### Testing with RedisCloud Pro Subscriptions

For testing Pro subscription features that require payment methods:

```bash
# Set RedisCloud API credentials
export REDISCLOUD_API_KEY="your-api-key"
export REDISCLOUD_SECRET_KEY="your-secret-key"
export REDISCLOUD_URL="https://api.redislabs.com/v1"

# List available payment methods
make rediscloud-payment-methods

# Get first payment method ID
make rediscloud-first-payment-method-id

# Run e2e tests with automatic payment method fetching
make e2e

# Or with 1Password integration
op run -- make e2e
```

### Useful Make Targets

```bash
make help                                 # Show all available targets
make test                                 # Run unit tests
make e2e                                  # Run end-to-end tests
make local-deploy                         # Deploy provider to local Kind cluster
make run                                  # Run provider locally (out of cluster)
make reviewable                           # Run all checks before submitting PR
make rediscloud-payment-methods          # List available payment methods from RedisCloud
make rediscloud-first-payment-method-id  # Get first payment method ID
```

## Submitting Changes

1. Push your changes to your fork
2. Submit a pull request to the main repository
3. Describe your changes in detail
4. Link any related issues

## Code of Conduct

Please be respectful and professional in all interactions. We strive to maintain a welcoming and inclusive community.

## Questions?

If you have questions, please open an issue or reach out on the Crossplane Slack channel.

Thank you for contributing!