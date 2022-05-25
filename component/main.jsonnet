// main template for keycloak
local k8up = import 'lib/backup-k8up.libjsonnet';
local com = import 'lib/commodore.libjsonnet';
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local rl = import 'lib/resource-locker.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.keycloak;

local namespace = kube.Namespace(params.namespace) {
  metadata+: {
    labels+: {
      SYNMonitoring: 'main',
    } + com.makeMergeable(params.namespaceLabels),
  },
};

local admin_secret = kube.Secret(params.admin.secretname) {
  metadata+: {
    labels+: params.labels,
  },
  stringData: {
    KEYCLOAK_ADMIN: params.admin.username,
    KEYCLOAK_ADMIN_PASSWORD: params.admin.password,
  },
};

local connection_secrets = {
  builtin: {
    // PostgreSQL admin password
    'postgresql-postgres-password': params.database.password,
    // this secret is shared between Keycloak and PostgreSQL
    'postgresql-password': params.database.password,
    KC_DB_PASSWORD: params.database.password,
    [if params.database.jdbcParams != '' then 'JDBC_PARAMS']: params.database.jdbcParams,
  },
  external: {
    KC_DB_PASSWORD: params.database.password,
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

local keycloak_cert_secret = kube.Secret(params.tls.secretName) {
  metadata+: {
    labels+: params.labels,
  },
  stringData: {
    'tls.key': params.tls.vault.certKey,
    'tls.crt': params.tls.vault.cert,
    // CA is required by nginx in passthrough mode
    'ca.crt': params.tls.vault.cert,
  },
};

local cert_manager_cert = {
  apiVersion: params.tls.certmanager.apiVersion,
  kind: 'Certificate',
  metadata: {
    name: params.tls.certmanager.certName,
    labels: params.labels,
  },
  spec: {
    secretName: params.tls.secretName,
    dnsNames: [
      params.fqdn,
    ],
    issuerRef: {
      name: params.tls.certmanager.issuer.name,
      kind: params.tls.certmanager.issuer.kind,
      group: params.tls.certmanager.issuer.group,
    },
  },
};

local ingress_tls_secret = kube.Secret(params.ingress.tls.secretName) {
  metadata+: {
    labels+: params.labels,
  },
  stringData: {
    'tls.key': params.ingress.tls.vault.certKey,
    'tls.crt': params.ingress.tls.vault.cert,
  },
};

local create_keycloak_cert_secret =
  params.tls.provider != 'openshift' && params.ingress.enabled && !(params.ingress.tls.termination == 'passthrough' && params.tls.provider == 'certmanager');
local create_ingress_cert_secret =
  params.ingress.enabled && params.ingress.tls.termination == 'reencrypt' && params.tls.provider == 'vault';
local create_ingress_cert =
  params.ingress.enabled && params.ingress.tls.termination == 'passthrough' && params.tls.provider == 'certmanager';

local k8up_repo_secret = kube.Secret(params.k8up.repo.secretName) {
  metadata+: {
    labels+: params.labels,
  },
  stringData: {
    password: params.k8up.repo.password,
  },
};

local k8up_repo_secret_ref = {
  key: 'password',
  name: k8up_repo_secret.metadata.name,
};

local k8up_s3_secret = kube.Secret(params.k8up.s3.secretName) {
  metadata+: {
    labels+: params.labels,
  },
  stringData: {
    username: params.k8up.s3.accessKey,
    password: params.k8up.s3.secretKey,
  },
};

local k8up_s3_secret_ref = {
  name: k8up_s3_secret.metadata.name,
  accesskeyname: 'username',
  secretkeyname: 'password',
};

local k8up_schedule =
  k8up.Schedule(
    'backup',
    '@hourly-random',
    keep_jobs=params.k8up.keepjobs,
    bucket=params.k8up.s3.bucket,
    backupkey=k8up_repo_secret_ref,
    s3secret=k8up_s3_secret_ref,
    create_bucket=false,
  ).schedule + k8up.PruneSpec('@daily-random', 30, 20);

// Define outputs below
{
  '00_namespace': namespace,
  [if params.ingress.enabled && params.helm_values.networkPolicy.enabled then '01_ingress_controller_ns_patch']: ns_patch,
  '10_admin_secret': admin_secret,
  '11_db_secret': db_secret,
  [if params.database.tls.enabled then '12_db_certs']: db_cert_secret,
  [if create_keycloak_cert_secret then '13_keycloak_certs']: keycloak_cert_secret,
  [if create_ingress_cert_secret then '14_ingress_certs']: ingress_tls_secret,
  [if create_ingress_cert then '20_le_cert']: cert_manager_cert,
  [if params.k8up.enabled then '30_k8up']: [ k8up_repo_secret, k8up_s3_secret, k8up_schedule ],
}
