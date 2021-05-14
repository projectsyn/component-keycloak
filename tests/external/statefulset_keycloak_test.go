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
	index := -1
	for i, v := range env {
		if v.Name == "DB_PASSWORD" {
			index = i
		}
	}
	assert.GreaterOrEqual(t, index, 0)
	assert.Equal(t, expectedDbSecretName, env[index].ValueFrom.SecretKeyRef.Name)

	envFrom := subject.Spec.Template.Spec.Containers[0].EnvFrom
	assert.Equal(t, expectedDbSecretName, envFrom[1].SecretRef.Name)
}
