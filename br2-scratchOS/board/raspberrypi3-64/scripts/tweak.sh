#!/bin/bash

#config.txt
enable_uart=1
kernel=uboot.bin
device_tree_address=0x02008000
dtparam=i2c_arm=on
dtparam=spi=on

#overclock to 1.4 GHz
force_turbo=1               #Enable cpu-overclock over 1300MHz
avoid_pwm_pll=1             #Enable no-relative freq between cpu and gpu cores

arm_freq=1400               #Frequency of ARM processor core in MHz
core_freq=550               #Frequency of GPU processor core in MHz
over_voltage=6              #ARM/GPU core voltage adjust, values over 6 voids warranty

sdram_freq=600              #Frequency of SDRAM in MHz
sdram_schmoo=0x02000020     #Set SDRAM schmoo to get more than 500MHz freq
over_voltage_sdram_p=6      #SDRAM phy voltage adjust
over_voltage_sdram_i=4      #SDRAM I/O voltage adjust
over_voltage_sdram_c=4      #SDRAM controller voltage adjust

gpu_mem=256                 #GPU memory in MB. Memory split between the ARM and GPU
gpu_freq=550                #Sets core_freq h264_freq isp_freq v3d_freq together
v3d_freq=500                #Frequency of 3D block in MHz
h264_freq=350               #Frequency of hardware video block in MHz

dtparam=sd_overclock=100    #Clock in MHz to use for MMC micrSD
dtparam=audio=on            #Enables the onboard ALSA audio
dtparam=spi=on              #Enables the SPI interfaces

temp_limit=80               #Overheat protection. Disable overclock if SoC reaches this temp
initial_turbo=60            #Enables turbo mode from boot for the given value in seconds

start_x=1                   #Enable software decoding (MPEG-2, VC-1, VP6, VP8, Theora, etc)
overscan_scale=1            #Respect the overscan for HDMI output, avoid black borders on TV

#tweaks
disable_splash=1
gpu_mem=320
dtoverlay=pi3-disable-bt
dtoverlay=pi3-disable-wifi

script_file="$(cat<<'EOF'

echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

EOF
)"

sed -i '/^exit 0$/i'"$packaged_script" /etc/rc.local