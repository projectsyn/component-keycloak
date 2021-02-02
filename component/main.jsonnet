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

local external_db_secret =
  if params.postgres.builtin == false then
    kube.Secret(params.postgres.external.secretname) {
      metadata+: {
        labels+: params.labels,
      },
      stringData:
        {
          DB_VENDOR: 'postgres',
          DB_ADDR: params.postgres.external.address,
          DB_PORT: params.postgres.external.port,
          DB_DATABASE: params.postgres.external.database,
          DB_USER: params.postgres.external.user,
          DB_PASSWORD: params.postgres.external.password,
        }
    };

// Define outputs below
{
  '00_namespace': namespace,
  '10_admin_secret': admin_secret,
  [if external_db_secret != null then '20_external_db_secret']: external_db_secret,
}
