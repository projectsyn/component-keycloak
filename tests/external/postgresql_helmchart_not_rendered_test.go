package external

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func Test_Postgresql_Helmchart_Not_Rendered(t *testing.T) {
	subChartDir := testPath + "/01_keycloak_helmchart/keycloak/charts"
	require.NoDirExists(t, subChartDir)
}
