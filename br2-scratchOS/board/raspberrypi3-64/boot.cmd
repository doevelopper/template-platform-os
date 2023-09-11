setenv kernel_addr_r 0x01000000
setenv ramdisk_addr_r 0x02100000
fatload mmc 0:1 ${kernel_addr_r} Image
fatload mmc 0:1 ${fdt_addr_r} bcm2710-rpi-3-b-plus.dtb
#fatload mmc 0:1 ${ramdisk_addr_r} rootfs.cpio
#setenv initrdsize $filesize
#booti ${kernel_addr_r} ${ramdisk_addr_r}:${initrdsize} ${fdt_addr_r}
booti ${kernel_addr_r} - ${fdt_addr_r}


# setenv dtb_loadaddr 0x41000000
# setenv kernel_loadaddr 0x41100000

# led led:usr on
# led led:pwr on

# # Initialize i2c bus 1
# # i2c dev 0

# # Default to Boson S3 Dev
# setenv fdtfile sun8i-s3-boson-s3-dev.dtb

# setexpr rootpart ${distro_bootpart} + 1 || rootpart=4
# part uuid ${devtype} ${devnum}:${rootpart} rootuuid
# setenv bootargs initcall_debug root=PARTUUID=${rootuuid} ro rootwait earlycon
# load ${devtype} ${devnum}:${distro_bootpart} ${kernel_loadaddr} zImage
# load ${devtype} ${devnum}:${distro_bootpart} ${dtb_loadaddr} ${fdtfile}

# # Check for a MAC address extracted from efuse
# if test -n ${ethaddr}; then
# 	# Parse MAC address, Linux expects an uint8_t array
# 	setexpr ethaddr_components gsub ':' ' 0x' [0x${ethaddr}]
# 	# Setup fdt modification
# 	fdt addr ${dtb_loadaddr}
# 	# Make some space for the extra property
# 	fdt resize 128
# 	# Insert MAC address into dtb
# 	fdt set /soc/ethernet@1c30000 local-mac-address ${ethaddr_components}
# fi

# bootz ${kernel_loadaddr} - ${dtb_loadaddr}


fatload mmc 0:1 $fdt_addr_r bcm2710-rpi-3-b.dtb
fatload mmc 0:1 $loadaddr Image
setenv bootargs root=/dev/mmcblk0p2 rw rootwait console=tty0 rootfstype=ext4 earlycon
booti $loadaddr - $ftadrr

# generic params
bootdelay=3
stderr=serial,lcd
stdin=serial,usbkbd
stdout=serial,lcd

# CPU config
cpu=armv8
smp=on

## Console config
#baudrate=115200
#sttyconsole=ttyS0
#ttyconsole=tty0

# Kernel/dtb filenames & load addresses
#boot_it=booti ${kernel_addr_r} - ${fdt_addr_r}
#fdt_addr_r=0x01000000
#kernel_addr_r=0x02000000

# NFS/TFTP boot configuraton
#gatewayip=192.168.1.1
netmask=255.255.255.0
nfsserverip=92.168.1.24
tftpserverip=192.168.1.24
nfspath=/srv/nfs/rpi

# bootcmd & bootargs configuration
#preboot=usb start
#bootcmd=run mmcboot
load_kernel=fatload mmc 0:1 ${kernel_addr_r} kernel8.img
mmcboot=run load_kernel; run set_bootargs_tty set_bootargs_mmc set_common_args; run boot_it
nfsboot=run load_kernel; run set_bootargs_tty set_bootargs_nfs set_common_args; run boot_it
set_bootargs_tty=setenv bootargs console=${ttyconsole} console=${sttyconsole},${baudrate}
set_bootargs_nfs=setenv bootargs ${bootargs} root=/dev/nfs rw rootfstype=nfs nfsroot=${nfsserverip}:${nfspath},udp,vers=3 ip=dhcp
set_bootargs_mmc=setenv bootargs ${bootargs} root=/dev/mmcblk0p2 rw rootfs=ext4
set_common_args=setenv bootargs ${bootargs} smsc95xx.macaddr=${ethaddr} 'ignore_loglevel dma.dmachans=0x7f35 rootwait 8250.nr_uarts=1 elevator=deadline fsck.repair=yes bcm2708_fb.fbwidth=1920 bcm2708_fb.fbheight=1080 vc_mem.mem_base=0x3ec00000 vc_mem.mem_size=0x40000000 dwc_otg.fiq_enable=0 dwc_otg.fiq_fsm_enable=0 dwc_otg.nak_holdoff=0'



setenv tftp_dir "/zed-node"
setenv kernel_img "zImage"
setenv fdt_file "zynq-zed.dtb"
setenv bit_file "zynq_pl.bit.bin"
setenv bitsize 3dbafc
setenv tftp_ld_kernel "tftpboot ${kernel_addr_r} ${tftp_dir}/${kernel_img}"
setenv tftp_ld_dtb "tftpboot ${fdt_addr_r} ${tftp_dir}/${fdt_file}"
setenv tftp_ld_bit "tftpboot ${loadbit_addr} ${tftp_dir}/${bit_file}"
setenv load_fpga "echo fpga load 0 ${loadbit_addr} ${bitsize}; fpga load 0 ${loadbit_addr} ${bitsize};"

setenv nfs_rootpath "/srv/nfsroot/zed-node"
setenv nfs_serverip "192.168.150.250"
setenv bootargs "console=ttyPS0,115200n8 ip=192.168.150.210:192.168.150.250:192.168.150.254:255.255.255.0:zed-node::none:192.168.150.235::: rootfstype=nfs root=/dev/nfs nfsroot=${nfs_serverip}:${nfs_rootpath},tcp,nfsvers=4.2 rw rootwait devtmpfs.mount=0"
run tftp_ld_bit
run load_fpga
run tftp_ld_kernel
run tftp_ld_dtb
bootz ${kernel_addr_r} - ${fdt_addr_r}