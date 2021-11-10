package common

import (
	"testing"

	"github.com/stretchr/testify/assert"
	networkingv1 "k8s.io/api/networking/v1"
)

var (
	ingressPath = "/01_keycloak_helmchart/keycloak/templates/ingress.yaml"
)

func IngressApiVersionTest(t *testing.T, basepath string) {
	subject := &networkingv1.Ingress{}
	scheme := NewSchemeWithDefault(t)
	ingress := DecodeWithSchema(t, basepath+ingressPath, subject,scheme).(*networkingv1.Ingress)
	assert.Equal(t, "keycloak", ingress.Name)
}
