package builtin

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
	index := -1
	for i, v := range env {
		if v.Name == "DB_PASSWORD" {
			index = i
		}
		if v.Name == "DB_ADDR" {
			assert.Equal(t, "patched", v.Value)
		}
	}
	assert.GreaterOrEqual(t, index, 0)
	assert.Equal(t, expectedDbSecretName, env[index].ValueFrom.SecretKeyRef.Name)

	envFrom := subject.Spec.Template.Spec.Containers[0].EnvFrom
	assert.Equal(t, expectedDbSecretName, envFrom[1].SecretRef.Name)

	assert.Len(t, subject.Spec.Template.Spec.InitContainers, 2)
	for _, c := range subject.Spec.Template.Spec.InitContainers {
		if c.Name == "theme-provider" {
			assert.Equal(t, "quay.io/vshn/keycloak-theme:v1.0.0", c.Image)
		}
	}

	assert.Len(t, subject.Spec.Template.Spec.Volumes, 4)
	containsTest := false
	for _, v := range subject.Spec.Template.Spec.Volumes {
		if v.Name == "test" {
			containsTest = true
		}
	}
	assert.True(t, containsTest)

	assert.Len(t, subject.Spec.Template.Spec.Containers[0].VolumeMounts, 4)
	containsTest = false
	for _, v := range subject.Spec.Template.Spec.Containers[0].VolumeMounts {
		if v.Name == "test" {
			containsTest = true
			assert.Equal(t, "/opt/test", v.MountPath)
		}
	}
	assert.True(t, containsTest)

}
