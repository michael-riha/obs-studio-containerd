
# OBS Cloud Kubernetes Deployment

`kubectl apply -k https://github.com/michael-riha/obs-studio-containerd.git//deployment/k8s?ref=feat/e2e`

`kubectl get all -n obs-cloud`
`kubectl port-forward --address 0.0.0.0 svc/novnc -n obs-cloud 8088:8080`

## Debug networking:

`kubectl logs svc/novnc -n obs-cloud -f`
`kubectl exec -it dnsutils -n obs-cloud -- nslookup novnc`

`kubectl logs deployment.apps/obs-builder -n obs-cloud -f`
`kubectl exec --stdin --tty pod/obs-builder-6db6858c79-gzhbc -n obs-cloud -- /bin/bash`