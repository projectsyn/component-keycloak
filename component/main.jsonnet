// main template for keycloak
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local rl = import 'lib/resource-locker.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.keycloak;

local namespace = kube.Namespace(params.namespace);

local admin_secret = kube.Secret(params.admin.secretname) {
  metadata+: {
    labels+: params.labels,
  },
  stringData: {
    KEYCLOAK_USER: params.admin.username,
    KEYCLOAK_PASSWORD: params.admin.password,
  },
};

local connection_secrets = {
  builtin: {
    // this secret is shared between Keycloak and PostgreSQL
    'postgresql-password': params.database.password,
    [if params.database.jdbcParams != '' then 'JDBC_PARAMS']: params.database.jdbcParams,
  },
  external: {
    DB_DATABASE: params.database.database,
    DB_USER: params.database.username,
    DB_PASSWORD: params.database.password,
    DB_VENDOR: params.database.external.vendor,
    DB_ADDR: params.database.external.host,
    DB_PORT: std.toString(params.database.external.port),
    [if params.database.jdbcParams != '' then 'JDBC_PARAMS']: params.database.jdbcParams,
  },
};

local db_secret = kube.Secret(params.database.secretname) {
  metadata+: {
    labels+: params.labels,
  },
  stringData: connection_secrets[params.database.provider],
};

// this secret is shared between Keycloak and PostgreSQL
local db_cert_secret = kube.Secret(params.database.tls.certSecretName) {
  metadata+: {
    labels+: params.labels,
  },
  stringData:
    if params.database.tls.verification == 'selfsigned' then
      {
        'tls.key': params.database.tls.serverCertKey,
        'tls.crt': params.database.tls.serverCert,
      }
    else
      {
        'README.txt': 'Keycloak is configured with DB TLS verification mode "%s", no custom CA cert required' % [ params.database.tls.verification ],
        'tls.crt': '',
      },
};

// Add a label to the namespace of the ingress-controller for the network policy selector.
local ns_patch =
  rl.Patch(
    kube.Namespace(params.ingress.controllerNamespace),
    {
      metadata: {
        labels: {
          name: params.ingress.controllerNamespace,
        },
      },
    }
  );

local keycloak_tls = {
  apiVersion: 'cert-manager.io/v1alpha2',
  kind: 'Certificate',
  metadata: {
    name: params.acmecertificate.name,
    labels: params.labels,
  },
  spec: {
    secretName: params.acmecertificate.name,
    dnsNames: [
      params.acmecertificate.name,
    ],
    issuerRef: {
      name: params.acmecertificate.issuer.name,
      kind: 'ClusterIssuer',
      group: 'cert-manager.io',
    },
  },
};

// Define outputs below
{
  '00_namespace': namespace,
  [if params.ingress.enabled && params.helm_values.networkPolicy.enabled then '01_ingress_controller_ns_patch']: ns_patch,
  '10_admin_secret': admin_secret,
  '11_db_secret': db_secret,
  [if params.database.tls.enabled then '12_db_certs']: db_cert_secret,
  [if params.acmecertificate.enabled then '13_keycloak_tls']: keycloak_tls,
}
