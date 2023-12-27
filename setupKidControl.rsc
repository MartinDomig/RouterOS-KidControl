:global kidControlStreaming
:set $kidControlStreaming [:toarray ""]

# Queue limit for normal and choked usage.
# First number is the limit for normal usage, second number is the limit for choked usage.
# The first number must not be 0.
:set ($kidControlStreaming->"queueLimitNormal") 10M
:set ($kidControlStreaming->"queueLimitChoked") 32k

# The list of users for which streaming should be limited.
:set ($kidControlStreaming->"noStreamUsers")  "Bart,Lisa,Maggie"

# If bandwidth usage remains in this range for a while, we suspect streaming.
# The first number is the lower limit, second number is the upper limit.
:set ($kidControlStreaming->"streamingDataRangeLower") 200k
:set ($kidControlStreaming->"streamingDataRangeUpper") 2800k

# Number of seconds to wait before we consider the user to be streaming
:set ($kidControlStreaming->"streamingGraceTime") 300

# Number of minutes to choke a streamer
:set ($kidControlStreaming->"chokeSeconds") 300

/system script run epochTime
/system script run calcRate
/system script run checkConfig

/system scheduler
add interval=1m name=checkConfig on-event="/system script run checkConfig" start-time=startup
add interval=1m name=limitStreaming on-event="/system script run limitStreaming" start-time=startup
