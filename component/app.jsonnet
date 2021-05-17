local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.keycloak;
local argocd = import 'lib/argocd.libjsonnet';
local instance = inv.parameters._instance;

local app = argocd.App(instance, params.namespace) {
  spec+: {
    source+: {
      path: 'manifests/keycloak/' + instance,
    },
  },
};

{
  [instance]: app,
}
