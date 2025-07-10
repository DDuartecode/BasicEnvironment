#!/bin/bash

DOCKER_CMD="docker compose"


DB_USER="postgres"
DB_PASS="senha"
DB_PORT="5432"
DB_NAME="postgres"

DB_AUTH_HOST="postgres-auth"
DB_AUTH_USER="auth"
DB_AUTH_PASS="authpass"
DB_AUTH_NAME="auth_db"

DB_ORDER_HOST="postgres-order"
DB_ORDER_USER="uorder"
DB_ORDER_PASS="uorderpass"
DB_ORDER_NAME="order_db"

AUTH_API_HOST="authenticator-api"
ORDER_API_HOST="order-api"
ORDER_PROCESSOR_HOST="order-processor"
ORDER_GENERATOR_HOST="order-generator"
RABBITMQ_HOST="rabiitmq"