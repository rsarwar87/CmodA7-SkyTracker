
# StarTracker for CMod A7.

One device to control and track a equatorial mount. I use it with Skywatcher EQ5 with two NEMA 17 2A 200 step motors, two DRV8825, two 12--teeth timing pully, two 60-teeth timing pully and two 152mm timing belts. It was controlled from the Ekos telescope ecosystem with indi_eqmod_telescope and indi_nikon_ccd running on the ARM core. 

The FPGA is connected to an Raspberry Pi over SPI. I connected the raspbery pi to the nikon camera and a wifi dongle and is controlled over indiserver.

## Hardware Design

### RA/DE DRV8825 controller

The two motors are controlled by `ip/drv8825.vhd` which can accept backlash offsets, slew tracking (continuous motor operation at a given period) and goto commands which can either be based on a targeted step count or an increment or decrement count.

The steps are counted at 50 Mhz; depending of the voltage on the motor the minimum period would change. at 20 v, the minim period is 125 ticks.

The goto commands can contain acceleration flag which will accelerate the motor to the targetted speed over a period of 2 seconds. The flag is ignored by the design if the number of increment/decrement needed for the operation is not high enough to justify their use; or is the period is not short enough to justify it.

|Ports |Description |
|----------------|------------------------------
|clk_50 | clock; must be 50 MHz
|rstn_50 | Active low reset
|drv8825_enable_n | pin to DRV8825 enable pin (active low). Pin is only enabled when motors are spinning
|drv8825_mode [2 downto 0] | DRV8825 mode selector, set from the command mode. When it is set as 5 or higher, the step counter is incremented by one. When it is 4, than by 2; 3 -> 4; 2 -> 8; 1 -> 16; 0 -> 32 in order to keep with the microsteppings.
| drv8825_sleep_n drv8825_rst_n | to the DRV8825
| drv8825_step | Clock for the DRV8825
| drv8825_direction | direction of the DRV8825
| drv8825_fault_n | reporting fault on DRV8825
| ctrl_step_count [32 downoto 0] | reports the current step count to the top level
| ctrl_status [31 downto 0] | reports status update to the top level, e.g. is the motor running, what mode, etc.
| ctrl_cmdcontrol [0] | Goto command parameters. This is the execute pin. Command is only executed at the rising edge of this bit
| ctrl_cmdcontrol [1] | Defines goto command parameter. When high, the command is interpretted as a goto call, i.e. motor will spin until that counter reaches the value defined by ctrl_cmdduration. When low, the command is interpreted as a simple increment or decrement command, where the motor is spun for the number of cycles defined by ctrl_cmdduration.
| ctrl_cmdcontrol [2] | Defines goto command parameter related to the director of the motor
| ctrl_cmdcontrol [3] | Defines park command parameter. motor will spin till counter reaches zero
| ctrl_cmdcontrol [6 downto 4] | Defines goto command parameter related to the direction of the motor.
| ctrl_cmdcontrol [7] | Defines goto command parameter related acceleration of the motor. When high, acceleration and de-acceleration ramps are to be used.
| ctrl_cmdcontrol [30] | When high, it cancels the current any command currently being processed immediately.
| ctrl_cmdcontrol [31] | When high, it cancels the current any command currently being processed whilst deaccelating.
| ctrl_cmdtick [31 downto 0] | Define goto parameters related to the period at which command is to be executed in.
| ctrl_cmdduration [31 downto 0] | Define goto parameters related to the number of cycles/target count of the command.
| ctrl_backlash_tick [2 downto 0] | Define backlash parameters related the motor mode.
| ctrl_backlash_tick [31 downto 3] | Define backlash parameters related to the steps or the number of ticks the backlash correction is to execute in. Backlash is active when it is a non-zero value.
| ctrl_backlash_duration [31 downto 0] | Define backlash parameters related to the steps the backlash correction is to execute for. Backlash is active when it is a non-zero value.
| ctrl_counter_load [31 downto 0] | Overwrites the current step count; count is updated on the rising edge of bit 31. Therefore 31 bits are available for a possible max count.
| ctrl_counter_max [31 downto 0] | Loads the maximum count per revolution; count is updated on the rising edge of bit 31. Therefore 31 bits are available for a possible max count.
| ctrl_trackctrl [0] | Define slew to/tracking parameters. Only executed when no goto command is being executed. Bit 0 must be high if tracking is to be enabled.
| ctrl_trackctrl [1] | Define slew to/tracking parameters. Bit 1 defines the direction of motion
| ctrl_trackctrl [5 downto 2] | Define slew to/tracking parameters. Bit 2-5 defines the motor mode
| ctrl_trackctrl [31 downto 6] | Define slew to/tracking parameters. remaining bits defines the speed/period is number of 20 ns ticks.

