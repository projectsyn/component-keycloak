package builtin

import (
	"testing"

	"github.com/projectsyn/component-keycloak/common"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

var (
	expectedNsLabels = map[string]string{
		"openshift.io/cluster-monitoring": "true",
		"name":          "keycloak-dev",
	}
	testPath = "../../compiled/openshift/openshift"
)

func Test_NamespaceLabels(t *testing.T) {
	ns := common.DecodeNamespace(t, testPath+"/00_namespace.yaml")
	require.NotEmpty(t, ns.Labels)
	assert.Equal(t, expectedNsLabels, ns.Labels)
}
