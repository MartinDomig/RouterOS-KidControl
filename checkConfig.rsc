# Test if kid control config changed
:global kidControl
:local kidControlNew [/ip kid-control print as-value]

:if ($kidControl != $kidControlNew) do={
  :put "Kid control config changed"
  :set kidControl $kidControlNew

  /system script run onKidControlUpdate
}
