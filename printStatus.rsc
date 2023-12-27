:global trafficData
:global EpochTime
:global CalcRate
:global kidControlStreaming

:if ([:typeof $trafficData] != "array") do={
  :global trafficData [:toarray ""]
}

:local streamingDataRangeStart [$CalcRate ($kidControlStreaming->"streamingDataRangeLower")]
:local streamingDataRangeEnd [$CalcRate ($kidControlStreaming->"streamingDataRangeUpper")]

:foreach i in=[/ip kid-control find disabled=no] do={
  :local userName [/ip kid-control get $i name]
  :local prevData [($trafficData->"$userName")]

  :if ([:typeof $prevData] = "str") do={
    :local bytesPerSec [:tonum [:pick $prevData ([:find $prevData "<rate>"] + 6) [:find $prevData "</rate>"]]]
    :local bitsPerSec ($bytesPerSec * 8)
    :local choke [:tonum [:pick $prevData ([:find $prevData "<choke>"] + 7) [:find $prevData "</choke>"]]]
    :local streamingStart [:tonum [:pick $prevData ([:find $prevData "<streamingStart>"] + 16) [:find $prevData "</streamingStart>"]]]
    :local ts [$EpochTime]

    :put "User: $userName, bytesPerSec: $bytesPerSec, choke: $choke"
    
    :local streamingDataRangeStart [$CalcRate ($kidControlStreaming->"streamingDataRangeLower")]
    :local streamingDataRangeEnd [$CalcRate ($kidControlStreaming->"streamingDataRangeUpper")]
    :if (($bitsPerSec >= $streamingDataRangeStart) && ($bitsPerSec <= $streamingDataRangeEnd)) do={
      :local since ($ts - $streamingStart)
      :if ($streamingStart = 0) do={
        :set since "now"
      }
      :put " streaming since $since seconds"
    }
    :if ($choke > 0) do={
      :local chokeTime ($choke - $ts)
      :put " choked for $chokeTime seconds"
    }
  }
}
