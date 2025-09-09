# Testing the RedisCloud Crossplane Provider

This guide explains how to test the RedisCloud Crossplane provider locally using kind (Kubernetes in Docker).

## Prerequisites

- Docker running
- Access to RedisCloud API credentials
- `devenv` shell environment (includes all necessary tools)

## Quick Start

1. **Get RedisCloud Credentials**
   ```bash
   # Visit https://app.redislabs.com/#/login
   # Go to Account Settings → API Keys
   # Create a new API key or use existing one
   ```

2. **Configure Credentials**
   ```bash
   # Edit .envrc and replace placeholder values
   export REDISCLOUD_API_KEY="your-actual-api-key"
   export REDISCLOUD_SECRET_KEY="your-actual-secret-key"
   
   # Reload environment
   direnv allow
   ```

3. **Run Quick Start**
   ```bash
   ./scripts/quick-start.sh
   ```

4. **Test the Provider**
   ```bash
   ./scripts/test-provider.sh
   ```

## Step-by-Step Testing

### 1. Create Kind Cluster
```bash
./scripts/test-provider.sh cluster
```

This creates a kind cluster named `rediscloud-test` with proper port mappings.

### 2. Install Crossplane
```bash
./scripts/test-provider.sh crossplane
```

Installs Crossplane using Helm in the `crossplane-system` namespace.

### 3. Install Provider
```bash
./scripts/test-provider.sh provider
```

Builds the provider image, loads it into kind, and installs it as a Crossplane provider.

### 4. Configure Credentials
```bash
./scripts/test-provider.sh config
```

Creates a Kubernetes secret with your RedisCloud credentials and a ProviderConfig that references it.

### 5. Test with Sample Resource
```bash
./scripts/test-provider.sh test
```

Creates a test Essentials subscription (free tier) to verify the provider works.

### 6. Check Status
```bash
./scripts/test-provider.sh status
```

Shows the status of all components in the cluster.

## Available Resources

The provider includes the following resource groups:

### ACL Resources (`acl.redis.io`)
- `Role` - ACL roles for database access
- `Rule` - ACL rules defining permissions  
- `User` - ACL users with assigned roles

### Active-Active Resources (`active.redis.io`)
- `ActiveSubscription` - Active-Active subscriptions
- `ActiveSubscriptionDatabase` - Databases in AA subscriptions
- `ActiveSubscriptionPeering` - VPC peering for AA subscriptions
- `ActiveSubscriptionRegions` - Region management for AA
- `ActiveTransitGatewayAttachment` - Transit gateway attachments
- `ActivePrivateServiceConnect*` - Private service connect resources

### Cloud Resources (`cloud.redis.io`)
- `Account` - Cloud provider account configurations

### Essentials Resources (`essentials.redis.io`)
- `Database` - Essentials tier databases
- `Subscription` - Essentials tier subscriptions

### Private Service Connect (`private.redis.io`)
- `ServiceConnect` - Private service connect
- `ServiceConnectEndpoint` - Service connect endpoints
- `ServiceConnectEndpointAccepter` - Endpoint accepters

### Pro Subscription Resources (`rediscloud.redis.io`, `subscription.redis.io`)
- `Subscription` - Pro tier subscriptions
- `Database` - Pro tier databases
- `Peering` - VPC peering for subscriptions

### Transit Gateway (`transit.redis.io`)
- `GatewayAttachment` - Transit gateway attachments

## Example Usage

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
./scripts/test-provider.sh cleanup

# Delete entire cluster
kind delete cluster --name rediscloud-test
```

## Environment Variables

The test scripts use these environment variables (configured in `.envrc`):

- `REDISCLOUD_API_KEY` - Your RedisCloud API key
- `REDISCLOUD_SECRET_KEY` - Your RedisCloud secret key  
- `REDISCLOUD_URL` - RedisCloud API URL (default: https://api.redislabs.com/v1)
- `KIND_CLUSTER_NAME` - Kind cluster name (default: rediscloud-test)
- `CROSSPLANE_NAMESPACE` - Crossplane namespace (default: crossplane-system)
- `PROVIDER_NAMESPACE` - Provider namespace (default: crossplane-system)
- `KUBECONFIG_PATH` - Kubeconfig file path (default: ./.kube/config)

## Development Workflow

1. Make changes to the provider code
2. Rebuild: `make build`
3. Reload provider: `./scripts/test-provider.sh provider`
4. Test changes: `./scripts/test-provider.sh test`

The provider image uses `packagePullPolicy: Never` so it will use the locally built image without pulling from a registry.