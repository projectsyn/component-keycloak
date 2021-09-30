package external

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/projectsyn/component-keycloak/common"
)

func Test_Keycloak_StatefulSet_Secrets(t *testing.T) {
	subject := common.DecodeStatefulsetV1(t, testPath+"/01_keycloak_helmchart/keycloak/templates/statefulset.yaml")
	require.NotEmpty(t, subject.Spec.Template.Spec.Containers)
	require.NotEmpty(t, subject.Spec.Template.Spec.Containers[0].Env)
	require.NotEmpty(t, subject.Spec.Template.Spec.Containers[0].EnvFrom)

	env := subject.Spec.Template.Spec.Containers[0].Env
	for _, v := range env {
		if v.Name == "DB_PASSWORD" {
			assert.NotEqual(t, "DB_PASSWORD", v.Name)
		}
	}

	envFrom := subject.Spec.Template.Spec.Containers[0].EnvFrom
	assert.Equal(t, expectedDbSecretName, envFrom[1].SecretRef.Name)

	assert.Len(t, subject.Spec.Template.Spec.InitContainers, 0)

	assert.Len(t, subject.Spec.Template.Spec.Volumes, 3)

	assert.Len(t, subject.Spec.Template.Spec.Containers[0].VolumeMounts, 3)
	for _, v := range subject.Spec.Template.Spec.Containers[0].VolumeMounts {
		if v.Name == "startup" {
			assert.Equal(t, "/opt/start", v.MountPath)
		}
	}

}