The following shows the pinmap on the board:

    GPIO_0(1) <= ra_enable_n; -- pin 2
    GPIO_0(3) <= ra_mode(0); -- pin 4
    GPIO_0(5) <= ra_mode(1); -- pin 6
    GPIO_0(7) <= ra_mode(2); -- pin 8
    GPIO_0(9) <= ra_rst_n; -- pin 10
    GPIO_0(8) <= ra_sleep_n; -- pin 9
    GPIO_0(11) <= ra_step; -- pin 14
    GPIO_0(13) <= ra_direction;-- pin 16
    GPIO_0(17) <= de_enable_n;-- pin 20
    GPIO_0(19) <= de_mode(0); -- pin 22
    GPIO_0(21) <= de_mode(1); -- pin 24
    GPIO_0(23) <= de_mode(2); -- pin 26
    GPIO_0(25) <= de_rst_n; -- pin 28
    GPIO_0(24) <= de_sleep_n; -- pin 27
    GPIO_0(27) <= de_step; -- pin 32
    GPIO_0(29) <= de_direction;-- pin 34

### Top Level
The two ips are controllerd from the RPi over SPI. The the SPI is handled in `hdl/spi_slave.vhd`, one for status and one for control. The are mapped onto the registers which feed the two ips.

#### SPI
Each SPI command consists of size 8-bit words.  It operates at a maximum or 32.1 MHz. 

##### Read commands
bits -> 0XZYYYYY - 8-bit DONTCARE - 32 bit DATA.

the first bit of the transaction denotes if it is read or write command, read is active low. the third bit, Z denotes it is the status registers or control registers. the following 5-bits are the address of the register.
The next 8 bits are ignored by the hardware, and is in place to allow proper 2-cycle clock domain cross over. Data is to be ignored during this word. the final 4 8-bit words are the returned register values.

##### Read commands
bits -> 1XZYYYYY - 32 bit DATA - 8-bit DONT CARE. 

the first bit of the transaction denotes if it is read or write command, write is active high. the third bit, Z denotes it is the status registers or control registers. the following 5-bits are the address of the register.
The following 4 8-bit words are written to the register pointed by the address. The last 8 bits are ignored by the hardware, and is in place to allow proper 2-cycle clock domain cross over. Data is to be ignored during this word. 

#### Camera Triggers
To facilitate the use of older cameras which cannot be triggered in bulb mode over the usb, there are two gpios which are used to send triggers. they can be passed to an optoisolator to connect to the camera remote trigger ports.

       GPIO_0(35) <= camera_trigger(0); -- pin 40
       GPIO_0(34) <= camera_trigger(1); -- pin 39

#### Polar LED
A 8 bit std_logic_vector can be set to a value which is used to generate a PWM signal in order to connect to an LED to be used as a polar illuminator

#### LED Status
The custom board has 8 leds which are used to show the status of the device. There are four state of operation
1.	during startup, the first led will be flashing whilst all the other leds will be on solid. This indicates that the linux software is yet to start.
2.	upon the start of the linux software, the led will display the IP address of the device. This is the default state when the motors are not spinning
3.	if ethernet fails to set up a link. all leds will blink in sync indicating a communication fault.
4.	 when motors are spinning, ->
	a. led_status(0) -> RA motor active
	b. led_status(1) <= RA motor direction;
	c. led_status(2) <= RA motor has valid signals;
	d. led_status(3) <= the 9th bit of the RA current count;
	a. led_status(4) -> DE motor active
	b. led_status(5) <= DE motor direction;
	c. led_status(6) <= DE motor has valid signals;
	d. led_status(7) <= the 9th bit of the DE current count;

## Software design
The software uses koheron-server to commincate with a client over the ethernet/wifi.
look here: https://github.com/rsarwar87/de10-sky-tracker/blob/master/koheron-server/README.md
### Register Map
The stutus and the control `hdl/spi_slave.vhd`s. The offsets for these are `0x20` and `0x00`.

#### Status

The following are the status registers in the 
| Ports | Offset w.r.t. 0x20   | size | Description  
|--|--|--| -- |
| dna            | 0x0 | 64-bit word | Returns fixed value, design ID
| step_count[0]   | 0x2 | 32-bit word | Current RA step count
| step_count[1]   | 0x3 | 32-bit word | Current DE step count
| status[0]  | 0x4 | 32-bit word | Current RA status
| status[1]      | 0x5 | 32-bit word | Current DE status
| forty_two      | 0x6 | 32-bit word | always returns 42, to check if device is working properly

#### Control

