:global CalcRate do={
	# Usage
	# $CalcRate [rate input]
	# Input must not be a decimal number.

	:local input $1

	# input is 1M or 10M or 128k or 512k
	# convert it to bytes

	:local rate 0
	:local unit [:pick $input ([:len $input] - 1) [:len $input]]
	:local value [:pick $input 0 ([:len $input] - 1)]

	:if ($unit = "M") do={
		:set rate ($value * 1000000)
	} else={
		:set rate ($value * 1000)
	}

	return [:tonum $rate]
}
