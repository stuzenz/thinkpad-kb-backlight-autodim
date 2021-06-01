#!/bin/bash
# Read the backlight state from before the idle
# If the backlight state before idle was not 0 
# it will set it back to what the state was
VAR="$(cat ~/.backlight_state)"
if  [[ $VAR -gt 0 ]]
then
  echo $VAR | tee /sys/class/leds/tpacpi::kbd_backlight/brightness
fi
