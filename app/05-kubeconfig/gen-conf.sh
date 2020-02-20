#!/bin/sh

KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe my-kubernetes-cluster \
  --region $GCLOUD_REGION \
  --format 'value(address)')
echo "Kubernetes public address: ${KUBERNETES_PUBLIC_ADDRESS}"

for instance in worker-0 worker-1 worker-2; do
  echo "Generating ${instance} config..."
  kubectl config set-cluster my-kubernetes-cluster \
    --certificate-authority=../certs/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=../certs/${instance}.pem \
    --client-key=../certs/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=my-kubernetes-cluster \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig

  if [ ! -f ${instance}.kubeconfig ]; then
    echo "Error creating ${instance} kube config"
    exit -1
  fi
done

echo "Generating kube-proxy config..."
kubectl config set-cluster my-kubernetes-cluster \
  --certificate-authority=../certs/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=../certs/kube-proxy.pem \
  --client-key=../certs/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=my-kubernetes-cluster \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

if [ ! -f kube-proxy.kubeconfig ]; then
    echo "Error creating kube-proxy kube config"
    exit -1
fi

echo "Generating kube-controller-manager config..."
kubectl config set-cluster my-kubernetes-cluster \
  --certificate-authority=../certs/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials kube-controller-manager \
  --client-certificate=../certs/kube-controller-manager.pem \
  --client-key=../certs/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=my-kubernetes-cluster \
  --user=kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig

if [ ! -f kube-controller-manager.kubeconfig ]; then
    echo "Error creating kube-controller-manager kube config"
    exit -1
fi

echo "Generating kube-scheduler config..."
kubectl config set-cluster my-kubernetes-cluster \
  --certificate-authority=../certs/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-credentials kube-scheduler \
  --client-certificate=../certs/kube-scheduler.pem \
  --client-key=../certs/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=my-kubernetes-cluster \
  --user=kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig

if [ ! -f kube-scheduler.kubeconfig ]; then
    echo "Error creating kube-scheduler kube config"
    exit -1
fi

echo "Generating admin config..."
kubectl config set-cluster my-kubernetes-cluster \
  --certificate-authority=../certs/ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=../certs/admin.pem \
  --client-key=../certs/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=admin.kubeconfig

kubectl config set-context default \
  --cluster=my-kubernetes-cluster \
  --user=admin \
  --kubeconfig=admin.kubeconfig

kubectl config use-context default --kubeconfig=admin.kubeconfig

if [ ! -f admin.kubeconfig ]; then
    echo "Error creating admin kube config"
    exit -1
fi