The following are the status registers in the 
|Ports |Offset w.r.t. 0x00  | size | Description 
|----------------|--------|--------|--------------
| counter_load[0] | 0x0 | 32-bit word | RA load counter
| counter_load[1] | 0x1 | 32-bit word | DE load counter
| counter_max[0]   | 0x2 | 32-bit word | RA max count
| counter_max[1]   | 0x3 | 32-bit word | DE max count
| cmdcontrol[0]  | 0x4 | 32-bit word | RA Command control
| cmdcontrol[1]      | 0x5 | 32-bit word | DE  Command control
| cmdduration[0]  | 0x6 | 32-bit word | RA Command duration
| cmdduration[1]      | 0x7 | 32-bit word | DE Command duration
| trackctrl[0]  | 0x8 | 32-bit word | RA tracking control
| trackctrl[1]      | 0x9 | 32-bit word | DE tracking control
| cmdtick[0]  | 0xa | 32-bit word | RA Command period
| cmdtick[1]      | 0xb | 32-bit word | DE Command period
| backlash_tick[0]  | 0xc | 32-bit word | RA Backlash period
| backlash_tick[1]      | 0xd | 32-bit word | DE Backlash period
| backlash_duration[0]  | 0xe | 32-bit word | RA Backlash duration
| backlash_duration[1]      | 0xf | 32-bit word | DE Backlash duration
| led  | 0x10 | 32-bit word | IP address of the device
| led_pwm      | 0x11 | 32-bit word | Polar LED
| camera_trigger      | 0x12 | 32-bit word | Current RA status



## Linux rootfs:
this repo tells how to make the 5.4 kernel and subsequent rootfs
https://github.com/rkaczorek/astroberry-server
 
### Installing server on the ARM
Clone the repo on this running linux. 
```
cd 
git clone https://github.com/rsarwar87/CmodA7-SkyTracker --depth=1
cd CmodA7-SkyTracker/koheron-server
make server
mkdir build
cd build
cmake ../
make
sudo cp serverd /usr/bin/.
```
Create a file in ```/etc/systemd/system/koheron-server.service``` and fill it with:
```
[Unit]
Description=Koheron TCP/Websocket server
After=network.target unzip-default-instrument.service
[Service]
Type=notify
NotifyAccess=all
ExecStart=/use/bin/serverd
ExecStop=/usr/bin/pkill -SIGINT serverd
KillSignal=SIGKILL
# No limitation in the number of restarts per time interval
StartLimitInterval=0
[Install]
WantedBy=multi-user.target
```
Finally run:
```
systemctl enable koheron-server.service
systemctl start koheron-server.service
```


### Indilib software stack on the ARM

The device needs some modified indi-3rd party drivers as well to enable controlling the mount and the camera triggers on the FPGA.

```
cd 
git clone https://github.com/rsarwar87/CmodA7-SkyTracker --depth=1
cd CmodA7-SkyTracker/koheron-server/
make server
cd libclient
mkdir build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=/usr ../
make
sudo make install
```

On the device:

```
sudo apt-get install libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtiff-dev libftdi-dev libgps-dev libraw-dev libdc1394-22-dev libgphoto2-dev libboost-dev libboost-regex-dev librtlsdr-dev liblimesuite-dev libftdi1-dev
cd
git clone https://github.com/rsarwar87/indi-3rdparty --depth=1
cd indi-3rdparty/indi-eqmod
mkdir build
cd  build
cmake -DCMAKE_INSTALL_PREFIX=/usr ../
make
sudo make install
cd 
cd indi-3rdparty/indi-gphoto
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ../
make
sudo make install
```
To run the device, connect everything and then from the terminal:

### Installing/configuring EKOS linux binaries on laptop.

Installation:
```
sudo apt-add-repository ppa:mutlaqja/ppa
sudo apt-get update
sudo apt-get install indi-full kstars-bleeding
```
Custom driver if indiserver is to run locally on the laptop/PC.
```
sudo apt-get install libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtiff-dev libftdi-dev libgps-dev libraw-dev libdc1394-22-dev libgphoto2-dev libboost-dev libboost-regex-dev librtlsdr-dev liblimesuite-dev libftdi1-dev
cd
git clone https://github.com/rsarwar87/indi-3rdparty --depth=1
cd indi-3rdparty/indi-eqmod
mkdir build
cd  build
make
sudo make install
cd 
## Do this if you wish to use the camera triggers only, otherwise not needed
cd indi-3rdparty/indi-gphoto
mkdir build
cd build
cmake ../
sudo make install
```

Running
```
export SKY_IP="127.0.0.1"
indiserver indi_nikon_ccd indi_eqmod_telescope
```
after first connect make the following changes:
1. EQ mod - change device port from /dev/ttyUSB0 to /dev/ttyS0. -- this is irralevent to out system, but it is just to stop indiserver from complaining
2. If you wish to use the FPGA to trigger the camera, in the nikon camera setting, set port to "KFPGA"


