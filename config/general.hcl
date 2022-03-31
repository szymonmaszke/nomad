bind_addr = "127.0.0.1"

data_dir = "/home/main/apps/nomad/data"
plugin_dir = "/nomad/plugins"

disable_update_check = true

limits {
	# Limit possible open connections by attacker
	https_handshake_timeout = "1s"
	rpc_handshake_timeout = "1s"
}
