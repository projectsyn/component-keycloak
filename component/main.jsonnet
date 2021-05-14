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

local secrets = {
  builtin: {
    'postgresql-password': params.database.password,
  },
  external: {
    DB_DATABASE: params.database.database,
    DB_USER: params.database.username,
    DB_PASSWORD: params.database.password,
    DB_VENDOR: params.database.external.vendor,
    DB_ADDR: params.database.external.host,
    DB_PORT: params.database.external.port,
  },
};

local db_secret = kube.Secret(params.database.secretname) {
  metadata+: {
    labels+: params.labels,
  },
  stringData: secrets[params.database.provider],
};

// Define outputs below
{
  '00_namespace': namespace,
  '10_admin_secret': admin_secret,
  '11_db_secret': db_secret,
}
