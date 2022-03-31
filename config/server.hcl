server {
	enabled = true
	# how many server nodes up and running necessary
	bootstrap_expect = 1

	# Kafka like, events like starting job
	enable_event_broker = false

	# garbage collection (different defaults)
	node_gc_threshold = "72h"
	job_gc_interval = "1m"
	job_gc_threshold = "1m"
	eval_gc_threshold = "1m"
	deployment_gc_threshold = "1m"
	csi_volume_claim_gc_threshold = "1m"
	csi_plugin_gc_threshold = "1m"

	# hearbeat almost off (as a single node is used)
	min_heartbeat_ttl = "72h"
	max_heartbeats_per_second = 1
	
	# number of cores used for scheduling
	num_schedulers = 1

	# allows apps to use more memory than specified if available
	default_scheduler_config {
		memory_oversubscription_enabled = true
	}
}
