package external

import (
	"testing"

	"os"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func FileSize(t *testing.T, path string) int64 {
	fi, err := os.Stat(path)
	require.NoError(t, err)
	return fi.Size()
}

func Test_Postgresql_Helmchart_Not_Rendered(t *testing.T) {
	subChartDir := testPath + "/01_keycloak_helmchart/postgresql/templates/primary"

	StatefulSetFileSize := FileSize(t, subChartDir+"/statefulset.yaml")
	assert.Equal(t, StatefulSetFileSize, int64(0))

	ServiceFileSize := FileSize(t, subChartDir+"/svc.yaml")
	assert.Equal(t, ServiceFileSize, int64(0))

	ServiceHeadlessFileSize := FileSize(t, subChartDir+"/svc-headless.yaml")
	assert.Equal(t, ServiceHeadlessFileSize, int64(0))

	NetworkPolicyFileSize := FileSize(t, subChartDir+"/networkpolicy.yaml")
	assert.Equal(t, NetworkPolicyFileSize, int64(0))
}
