helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm template istiod istio/istiod --version "1.22.0" --namespace istio-system --values values.yaml > generated.yaml