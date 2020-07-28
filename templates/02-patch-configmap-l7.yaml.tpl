# https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.28.0/deploy/static/provider/aws/patch-configmap-l7.yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-configuration
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
data:
  use-proxy-protocol: "false"
  use-forwarded-headers: "true"
  proxy-real-ip-cidr: "0.0.0.0/0" # restrict this to the IP addresses of ELB
---
