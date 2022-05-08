# Access the hardware from Linux

When Linux is booted, there are several things allowing to control the hardware.

## LEDs

LED support must be enabled in the Kernel. Additional triggers can be appended by configuration at compilation time.

Initially, KizOS shows the status of the TaHoma using its 2 RGB LEDs. Once the regulator feeds the LEDs with the right voltage, they can be controlled using `/sys/class/leds/pwm:<color>:user`.

For example, setting the LEDs to green will look like something like:

```bash
echo 128 > /sys/class/leds/pwm:green:user/brightness
echo 0 > /sys/class/leds/pwm:red:user/brightness
echo 0 > /sys/class/leds/pwm:blue:user/brightness
```

The brightness can be adjusted between 0 and 255.

## USB

At start, the USB-A port is disabled. To enable it, it is necessary to set the GPIO PE3 to HIGH first.

To enable it, we need to take 2 steps:

* Export the pin
* Set the pin to output and the level to high

In Shell this gives (note that this won't work with Linux <= 3.7):

```bash
PIN=131 # 131 is PE3's pin number
NAME=pioE3 # pioE3 is PE3 full name
VALUE=1 # Value is high for bus powering
# If the pioE3 GPIO is not already exported
if ! test -d /sys/class/gpio/$NAME ; then
    echo $PIN > /sys/class/gpio/export
fi
# Set the pin as output and set the value
echo out > /sys/class/gpio/$NAME/direction
echo $VALUE > /sys/class/gpio/$NAME/value

```