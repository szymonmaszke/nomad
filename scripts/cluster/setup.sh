#!/usr/bin/env sh

POD="${1:-cluster}"

##################################################################################
#
#				VAULT
#
##################################################################################

VAULT_ADDRESS="${2:-http://127.0.0.1:8200}"

VAULT_POLICIES_DIR="${3:-/home/main/apps/vault/policies}"
VAULT_POLICY_FILE="${4:-nomad-server-policy.hcl}"
VAULT_ROLES_DIR="${5:-/home/main/apps/vault/roles}"
VAULT_ROLE_FILE="${6:-nomad-role.json}"

VAULT_POLICY_NAME="${7:-nomad-server}"
VAULT_ROLE_NAME="${8:-/auth/token/roles/nomad}"

VAULT_RENEWAL_PERIOD="${9:-1h}"

until podman healthcheck run vault >/dev/null 2>&1
do 
	:
done

VAULT_TOKEN=$(/home/main/apps/vault/scripts/cluster/setup.sh \
	"${POD}" \
	"${VAULT_ADDRESS}" \
	"${VAULT_POLICIES_DIR}" \
	"${VAULT_POLICY_FILE}" \
	"${VAULT_ROLES_DIR}" \
	"${VAULT_ROLES_FILE}" \
	"${VAULT_POLICY_NAME}" \
	"${VAULT_ROLE_NAME}" \
	"${VAULT_RENEWAL_PERIOD}" \
)

##################################################################################
#
#				CONSUL
#
##################################################################################

CONSUL_ADDRESS="${3:-http://127.0.0.1:8500}"

CONSUL_POLICY_FILE="${3:-nomad-server.hcl}"
CONSUL_POLICY_NAME="${3:-nomad-server}"
CONSUL_POLICY_DESCRIPTION="${3:-Nomad server policy}"
CONSUL_POLICY_DIR="${3:-/home/main/apps/consul/data/policies}"

CONSUL_TOKEN=$(/home/main/apps/consul/scripts/cluster/setup.sh \
	"${POD}" \
	"${CONSUL_ADDRESS}" \
	"${CONSUL_POLICY_FILE}" \
	"${CONSUL_POLICY_NAME}" \
	"${CONSUL_POLICY_DESCRIPTION}" \
	"${CONSUL_POLICY_DIR}" \
)



##################################################################################
#
#				NOMAD
#
##################################################################################

/home/main/apps/nomad/scripts/run.sh "${VAULT_TOKEN}" "${CONSUL_TOKEN}"
