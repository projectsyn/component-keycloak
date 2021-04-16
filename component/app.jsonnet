local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.keycloak;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('keycloak', params.namespace);

{
  keycloak: app,
}
