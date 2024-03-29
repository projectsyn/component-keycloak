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

{
  [file]:
    if params.postgresql_helm_values.enabled
    then com.yaml_load(std.extVar('output_path') + '/' + file + file_extension)
    else []
  for file in files
}
