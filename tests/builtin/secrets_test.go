package builtin

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/projectsyn/component-keycloak/common"
)

var (
	expectedDbSecretName = "keycloak-postgresql"
	testPath             = "../../compiled/builtin/builtin"
)

func Test_Database_Secret_DefaultParameters(t *testing.T) {

	subject := common.DecodeSecret(t, testPath+"/11_db_secret.yaml")
	assert.Equal(t, expectedDbSecretName, subject.Name)
	require.NotEmpty(t, subject.StringData)

	data := subject.StringData
	expected := "t-silent-test-1234/c-green-test-1234/builtin/db-password"
	assert.Len(t, data, 4)
	assert.Equal(t, expected, data["KC_DB_PASSWORD"])
	assert.Equal(t, expected, data["postgres-password"])
	assert.Equal(t, expected, data["password"])
}
