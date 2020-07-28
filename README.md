# NGINX Ingress Controller 

## Overview
Built around the Kubernetes Ingress resource that uses ConfigMap to store the NGINX configuration.

#### Docs
https://kubernetes.github.io/ingress-nginx/

https://kubernetes.github.io/ingress-nginx/how-it-works/


#### Configuration
https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/annotations.md


## Building and Deploying 
- `./build`
- `./apply`


- Validate all the components that ingress-nginx deploys into the ingress-nginx namespace:
```console
kubectl get all -n ingress-nginx
NAME                                            READY   STATUS    RESTARTS   AGE
pod/nginx-ingress-controller-748cd7b559-rgk5p   1/1     Running   0          100m

NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)                      AGE
service/ingress-nginx   LoadBalancer   172.20.34.160   your-hex-aws-external-ip-address-goes-here-1492918777.us-west-2.elb.amazonaws.com   80:31487/TCP,443:30073/TCP   100m

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-ingress-controller   1/1     1            1           100m

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-ingress-controller-748cd7b559   1         1         1       100m
```

- Notes: 
  - The service must get and publish its external-ip address--for AWS it should look like this:
  ```console
  kubectl get service/ingress-nginx -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
  your-hex-aws-external-ip-address-goes-here-1492918777.us-west-2.elb.amazonaws.com
  ```
  - This can sometimes take up to 15 minutes when AWS backend queues are high.

## Testing and Validation Ingress with a Demo Service
We also Deploy a kuard demo service configuted to terminate L7 TLS at the AWS ELB using the below kuard kube manifest files.

You can get the address of your NLB via--if you don't see the status as shown below either more time is needed on AWS backend or there is an error--see the EKS cluster's control-plane logs <https://us-west-2.console.aws.amazon.com/cloudwatch/home?region=us-west-2#logs:> for further troubleshooting.:

```console
k logs -f deployment.apps/nginx-ingress-controller -n ingress-nginx | grep $service
```

```console
kubectl get ing/kuard -n kuard -o yaml | grep -A 5 'status'
status:
  loadBalancer:
    ingress:
    - hostname: your-hex-aws-external-ip-address-goes-here-1492918777.us-west-2.elb.amazonaws.com
```

Our Kuard demo TLS service deploys the following components for kuard to the current kube cluster (per your KUBECONFIG ENV variable).
* kind: Namespace
* kind: Deployment
* kind: Service
* kind: Ingress

- Note it also configures requisite Route53 resource records for our kuard.dev.terradatum service due to our annotations in the Ingress manifest in the above noted manifest file.

#### Validate that External-DNS creates requisite A/ALIAS and TXT records for demo service.
```console
export HOST=kuard.dev.mycompany.com ; aws route53 list-resource-record-sets --hosted-zone-id Z3L41146DZNXKA | grep -A 5 $HOST | egrep "(Value|Name)"
            "Name": "kuard.dev.mycompany.com.",
                "DNSName": "your-hex-aws-external-ip-address-goes-here-1492918777.us-west-2.elb.amazonaws.com.",
            "Name": "kuard.dev.mycompany.com.",
                    "Value": "\"heritage=external-dns,external-dns/owner=Z3L41146DZNXKA,external-dns/resource=ingress/kuard/kuard\""
```

#### Test with curl or browser
```console
curl https://kuard.dev.mycompany.com | grep 'Demo'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1754  100  1754    0     0   8323      0 --:--:-- --:--:-- --:--:--  8312
  <title>KUAR Demo</title>
```

```console
open https://kuard.dev.mycompany.com
```
