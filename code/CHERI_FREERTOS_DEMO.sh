# CHERI-FREERTOS DEMO EXPLANATIONS

# This is a step by step explanation on how to run the cyberphys Demo.

# we will use HOMEDIR/cheri directory to build tools and demonstration
cd
mkdir cheri
cd cheri
# updating system
sudo apt update
sudo apt upgrade
sudo apt install git
# fetching cheribuild code from github
git clone https://github.com/CTSRD-CHERI/cheribuild.git
# installing dependencies
sudo apt install autoconf automake libtool pkg-config clang bison cmake mercurial ninja-build samba flex texinfo time libglib2.0-dev libpixman-1-dev libarchive-dev libarchive-tools libbz2-dev libattr1-dev libcap-ng-dev libexpat1-dev libgmp-dev
sudo apt-get install libmpc-dev
sudo apt install python-is-python3
# building needed tools
cd cheribuild
git checkout hmka2
./cheribuild.py qemu # emulator
./cheribuild.py llvm # cross compiler, will take a long time

##########################################################################
####### Build of Cyberphys will fail because there are errors in the code
# these operation modify the demo code, 
# wich will be fetched during the build of cyberphys on either freertos or cheri-freertos
cd ../freertos/FreeRTOS/Demo/RISC-V-Generic/bsp/
# bad file inclusion; file do not exists;
sed -e 's/#include "xiic.h"/\/\/#include "xiic.h"/' iic.h > tmp; mv tmp iic.h
sed -e 's/#include "xiic.h"/\/\/#include "xiic.h"/' iic.c > tmp; mv tmp iic.c
cd ../demo/cyberphys/
# virtualization don't have this specific hardware; disable build option
sed -e "s/'BSP_USE_IIC0         = 1',/'BSP_USE_IIC0         = 0',/" wscript > tmp; mv tmp wscript
# race condition on startNetwork() ip stack not initialised
# we have to move it at a place where its absolutely certain that it has been initialized
sed -e "s/    startNetwork()/\/\/startNetwork()/" main_besspin.c > tmp; mv tmp main_besspin.c
sed -e "s/uint8_t dummy = 1/startNetwork();uint8_t dummy = 1/" main_besspin.c > tmp; mv tmp main_besspin.c
##########################################################################

########## CYBERPHYS FREERTOS ##########
# HOW TO BUILD CYBERPHYS ON FREERTOS ON RISC-V ARCHITECTURE
cd ~/cheri/cheribuild
./cheribuild.py newlib-baremetal-riscv64
./cheribuild.py compiler-rt-builtins-baremetal-riscv64
./cheribuild.py freertos-baremetal-riscv64 --freertos/prog cyberphys --freertos/platform qemu_virt

# HOW TO RUN CYBERPHYS ON FREERTOS ON RISC-V ARCHITECTURE (commented by default to build everything automatically)
./cheribuild.py run-freertos-baremetal-riscv64 --run-freertos/prog cyberphys

########################################


########## CYBERPHYS CHERI-FREERTOS ##########
# HOW TO BUILD CYBERPHYS ON CHERI-FREERTOS ON CHERI-RISC-V ARCHITECTURE
./cheribuild.py newlib-baremetal-riscv64-purecap --clean --reconfigure
./cheribuild.py compiler-rt-builtins-baremetal-riscv64-purecap --clean --reconfigure


# DEFAULT:
./cheribuild.py freertos-baremetal-riscv64-purecap --freertos/prog cyberphys --freertos/platform qemu_virt --clean --reconfigure

#  WITH COMPARTMENTALIZATION ENABLED:
./cheribuild.py freertos-baremetal-riscv64-purecap --freertos/prog cyberphys --freertos/platform qemu_virt --clean --reconfigure --freertos/compartmentalize

# WITH DEBUG INFORMATIONS
./cheribuild.py freertos-baremetal-riscv64-purecap --freertos/prog cyberphys --freertos/platform qemu_virt --clean --reconfigure --freertos/compartmentalize --freertos/debug

# HOW TO RUN CYBERPHYS ON CHERI-FREERTOS ON CHERI-RISC-V ARCHITECTURE
./cheribuild.py run-freertos-baremetal-riscv64-purecap --run-freertos/prog cyberphys

##############################################

# ATTACK CODE:
cd ~/cheri/freertos/FreeRTOS/Demo/RISC-V-Generic/demo/cyberphys
sudo apt install curl
curl -o client.c https://github.com/GaloisInc/BESSPIN-Tool-Suite/blob/master/besspin/cyberPhys/canlib/utils/client.c

# Change IP target to "127.0.0.1" and  target port values (its emulated on computer, listening on a specific port of computer, the information is given at the beginning of execution)
sed -e 's/#define TARGET_ADDR/#define TARGET_ADDR "127.0.0.1"\/\//' client.c > tmp; mv tmp client.c
sed -e 's/#define PORT/#define PORT 5002\/\//' client.c > tmp; mv tmp client.c

# compile of the attack code will fail !!! comment the last function of ~/cheri/freertos/FreeRTOS/Demo/Risc-V-Generic/demo/cyberphys/cyberphys/j1939.c during the compilation, un-comment it after
 gcc -c cyberphys/j1939.c
 gcc -c cyberphys/canlib.c
 gcc -o client client.c j1939.o canlib.o 
 # TO RUN: (during run of cyberphys on either freertos or cheri-freertos)
 ./client
 
#to change compartmentalization option other than the default, set one of the option to 1 on wscript (~/cheri/freertos/FreeRTOS/Demo/RISC-V-Generic/demo/cyberphys/wscript):
#configCHERI_COMPARTMENTALIZATION_FAULT_RETURN
#configCHERI_COMPARTMENTALIZATION_FAULT_KILL
#configCHERI_COMPARTMENTALIZATION_FAULT_RESTART
#configCHERI_COMPARTMENTALIZATION_FAULT_CUSTOM
