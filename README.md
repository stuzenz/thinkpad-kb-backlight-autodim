# Setting the keyboard backlight to turn off and on based on the idle trigger and a time delay

The below gives you an approach to set a timer to turn off the keyboard back light from when you have last touched the input devices (touchpad/keyboard/mouse). The keyboard back light will then return to its original state when coming out of idle mode.

This approach below works for thinkpads - I suspect this will work on non-Thinkpads too - with this line changed to whatever works for other products. 
`/sys/class/leds/tpacpi::kbd_backlight/brightness`

- I had to write in some logic to check kb backlight state and provide behaviour accordingly.
- I also had to work around some weird parse error when trying to run xidlehook from a systemd service

Five things needed to do this

1. Install xidlehook
1. Create a service that only changes the permission on the file `/sys/class/leds/tpacpi::kbd_backlight/brightness`
1. Create a `/home/[YOUR_HOME_DIRECTORY]/.config/autostart` file to execute the `xidlehook` command on boot and login
1. Create a script to run on idle and a cancel script to run when idle cancels in `/home/[YOUR_HOME_DIRECTORY]/bin`
1. Create a file to hold the original state of the kb-backlight `/home/[YOUR_HOME_DIRECTORY]/.backlight_state`

- Keep in mind when copying the scripts below that depending on the language and environment it can help reduce weird bugs to have a spare line at the end of each file.

Once you following the instructions you should have five new files as below (swap out my name for your home directory name)

-`/etc/systemd/system/brightness-kb-backlight-permission.service`
-`/home/[YOUR_HOME_DIRECTORY]/.config/autostart/kb_brightness.desktop`
-`/home/[YOUR_HOME_DIRECTORY]/bin/run_dim_check.sh`
-`/home/[YOUR_HOME_DIRECTORY]/bin/run_dim_check_cancel.sh`
-`/home/[YOUR_HOME_DIRECTORY]/.backlight_state`

## 1. Install xidlehook

​For archlinux

`paru -S xidlehook`

You can test it by trying this command 
`sudo xidlehook --timer 3 'echo 0 | tee /sys/class/leds/tpacpi::kbd_backlight/brightness' 'echo 1 | tee /sys/class/leds/tpacpi::kbd_backlight/brightness'`

​
## 2. Create a service that only changes the permission on the file `/sys/class/leds/tpacpi::kbd_backlight/brightness`

Linux resets the permission on this file on each reboot - so this gets the permission back to a permissions state where we can write to the file without needing sudo

Copy the script into
`/etc/systemd/system/brightness-kb-backlight-permission.service`

Once it is copied do the following to make sure the service is registered

```
➜ sudo systemctl daemon-reload

~ 
➜ sudo systemctl enable brightness-kb-backlight-permission.service

~ 
➜ sudo systemctl start brightness-kb-backlight-permission.service

~ 
➜ sudo systemctl status brightness-kb-backlight-permission.service
○ brightness-kb-backlight-permission.service - Change permission for kb backlight file for use without sudo with xidlehook
     Loaded: loaded (/etc/systemd/system/brightness-kb-backlight-permission.service; enabled; vendor preset: disabled)
     Active: inactive (dead) since Thu 2021-05-27 11:27:53 NZST; 24min ago
    Process: 21032 ExecStart=/usr/bin/chmod 777 /sys/class/leds/tpacpi::kbd_backlight/brightness (code=exited, status=0/SUCCESS)
   Main PID: 21032 (code=exited, status=0/SUCCESS)
        CPU: 1ms

May 27 11:27:53 arch-t460p systemd[1]: Started Change permission for kb backlight file for use without sudo with xidlehook.
May 27 11:27:53 arch-t460p systemd[1]: brightness-kb-backlight-permission.service: Deactivated successfully.
```

## 3. Copy the other files from repo into their correct locations (relative to home)