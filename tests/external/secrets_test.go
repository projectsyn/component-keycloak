package external

import (
	"os"
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

// Because we don't need a certificate secret if the server's certificate is valid (e.g. Let's Encrypt)
func Test_Database_Certificate_Secret_NotExists(t *testing.T) {
	_, err := os.Lstat(testPath+"/13_db_certs.yaml")
	assert.Error(t, err)
	assert.True(t, os.IsNotExist(err))
}
