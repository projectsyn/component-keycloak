package external

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/projectsyn/component-keycloak/common"
)

func Test_Keycloak_StatefulSet_Secrets(t *testing.T) {
	subject := common.DecodeStatefulsetV1(t, testPath+"/01_keycloak_helmchart/keycloakx/templates/statefulset.yaml")
	require.NotEmpty(t, subject.Spec.Template.Spec.Containers)
	require.NotEmpty(t, subject.Spec.Template.Spec.Containers[0].Env)
	require.NotEmpty(t, subject.Spec.Template.Spec.Containers[0].EnvFrom)

	env := subject.Spec.Template.Spec.Containers[0].Env
	for _, v := range env {
		if v.Name == "KC_DB_PASSWORD" {
			assert.NotEqual(t, "KC_DB_PASSWORD", v.Name)
		}
	}

	envFrom := subject.Spec.Template.Spec.Containers[0].EnvFrom
	assert.Equal(t, expectedDbSecretName, envFrom[1].SecretRef.Name)
	assert.Len(t, subject.Spec.Template.Spec.InitContainers, 1)
}

func Test_Keycloak_StatefulSet_Volumes(t *testing.T) {
	subject := common.DecodeStatefulsetV1(t, testPath+"/01_keycloak_helmchart/keycloakx/templates/statefulset.yaml")

	volumes := make(map[string]int)
	for _, v := range subject.Spec.Template.Spec.Volumes {
		volumes[v.Name]++
	}

	// from defaults.yml
	assert.Equal(t, 1, volumes["db-certs"])
	assert.Equal(t, 1, volumes["keycloak-tls"])

	// from test inventory
	assert.Equal(t, 1, volumes["themes"])
}
func Test_Keycloak_StatefulSet_VolumeMounts(t *testing.T) {
	subject := common.DecodeStatefulsetV1(t, testPath+"/01_keycloak_helmchart/keycloakx/templates/statefulset.yaml")
	container := subject.Spec.Template.Spec.Containers[0]

	// ensure we have the correct container
	assert.Equal(t, "keycloak", container.Name)

	assert.Len(t, container.VolumeMounts, 5)
	volumeMounts := make(map[string]int)
	for _, v := range container.VolumeMounts {
		volumeMounts[v.Name]++
	}

	// from defaults.yml
	assert.Equal(t, 1, volumeMounts["db-certs"])
	assert.Equal(t, 1, volumeMounts["keycloak-tls"])

	// from test inventory
	assert.Equal(t, 3, volumeMounts["themes"])
}
