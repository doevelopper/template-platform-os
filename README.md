```txt
                 ,-.     ______   ,.
                 ("` )-,-' -.   `-( /                                                                    ,;                 '.         
                 `._`-    _,._`  ,';.                                                                   ;:                   :;
                  _/ ---,',o-.` ,-,:o.                                                                 ::                     ::
                 /,:"'    ,-.`-,   ``"\                                                                ::                     ::
                 /  ,.::"('  ` ,::.    \                                                               ':                     :
                (;:' __,' \ \_ `"""``../                                                                :.                    :
                 :','     ;  \`._    `')                                                             ;' ::                   ::  '
                 ' "":    ;;  \| |`----;                                                            .'  ';                   ;'  '.   
               ,' ,- '`     ; `| |`==='\.                                                          ::    :;                 ;:    ::
              '             ;  | |     | \                                                         ;      :;.             ,;:     :: 
             /            ; ;  ; ;     )  `                                                        :;      :;:           ,;"      ::
            /            ,   '/ /,    //   ;                                                       ::.      ':;  ..,.;  ;:'     ,.;:
            ;           ,    /,';;;;;//    ;
            :         :'     `      ;/     '
            |        ::               ;   ;
            |      .:::                  ;
            |        `:              ,  :
            ;         |             ,   ;
             \        |            ::  |
             ,\       |.          ::   |
            /  \       :.        .:'    \
          ,'   ;        ;:.    .:;      |
      ,-""-.,^-`;       ::::.::,'|      ;
     /:.    `   `;      |:::::/  |     :
    (:::.    `   ;      |:::'/   |     |
     \:' `    `.  \      \'  /   |     |
      \    `   \:.:\      \ /    :     :
  ,'`-'`.       \::;      `/     ;    (
,;_      `._     \:/       `--.,'      `.
   `::.     \ ,::'Y-. ,-. ,-. (   ,-. ,-.`,.
     `"`--.__)   (   Y   Y   \;\ (   Y   Y  \
             \ ; |  :| : | : |  \|  :|  :| :|
              `-'`--;^-;-^-;-'    `-; `-;`-;'
```
# Template Buildroot External
Template of BR2_EXTERNAL  project architecture that leverage multi SBC platformization



## Table of contents

* [General info](#general-info)
* [Setup](#setup)
* [Configuration](#configuration)
* [Build](#build)
* [Other buildroot commands](#other-buildroot-commands)
* [Measurement software for Sleepy Pi 2](#measurement-software-for-sleepy-pi-2)

## General info

An external [buildroot](https://buildroot.org/) project to optimize the localizer project of DistriNet on the Raspberry Pi Zero W.
The goal is to improve boot times to prolong running the Raspberry Pi Zero W in combination with a Sleepy Pi 2 on a battery.

## Setup

To define the necessary paths (e.g. of buildroot), create a `.env` file.

```sh
cp .env.example .env
```

Put buildroot source code (from git or a tarball) alongside this project (in `../buildroot`), or alter the `BUILDROOT_PATH` variable in `.env`.

## Configuration

Start configuring the image by first selecting a defconfig.

```sh
make rpi0w_defconfig
```

> The optimized configuration is available as `rpi0w_fast_reboot_defconfig` with all measurement software enabled.
>
> To see all available defconfigs, list them with:
>
> ```sh
> make list-defconfigs
> ```

Next, configure the image in `menuconfig` if required.

```sh
make menuconfig
```

Target packages provided by this project can be found under `External options ---> DistriNet`.
## Build

Build an image (this can take a while):
```sh
    make all
```
## Other buildroot commands

Any command that buildroot supports can be used. The command will always be passed to buildroot.

## Measurement software for Sleepy Pi 2

The software used to measure the boot time is included at `board/distrinet/sleepypi2` and can be flashed with the Arduino IDE. The setup is documented at [SpellFoundry](https://spellfoundry.com/docs/sleepy-pi-2-getting-started/). In addition to the Sleepy Pi libraries, the Arduino [EDB](https://www.arduino.cc/reference/en/libraries/edb/) library is used to store measurements in EEPROM.

           
         ,;                 '.         
        ;:                   :;        
       ::                     ::       
       ::                     ::       
       ':                     :        
        :.                    :        
     ;' ::                   ::  '     
    .'  ';                   ;'  '.    
   ::    :;                 ;:    ::   
   ;      :;.             ,;:     ::   
   :;      :;:           ,;"      ::   
   ::.      ':;  ..,.;  ;:'     ,.;:   
    "'"...   '::,::::: ;:   .;.;""'    
        '"""....;:::::;,;.;"""         
    .:::.....'"':::::::'",...;::::;.   
   ;:' '""'"";.,;:::::;.'""""""  ':;   
  ::'         ;::;:::;::..         :;  
 ::         ,;:::::::::::;:..       :: 
 ;'     ,;;:;::::::::::::::;";..    ':.
::     ;:"  ::::::"""'::::::  ":     ::
 :.    ::   ::::::;  :::::::   :     ; 
  ;    ::   :::::::  :::::::   :    ;  
   '   ::   ::::::....:::::'  ,:   '   
    '  ::    :::::::::::::"   ::       
       ::     ':::::::::"'    ::       
       ':       """""""'      ::       
        ::                   ;:        
        ':;                 ;:"        
          ';              ,;'          
            "'           '"            
              '