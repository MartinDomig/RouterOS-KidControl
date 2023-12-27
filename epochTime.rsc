# This script was originally posted by user minks on the MikroTik forum, and updated by user Jotne.
# https://forum.mikrotik.com/viewtopic.php?t=75555
#
# Usage:
# :put [$EpochTime] (returns current epoch time)
# :put [$EpochTime "may/01 16:23:50"]
# :put [$EpochTime "15:23:50"]

:global EpochTime do={
	# Usage
	# $EpochTime [time input]
	# -----
	# Get current time
	# :put [$EpochTime]
	# 
	# Read log time in one of these two format "may/01 16:23:50" or "12:02:23" for log number *323
	# :put [$EpochTime [:log get *323 time]]

	:local ds
	:local ts
	:if ([:len $1]=0) do={
		# Get "now time"
		:set ds [/system clock get date]
		:set ts [/system clock get time]
	} else={
	
		if ([:len $1]>8) do={
			# Use remote date and time and convert date
			:set ds "$[:pick $1 0 6]/$[:pick [/system clock get date] 7 11]"
			:set ts [:pick $1 7 15]
		} else={
			# Use remote time and get date
			:set ds [/system clock get date]
			:set ts $1
		}
	}
	:local months
	:if ((([:pick $ds 9 11]-1)/4) != (([:pick $ds 9 11])/4)) do={

		:set months {"an"=0;"eb"=31;"ar"=60;"pr"=91;"ay"=121;"un"=152;"ul"=182;"ug"=213;"ep"=244;"ct"=274;"ov"=305;"ec"=335}
	} else={
		:set months {"an"=0;"eb"=31;"ar"=59;"pr"=90;"ay"=120;"un"=151;"ul"=181;"ug"=212;"ep"=243;"ct"=273;"ov"=304;"ec"=334}
	}
	:set ds (([:pick $ds 9 11]*365)+(([:pick $ds 9 11]-1)/4)+($months->[:pick $ds 1 3])+[:pick $ds 4 6])
	:set ts (([:pick $ts 0 2]*60*60)+([:pick $ts 3 5]*60)+[:pick $ts 6 8])
	:return ($ds*24*60*60 + $ts + 946684800 - [/system clock get gmt-offset])
}
