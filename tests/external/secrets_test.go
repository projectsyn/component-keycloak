package external

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/projectsyn/component-keycloak/common"
)

var (
	expectedDbSecretName = "keycloak-postgresql"
	testPath             = "../../compiled/keycloak/external"
)

func Test_Database_Secret_DefaultParameters(t *testing.T) {

	subject := common.DecodeSecret(t, testPath+"/11_db_secret.yaml")
	assert.Equal(t, expectedDbSecretName, subject.Name)
	require.NotEmpty(t, subject.StringData)

	data := subject.StringData
	assert.Len(t, data, 7)
	assert.Equal(t, "t-silent-test-1234/c-green-test-1234/external/db-password", data["DB_PASSWORD"])
	assert.Equal(t, "5432", data["DB_PORT"])
}
