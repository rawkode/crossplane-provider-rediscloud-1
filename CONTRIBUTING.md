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
2. Test your changes locally: `./scripts/test-provider.sh`
3. Ensure all CRDs generate properly: `make generate`

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