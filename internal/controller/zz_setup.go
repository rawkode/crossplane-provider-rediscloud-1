// SPDX-FileCopyrightText: 2024 The Crossplane Authors <https://crossplane.io>
//
// SPDX-License-Identifier: Apache-2.0

package controller

import (
	ctrl "sigs.k8s.io/controller-runtime"

	"github.com/crossplane/upjet/pkg/controller"

	role "github.com/RedisLabs/provider-rediscloud/internal/controller/acl/role"
	rule "github.com/RedisLabs/provider-rediscloud/internal/controller/acl/rule"
	user "github.com/RedisLabs/provider-rediscloud/internal/controller/acl/user"
	activeprivateserviceconnect "github.com/RedisLabs/provider-rediscloud/internal/controller/active/activeprivateserviceconnect"
	activeprivateserviceconnectendpoint "github.com/RedisLabs/provider-rediscloud/internal/controller/active/activeprivateserviceconnectendpoint"
	activeprivateserviceconnectendpointaccepter "github.com/RedisLabs/provider-rediscloud/internal/controller/active/activeprivateserviceconnectendpointaccepter"
	activesubscription "github.com/RedisLabs/provider-rediscloud/internal/controller/active/activesubscription"
	activesubscriptiondatabase "github.com/RedisLabs/provider-rediscloud/internal/controller/active/activesubscriptiondatabase"
	activesubscriptionpeering "github.com/RedisLabs/provider-rediscloud/internal/controller/active/activesubscriptionpeering"
	activesubscriptionregions "github.com/RedisLabs/provider-rediscloud/internal/controller/active/activesubscriptionregions"
	activetransitgatewayattachment "github.com/RedisLabs/provider-rediscloud/internal/controller/active/activetransitgatewayattachment"
	account "github.com/RedisLabs/provider-rediscloud/internal/controller/cloud/account"
	database "github.com/RedisLabs/provider-rediscloud/internal/controller/essentials/database"
	subscription "github.com/RedisLabs/provider-rediscloud/internal/controller/essentials/subscription"
	serviceconnect "github.com/RedisLabs/provider-rediscloud/internal/controller/private/serviceconnect"
	serviceconnectendpoint "github.com/RedisLabs/provider-rediscloud/internal/controller/private/serviceconnectendpoint"
	serviceconnectendpointaccepter "github.com/RedisLabs/provider-rediscloud/internal/controller/private/serviceconnectendpointaccepter"
	providerconfig "github.com/RedisLabs/provider-rediscloud/internal/controller/providerconfig"
	subscriptionrediscloud "github.com/RedisLabs/provider-rediscloud/internal/controller/rediscloud/subscription"
	databasesubscription "github.com/RedisLabs/provider-rediscloud/internal/controller/subscription/database"
	peering "github.com/RedisLabs/provider-rediscloud/internal/controller/subscription/peering"
	gatewayattachment "github.com/RedisLabs/provider-rediscloud/internal/controller/transit/gatewayattachment"
)

// Setup creates all controllers with the supplied logger and adds them to
// the supplied manager.
func Setup(mgr ctrl.Manager, o controller.Options) error {
	for _, setup := range []func(ctrl.Manager, controller.Options) error{
		role.Setup,
		rule.Setup,
		user.Setup,
		activeprivateserviceconnect.Setup,
		activeprivateserviceconnectendpoint.Setup,
		activeprivateserviceconnectendpointaccepter.Setup,
		activesubscription.Setup,
		activesubscriptiondatabase.Setup,
		activesubscriptionpeering.Setup,
		activesubscriptionregions.Setup,
		activetransitgatewayattachment.Setup,
		account.Setup,
		database.Setup,
		subscription.Setup,
		serviceconnect.Setup,
		serviceconnectendpoint.Setup,
		serviceconnectendpointaccepter.Setup,
		providerconfig.Setup,
		subscriptionrediscloud.Setup,
		databasesubscription.Setup,
		peering.Setup,
		gatewayattachment.Setup,
	} {
		if err := setup(mgr, o); err != nil {
			return err
		}
	}
	return nil
}
