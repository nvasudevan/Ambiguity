module HillClimbConfig
	CFACTOR=0.1
	NO_NODES_FACTOR=0.00001
	# options: ratio, prod_count
	WEIGHTED_FUNCTION="ratio"
	# length, productions_touched, consecutive_touch
	FITNESS_TYPE="consecutive_touch"
	# options: time [mins], memory [KB]
	TERMINATE_BY="memory"
        K_CONSECUTIVE_TOUCH=2
	MAX_TIME=30
	MAX_MEMLIMIT=1048576
	MAX_DEPTH=4000
end
