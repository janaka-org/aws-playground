Lens IDE is pretty good to get visibility in to what's running on an K8s cluster including system services for EKS.

Get kubeconfig for Lens IDE etc 

`aws eks --region us-west-2 update-kubeconfig --name janaka-experiments --profile janakapersonal`


For Fargate run this command to patch coreDNS. Otherwise the pods don't start up.
ref https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html

`kubectl patch deployment coredns -n kube-system --type json -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'`