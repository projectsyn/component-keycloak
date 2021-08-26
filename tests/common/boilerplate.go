package common

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/serializer"
	clientgoscheme "k8s.io/client-go/kubernetes/scheme"
)

func DecodeStatefulsetV1(t *testing.T, path string) *appsv1.StatefulSet {
	subject := &appsv1.StatefulSet{}
	scheme := NewSchemeWithDefault(t)
	require.NoError(t, appsv1.AddToScheme(scheme))
	return DecodeWithSchema(t, path, subject, scheme).(*appsv1.StatefulSet)
}

func DecodeSecret(t *testing.T, path string) *corev1.Secret {
	subject := &corev1.Secret{}
	scheme := NewSchemeWithDefault(t)
	require.NoError(t, corev1.AddToScheme(scheme))
	return DecodeWithSchema(t, path, subject, scheme).(*corev1.Secret)
}

func DecodeWithSchema(t *testing.T, path string, into runtime.Object, schema *runtime.Scheme) runtime.Object {
	data, err := ioutil.ReadFile(path)
	require.NoError(t, err)
	kind := into.GetObjectKind().GroupVersionKind()
	decode, _, err := serializer.NewCodecFactory(schema).UniversalDeserializer().Decode(data, &kind, into)
	require.NoError(t, err)
	return decode
}

func NewSchemeWithDefault(t *testing.T) *runtime.Scheme {
	scheme := runtime.NewScheme()
	require.NoError(t, clientgoscheme.AddToScheme(scheme))
	return scheme
}

func ScanFiles(path string) (files []string, retErr error) {
	err := filepath.Walk(path, func(path string, info os.FileInfo, err error) error {
		if info.IsDir() {
			return nil
		}
		if strings.HasSuffix(info.Name(), ".yaml") {
			files = append(files, path)
		}
		return nil
	})
	return files, err
}

