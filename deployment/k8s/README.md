
# OBS Cloud Kubernetes Deployment

`kubectl apply -k https://github.com/michael-riha/obs-studio-containerd.git//deployment/k8s?ref=feat/e2e`

## Debug networking:

`kubectl exec -it dnsutils -n obs-cloud -- nslookup novnc`
