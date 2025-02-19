# About this sample

This sample shows is meant to be used only as a way of getting to know the SnapCd "bootstrap" deployment. It includes various secrets and credentials that have been hardcoded and is therefore not production-ready! 

# Prerequisites

You will need the following tools to deploy this sample:

- Kustomize (https://github.com/kubernetes-sigs/kustomize)
- Kubectl (https://kubernetes.io/docs/tasks/tools/)

# Prerequisites TL;DR

```bash
KUSTOMIZE_VER=5.0.0
wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VER}/kustomize_v${KUSTOMIZE_VER}_linux_amd64.tar.gz
tar xzf kustomize_v${KUSTOMIZE_VER}_linux_amd64.tar.gz
sudo mv kustomize /usr/local/bin/
chmod +x /usr/local/bin/kustomize

KUBECTL_VERSION=v1.25.5
curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

# Configure `.env` files

Configure all of the `.env` inputs in `./configs` and in `./secrets`.

# Configure `OpenIdConnect__TokenEncryption__SymmetricKey`

The token-encryption symmetric key plays an important role in securing token-based authentication against your Snap CD server instance. Any tokens that your instance generates will be encrypted with this key (and again decrypted when the server is presented with the token). You can use the following script to generate it:

```bash
SYMMETRIC_KEY=$(openssl rand -base64 32)
PEM_KEY="-----BEGIN SYMMETRIC KEY-----\n$SYMMETRIC_KEY\n-----END SYMMETRIC KEY-----"
echo -e "$PEM_KEY" > secrets/OpenIdConnect__TokenEncryption__SymmetricKey
```

# Configure `OpenIdConnect__TokenSigning__RsaPrivateKey` and `OpenIdConnect__TokenSigning__RsaPublicKey`

The token-signing RSA private key will be used by the Snap CD Server to sign access tokens (before they are encrypted) and the private key will be used to validate the origin of the key. You can generate them as follows

```bash
PRIVATE_KEY_PATH="./secrets/OpenIdConnect__TokenSigning__RsaPrivateKey"
PUBLIC_KEY_PATH="./configs/OpenIdConnect__TokenSigning__RsaPublicKey"
openssl genpkey -algorithm RSA -out "$PRIVATE_KEY_PATH" -pkeyopt rsa_keygen_bits:1024
openssl rsa -pubout -in "$PRIVATE_KEY_PATH" -out "$PUBLIC_KEY_PATH"
```

# Deploy

```bash
kustomize build . | kubectl apply -f -
```

# Remove

```bash
kustomize build . | kubectl delete -f -
```