# Setting up falco
kubectl create ns falco 

helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
helm upgrade --install falco falcosecurity/falco --namespace falco \
--set falcosidekick.enabled=true \
--set falcosidekick.webui.enabled=true \
--set auditLog.enabled=true \
--set falcosidekick.webui.redis.storageClass="nfs-client" \
-f rules/rules.yaml

# Setting up fluent bit
kubectl create namespace logging
kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-openshift-security-context-constraints.yaml
helm upgrade --install fluent-bit fluent/fluent-bit \
        -f values-override.yaml \
        -n logging

# test
export POD_NAME=$(kubectl get pods --namespace logging -l "app.kubernetes.io/name=fluent-bit,app.kubernetes.io/instance=fluent-bit" -o jsonpath="{.items[0].metadata.name}")
echo "curl http://127.0.0.1:2020 for Fluent Bit build information"
kubectl --namespace logging port-forward $POD_NAME 2020:2020


