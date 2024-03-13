package builtin_auth_rewrite

import (
	"testing"

	"github.com/projectsyn/component-keycloak/common"
	"github.com/stretchr/testify/assert"
	networkingv1 "k8s.io/api/networking/v1"
)

var (
	basePath = "../../compiled/builtin-auth-rewrite/builtin-auth-rewrite"
	ingressPath = "/20_ingress_auth_rewrite.yaml"
)

func Test_IngressApiVersion(t *testing.T) {
	subject := &networkingv1.Ingress{}
	scheme := common.NewSchemeWithDefault(t)
	ingress := common.DecodeWithSchema(t, basePath+ingressPath, subject, scheme).(*networkingv1.Ingress)
	assert.Equal(t, "keycloakx-auth-rewrite", ingress.Name)
}
