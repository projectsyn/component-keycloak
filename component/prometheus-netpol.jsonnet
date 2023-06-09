local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.keycloak;

local prometheus_namespace =
  'syn-infra-monitoring';
local prometheus_name = 'prometheus';

local keycloak_namespace = params.namespace;
local keycloak_name = 'keycloakx';

local name = prometheus_name + '-' + prometheus_namespace + '-to-' + keycloak_name;

local netpol =
  kube.NetworkPolicy(name) {
    metadata+: {
      namespace: keycloak_namespace,
    },
    spec+: {
      ingress: [
        {
          from: [
            {
              namespaceSelector: {
                matchLabels: {
                  name: prometheus_namespace,
                },
              },
              podSelector: {
                matchLabels: {
                  'app.kubernetes.io/component': prometheus_name,
                },
              },
            },
          ],
          ports: [
            {
              port: 8080,
              protocol: 'TCP',
            },
          ],
        },
      ],
      podSelector: {
        matchLabels: {
          'app.kubernetes.io/instance': keycloak_name,
          'app.kubernetes.io/name': keycloak_name,
        },
      },
    },
  };

{
  [if params.helm_values.networkPolicy.enabled then '40_netpol']: netpol,
}
