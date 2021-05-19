// main template for keycloak
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
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
    [if params.database.tls.enabled then 'JDBC_PARAMS']: params.database.tls.jdbcParams,
  },
  external: {
    DB_DATABASE: params.database.database,
    DB_USER: params.database.username,
    DB_PASSWORD: params.database.password,
    DB_VENDOR: params.database.external.vendor,
    DB_ADDR: params.database.external.host,
    DB_PORT: std.toString(params.database.external.port),
    [if params.database.tls.enabled then 'JDBC_PARAMS']: params.database.tls.jdbcParams,
  },
};

local db_secret = kube.Secret(params.database.secretname) {
  metadata+: {
    labels+: params.labels,
  },
  stringData: connection_secrets[params.database.provider],
};

local db_cert_secret = kube.Secret(params.database.tls.certSecretName) {
  metadata+: {
    labels+: params.labels,
  },
  type: 'kubernetes.io/tls',
  stringData: {
    'tls.key': params.database.tls.serverCertKey,
    'tls.crt': params.database.tls.serverCert,
  },
};

// Define outputs below
{
  '00_namespace': namespace,
  '10_admin_secret': admin_secret,
  '11_db_secret': db_secret,
  [if params.database.tls.enabled && params.database.tls.verification != 'verify' then '13_db_certs']: db_cert_secret,
}
