/**
 * Remove generated postgresql manifests if not required
 */
local com = import 'lib/commodore.libjsonnet';
local inv = com.inventory();
local params = inv.parameters.keycloak;

local file_extension = '.yaml';

local dir_path = std.extVar('output_path');
local files_in_dir = std.native('list_dir')(dir_path, true);

/* Remove file_extension from file list */
local files = [ std.strReplace(file, file_extension, '') for file in files_in_dir ];

local bitnami_ready =
  '[ -f /opt/bitnami/postgresql/tmp/.initialized ] || [ -f /bitnami/postgresql/.initialized ]\n';

// NOTE(sg): The Helm chart has custom logic to inject the `bitnami_ready`
// string in the postgres container's readiness probe when it's rendered with
// an image that contains exactly `bitnami/`. We mimic the Helm chart's
// behavior for images that contain `bitnamilegacy/` here since those still
// are bitnami images and will have the bitnami special readiness indication
// file.
local patchReadinessProbe(obj) =
  if std.startsWith(params.images.postgresql.repository, 'bitnamilegacy/')
     && obj.kind == 'StatefulSet'
     && obj.metadata.name == 'keycloak-postgresql'
  then
    local containers = obj.spec.template.spec.containers;
    assert
      std.length(containers) == 1 :
      'Expected builtin postgres statefulset to have a single container';
    // extract the readiness probe command
    local rcommand = containers[0].readinessProbe.exec.command;
    // extract the sh -c -e prefix
    local shell = rcommand[0:std.length(rcommand) - 1];
    assert
      shell[0] == '/bin/sh' :
      'expected readiness command to start with\n    /bin/sh';
    // patch the command string with a second line checking for the bitnami
    // initialized file.
    local cmd = rcommand[std.length(rcommand) - 1];
    assert
      std.startsWith(cmd, 'exec pg_isready') :
      'expected readiness probe to use `exec pg_isready`';
    local patched_cmd = [ cmd + bitnami_ready ];
    obj {
      spec+: {
        template+: {
          spec+: {
            containers: [
              containers[0] {
                readinessProbe+: {
                  exec: {
                    // set the patched command
                    command: shell + patched_cmd,
                  },
                },
              },
            ],
          },
        },
      },
    }
  else
    obj;

{
  [file]:
    if params.postgresql_helm_values.enabled
    then
      patchReadinessProbe(
        com.yaml_load(std.extVar('output_path') + '/' + file + file_extension)
      )
    else
      []
  for file in files
}
