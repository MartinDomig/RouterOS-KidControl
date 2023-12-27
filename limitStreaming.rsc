:global EpochTime
:global CalcRate
:global kidControlStreaming

:global trafficData
:if ([:typeof $trafficData] != "array") do={
  :global trafficData [:toarray ""]
}

:foreach i in=[/ip kid-control find disabled=no] do={
  :local userName [/ip kid-control get $i name]

  :if ([/queue simple find name=$userName] != "") do={
    :put "USER $userName --------v"

    :local bytes [/queue simple get [find name=$userName] bytes]
    :local bytesDown [:pick $bytes 0 [:find $bytes "/"]]
    :local bytesUp [:pick $bytes ([:find $bytes "/"] + 1) [:len $bytes]]
    :local bytesTotal ([:tonum $bytesDown] + [:tonum $bytesUp])

    :local ts [$EpochTime]
    :local choke 0
    :local streamingStart 0
    :local bytesPerSec 0

    :local prevData [($trafficData->"$userName")]
    :if ([typeof $prevData] = "str") do={
      :local prevTs [:tonum [:pick $prevData ([:find $prevData "<ts>"] + 4) [:find $prevData "</ts>"]]]
      :local prevBytesTotal [:tonum [:pick $prevData ([:find $prevData "<total>"] + 7) [:find $prevData "</total>"]]]
      :local prevBytesPerSec [:tonum [:pick $prevData ([:find $prevData "<rate>"] + 6) [:find $prevData "</rate>"]]]
      :set choke [:tonum [:pick $prevData ([:find $prevData "<choke>"] + 7) [:find $prevData "</choke>"]]]
      :set streamingStart [:tonum [:pick $prevData ([:find $prevData "<streamingStart>"] + 16) [:find $prevData "</streamingStart>"]]]

      :local bytesDiff ($bytesTotal - $prevBytesTotal)
      :local tsDiff ($ts - $prevTs)
      :if ($tsDiff <= 0) do={
        :set tsDiff 1
      }
      :set bytesPerSec ($bytesDiff / $tsDiff)
      :set bytesPerSec (($prevBytesPerSec * 4 + $bytesPerSec) / 5)
      :if ($bytesPerSec < 0) do={
        :set bytesPerSec 0
      }
      :if ($bytesPerSec > 1000000000) do={
        :set bytesPerSec 0
      }
      :local bitsPerSec ($bytesPerSec * 8)

      :put "  Stats: $bytesPerSec bytes/sec ($bitsPerSec bits/sec)"

      :if ($choke > 0) do={
        :local chokeDiff ($choke - $ts)
        :put "  is choked for $chokeDiff more seconds"
        :if ($chokeDiff <= 0) do={
          :put "  is no longer choked"
          :local queueLimitNormal ($kidControlStreaming->"queueLimitNormal")
          /queue simple set [find name=$userName] max-limit="$queueLimitNormal/$queueLimitNormal"

          :log info "KidControl: $userName is no longer choked"
          :set choke 0
          :set streamingStart 0
        }

      } else={

        # if bitsPerSec is within the streaming range, the user is currently streaming
        :local streamingDataRangeStart [:tonum [$CalcRate ($kidControlStreaming->"streamingDataRangeLower")]]
        :local streamingDataRangeEnd [:tonum [$CalcRate ($kidControlStreaming->"streamingDataRangeUpper")]]
        :if (($bitsPerSec >= $streamingDataRangeStart) && ($bitsPerSec <= $streamingDataRangeEnd)) do={
          :put "  is streaming"
          :if ($streamingStart = 0) do={
            :put "  started streaming just now ($bitsPerSec)"
            :set streamingStart $ts
          } else={
            :if ($streamingStart + ($kidControlStreaming->"streamingGraceTime") < $ts) do={
              :put "  has been streaming for too long ($bitsPerSec)"

              :if ([:find ($kidControlStreaming->"noStreamUsers") $userName] >= 0) do={
                :log info "KidControl: choking $userName"
                :set choke ($ts + ($kidControlStreaming->"chokeSeconds"))
                :put "  choke set to $choke, ts is $ts"
                :local queueLimitChoked ($kidControlStreaming->"queueLimitChoked")
                /queue simple set [find name=$userName] max-limit="$queueLimitChoked/$queueLimitChoked"
                :put "  choking user, limit is $queueLimitChoked"
              }
            }
          }
        } else={
          :set streamingStart 0
        }

      }
    }

    :set ($trafficData->"$userName") "<ts>$ts</ts><total>$bytesTotal</total><rate>$bytesPerSec</rate><choke>$choke</choke><streamingStart>$streamingStart</streamingStart>"
  }
}
