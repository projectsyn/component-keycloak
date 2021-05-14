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

local keycloak_postgresql_secret = kube.Secret(params.database.existingSecret) {
  metadata+: {
    labels+: params.labels,
  },
  stringData: {
    'postgresql-password': params.database.postgresqlPassword,
  },
};

local external_db_secret =
  local isdummysecret =
    if params.database.builtin then
      {
        'commodore.syn.tools/dummy-secret': 'true',
      }
    else
      {};
  kube.Secret(params.database.external.secretname) {
    metadata+: {
      labels+: params.labels + isdummysecret,
    },
    stringData:
      if !params.database.builtin then
        {
          DB_VENDOR: params.database.external.vendor,
          DB_ADDR: params.database.external.host,
          DB_PORT: params.database.external.port,
          DB_DATABASE: params.database.external.database,
          DB_USER: params.database.external.username,
          DB_PASSWORD: params.database.external.password,
        }
      else {},
  };

// Define outputs below
{
  '00_namespace': namespace,
  '10_admin_secret': admin_secret,
  '20_external_db_secret': external_db_secret,
  [if params.database.builtin then '20_keycloak_postgresql_secret']: keycloak_postgresql_secret,
}
