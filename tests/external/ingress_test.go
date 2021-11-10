package external

import (
	"testing"

	"github.com/projectsyn/component-keycloak/common"
)


func Test_IngressApiVersion(t *testing.T) {
	common.IngressApiVersionTest(t, testPath)
}
