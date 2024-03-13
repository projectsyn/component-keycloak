local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.keycloak;

local ingress_name = 'keycloakx-auth-rewrite';
local keycloak_name = 'keycloakx';
local ingress_class_name =
  if params.ingressAuthRewrite.ingressClassName != null then
    { ingressClassName: params.ingressAuthRewrite.ingressClassName }
  else
    {};
local ingress_path =
  if inv.parameters.facts.distribution == 'openshift4' then
    '/auth'
  else
    '/auth(/|$)(.*)';

local ingress =
  kube.Ingress(ingress_name) {
    metadata+: {
      annotations: params.ingressAuthRewrite.annotations,
      labels: params.labels,
    },
    spec+:
      ingress_class_name
      {
        rules: [
          {
            host: params.fqdn,
            http:
              {
                paths: [
                  {
                    path: ingress_path,
                    pathType: 'Prefix',
                    backend: {
                      service: {
                        name: keycloak_name + '-http',
                        port: {
                          name: params.helm_values.ingress.servicePort,
                        },
                      },
                    },
                  },
                ],
              },
          },
        ],
        tls: [
          {
            hosts: [
              params.fqdn,
            ],
            secretName: params.ingressAuthRewrite.tls.secretName,
          },
        ],

      },
  };

{
  [if params.ingressAuthRewrite.enabled then '20_ingress_auth_rewrite']: ingress,
}
