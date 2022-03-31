#!/usr/bin/env sh

run() {
	NOMAD_DATA_DIR=/home/main/apps/nomad/data

	# Mounts explained
	# --volume /lib/modules:/lib/modules:ro -> fingerprinting host
	# --volume "$XDG_RUNTIME_DIR"/podman:/run/podman -> podman socket
	# ^ Possible workaround would be PINP, creating new image altogether
	# Might be too troublesome

	podman container run \
		--cap-add=sys_admin \
		--pod cluster \
		--name=nomad \
		--rm \
		--volume /home/main/apps/nomad/config:/etc/nomad:ro \
		--volume "$NOMAD_DATA_DIR":"$NOMAD_DATA_DIR":z \
		--volume "$XDG_RUNTIME_DIR"/podman:/run/podman \
		--volume /tmp:/tmp \
		--volume /lib/modules:/lib/modules:ro \
		-e NOMAD_DISABLE_PERM_MGMT=true \
		-e VAULT_TOKEN="${1}" \
		-e CONSUL_HTTP_TOKEN="${2}" \
		-e "NOMAD_DATA_DIR=${NOMAD_DATA_DIR}" \
		ghcr.io/szymonmaszke/nomad:latest agent -dev

}

run "$1" "$2"
