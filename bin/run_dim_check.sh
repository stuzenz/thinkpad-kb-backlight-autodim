#!/bin/bash
# checks the current state and turns off if the state is not already off
# also stores the current state in .backlight_state

VAR="$(cat /sys/class/leds/tpacpi::kbd_backlight/brightness)"
echo $VAR |tee ~/.backlight_state
if  [[ $VAR -gt 0 ]]
then
  echo 0 | tee /sys/class/leds/tpacpi::kbd_backlight/brightness
fi
