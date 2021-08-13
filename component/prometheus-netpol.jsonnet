local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.keycloak;

local prometheus_namespace =
  if std.objectHas(inv.parameters, 'rancher_monitoring') then
    inv.parameters.rancher_monitoring.namespace
  else
    'syn-synsights';
local prometheus_name = 'prometheus';

local keycloak_namespace = params.namespace;
local keycloak_name = params.release_name;

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
                  app: prometheus_name,
                },
              },
            },
          ],
          ports: [
            {
              port: 9990,
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
  '40_netpol': netpol,
}
