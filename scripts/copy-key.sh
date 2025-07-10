#!/bin/bash
set -e

DOCKER_CMD="docker compose"

#local dentro do container
SOURCE_DIR="AuthenticatorApi/storage"
#local na raiz do projeto
LOCAL_SOURCE_DIR="../Authenticator/AuthenticatorApi/storage"

PUBLIC_KEY_NAME="oauth-public.key"

PUBLIC_KEY="$SOURCE_DIR/$PUBLIC_KEY_NAME"

DEST_DIR="./Keys"

# Cria o diretório de destino se não existir
mkdir -p "$DEST_DIR"

$DOCKER_CMD up -d

# Altera permissão dentro do container
$DOCKER_CMD exec authenticator-api chmod 644 $PUBLIC_KEY

# Copia a chave pública
cp -r "$LOCAL_SOURCE_DIR/$PUBLIC_KEY_NAME" "$DEST_DIR/"

$DOCKER_CMD exec authenticator-api chmod 600 $PUBLIC_KEY

chmod 644 "$DEST_DIR/$PUBLIC_KEY_NAME"

mkdir -p "../OrderGenerator/OrderGeneratorApi/oauth/keys"
cp -r "$DEST_DIR/$PUBLIC_KEY_NAME" "../OrderGenerator/OrderGeneratorApi/oauth/keys"
cp -r "$DEST_DIR/$PUBLIC_KEY_NAME" "../OrderProcessor/OrderProcessorApi/storage"

$DOCKER_CMD down

$DOCKER_CMD up -d

echo "Chave copiada para $DEST_DIR com sucesso."
