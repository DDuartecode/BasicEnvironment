#!/bin/bash

SCRIPT_PATH=$(dirname "$0")

source "$SCRIPT_PATH/variables.sh"

RETURN=0

#clonar os projetos aqui
git clone https://github.com/DDuartecode/Authenticator.git ../Authenticator
git clone https://github.com/DDuartecode/OrderProcessor.git ../OrderProcessor
git clone https://github.com/DDuartecode/OrderGenerator.git ../OrderGenerator

#iniciar banco autenticação
init_auth_db_container()
{
    $DOCKER_CMD up $DB_AUTH_HOST -d
}

#configurar banco de autenticação
config_auth_db()
{
    echo "Aguardando o PostgreSQL do AUTENTICADOR aceitar conexões..."

    # Aguarda até o Postgres aceitar conexões
    until $DOCKER_CMD exec "$DB_AUTH_HOST" pg_isready -U "$DB_USER" > /dev/null 2>&1; do
    echo "Postgres ainda não está pronto... aguardando"
    sleep 1
    done

    echo "Postgres está pronto! Executando comandos..."

    $DOCKER_CMD exec $DB_AUTH_HOST psql -U $DB_USER -c "CREATE USER $DB_AUTH_USER WITH PASSWORD '$DB_AUTH_PASS';"
    $DOCKER_CMD exec $DB_AUTH_HOST psql -U $DB_USER -c "CREATE DATABASE $DB_AUTH_NAME;"
    $DOCKER_CMD exec $DB_AUTH_HOST psql -U $DB_USER -c "GRANT ALL PRIVILEGES ON DATABASE $DB_AUTH_NAME TO $DB_AUTH_USER;"
    $DOCKER_CMD exec $DB_AUTH_HOST psql -U $DB_USER -d $DB_AUTH_NAME -c "GRANT USAGE, CREATE ON SCHEMA public TO $DB_AUTH_USER;"
}

#iniciar banco api
init_order_db_container()
{
    $DOCKER_CMD up $DB_ORDER_HOST -d
}

#configurar banco da api
config_order_db()
{
    echo "Aguardando o PostgreSQL da API aceitar conexões..."

    # Aguarda até o Postgres aceitar conexões
    until $DOCKER_CMD exec "$DB_ORDER_HOST" pg_isready -U "$DB_USER" > /dev/null 2>&1; do
    echo "Postgres ainda não está pronto... aguardando"
    sleep 1
    done

    echo "Postgres está pronto! Executando comandos..."

    $DOCKER_CMD exec $DB_ORDER_HOST psql -U $DB_USER -c "CREATE USER $DB_ORDER_USER WITH PASSWORD '$DB_ORDER_PASS';"
    $DOCKER_CMD exec $DB_ORDER_HOST psql -U $DB_USER -c "CREATE DATABASE $DB_ORDER_NAME;"
    $DOCKER_CMD exec $DB_ORDER_HOST psql -U $DB_USER -c "GRANT ALL PRIVILEGES ON DATABASE $DB_ORDER_NAME TO $DB_ORDER_USER;"
    $DOCKER_CMD exec $DB_ORDER_HOST psql -U $DB_USER -d $DB_ORDER_NAME -c "GRANT USAGE, CREATE ON SCHEMA public TO $DB_ORDER_USER;"
}

#inicia api autenticador
init_auth_api_container()
{
    $DOCKER_CMD up $AUTH_API_HOST --build -d
}

#configurar api autenticador
config_auth_api()
{
    echo "Executando composer install..."
    $DOCKER_CMD exec $AUTH_API_HOST composer install --working-dir=/app/AuthenticatorApi

    echo "Instalando Passport..."
    $DOCKER_CMD exec $AUTH_API_HOST php /app/AuthenticatorApi/artisan passport:install #não rodar as migration quando pedir

    # echo "Rodando migrations..."
    # $DOCKER_CMD exec $AUTH_API_HOST php /app/AuthenticatorApi/artisan migrate --force

    echo "Criando personal acess..."
    $DOCKER_CMD exec $AUTH_API_HOST php /app/AuthenticatorApi/artisan passport:client --personal --no-interaction
    $DOCKER_CMD exec $AUTH_API_HOST php /app/AuthenticatorApi/artisan passport:client --password --no-interaction

    echo "Rodando o seed inicial..."
    $DOCKER_CMD exec $AUTH_API_HOST php /app/AuthenticatorApi/artisan db:seed #necessário alterar caso seja um seed específico

    echo "Limpando cache..."
    $DOCKER_CMD exec $AUTH_API_HOST php /app/AuthenticatorApi/artisan cache:clear

    echo "Limpando configs..."
    $DOCKER_CMD exec $AUTH_API_HOST php /app/AuthenticatorApi/artisan config:clear
}

#inicia api de pedidos
init_order_api_container()
{
    $DOCKER_CMD up $ORDER_API_HOST --build -d
}

#configurar api de pedidos
config_order_api()
{
    echo "Executando composer install..."
    $DOCKER_CMD exec $ORDER_API_HOST composer install --working-dir=/app/OrderProcessorApi

    echo "Rodando migrations..."
    $DOCKER_CMD exec $ORDER_API_HOST php /app/OrderProcessorApi/artisan migrate --force

    echo "Rodando o seed inicial..."
    $DOCKER_CMD exec $ORDER_API_HOST php /app/OrderProcessorApi/artisan db:seed #necessário alterar caso seja um seed específico

    echo "Limpando cache..."
    $DOCKER_CMD exec $ORDER_API_HOST php /app/OrderProcessorApi/artisan cache:clear

    echo "Limpando configs..."
    $DOCKER_CMD exec $ORDER_API_HOST php /app/OrderProcessorApi/artisan config:clear
}

#inicia processador de pedidos
init_order_processor_container()
{
    $DOCKER_CMD up $ORDER_API_HOST --build -d
}

#inicia o gerador de pedidos
ini_order_generator_container()
{
    $DOCKER_CMD up $ORDER_ORDER_GENERATOR_HOST --build -d
}

#inicia fila
init_rabbitmq_container()
{
    $DOCKER_CMD up $RABBITMQ_HOST --build -d
}

init_auth_db_container
init_order_db_container
init_auth_api_container
init_order_api_container
init_order_processor_container
ini_order_generator_container
init_rabbitmq_container

config_auth_db
config_order_db
config_auth_api
config_order_api

exit $RETURN