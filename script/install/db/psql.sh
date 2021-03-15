#!/usr/bin/env bash

# constant
PROJECT_ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../../.. >/dev/null 2>&1 && pwd)"
CURRENT_DIR=$(dirname "$0")
POSTGRES_K8S_BASENAME="psql-cluster" && export POSTGRES_K8S_BASENAME
POSTGRES_K8S_SERVICE="${POSTGRES_K8S_BASENAME}-postgresql" && export POSTGRES_K8S_SERVICE
SERVICE_CONFIG_FILENAME="minikube-psql"
SERVICE_CONFIG_TEMPLATE_LOCATION="${CURRENT_DIR}/${SERVICE_CONFIG_FILENAME}-template.service"
SERVICE_CONFIG_LOCATION="${CURRENT_DIR}/${SERVICE_CONFIG_FILENAME}.service"

# dependencies
. "${PROJECT_ROOT_PATH}/script/common.sh"

echo_info "Running $(basename "$0")"
# install
if ! kubectl get service "${POSTGRES_K8S_SERVICE}" &>/dev/null; then
  echo_debug "Installing PostgreSQL..."
  echo_debug "If helm version<3.1, use => helm install ${POSTGRES_K8S_BASENAME} bitnami/postgresql --version 10.2.2"
  echo_debug "If helm version>3.1, use => helm install ${POSTGRES_K8S_BASENAME} bitnami/postgresql"

  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm install ${POSTGRES_K8S_BASENAME} bitnami/postgresql --version 10.2.2

  echo_debug "Installing PostgreSQL as service..."
  envsubst <"${SERVICE_CONFIG_TEMPLATE_LOCATION}" >"${SERVICE_CONFIG_LOCATION}"
  sudo cp "${SERVICE_CONFIG_LOCATION}" /etc/systemd/system/
  rm "${SERVICE_CONFIG_LOCATION}"
  sudo systemctl daemon-reload
  sudo systemctl enable ${SERVICE_CONFIG_FILENAME}.service
  sudo systemctl start ${SERVICE_CONFIG_FILENAME}.service
fi

# output result
POSTGRES_PASSWORD="$(kubectl get secret --namespace default ${POSTGRES_K8S_SERVICE} -o jsonpath="{.data.postgresql-password}" | base64 --decode)"
cat <<EOF >"${PROJECT_ROOT_PATH}/config/db/psql.properties"
url=jdbc:postgresql://localhost:5432/postgres
username=postgres
password=${POSTGRES_PASSWORD}
EOF
