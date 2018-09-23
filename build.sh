#!/bin/bash - 
#===============================================================================
#
#          FILE: build.sh
# 
#         USAGE: ./build.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 09/23/2018 08:49
#      REVISION:  ---
#===============================================================================

BASE_DIR=$(pwd)

#
#pip install esptool
#pip install pyserial 

# git clone espidf
if [ ! -d "${BASE_DIR}/esp-idf" ]
then
  git clone https://github.com/espressif/esp-idf.git
  cd ${BASE_DIR}/esp-idf
  # this value should come from the micropython repo
  git checkout 30545f4cccec7460634b656d278782dd7151098e
  git submodule update --init --recursive
fi 

export ESPIDF=${BASE_DIR}/esp-idf

if [ ! -d "${BASE_DIR}/xtensa-esp32-elf" ]
then
  #wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux32-1.22.0-73-ge28a011-5.2.0.tar.gz
  wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
  tar xzf xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
fi 

export PATH=${BASE_DIR}/xtensa-esp32-elf/bin:$PATH

# git clone micropython
if [ ! -d "${BASE_DIR}/micropython" ]
then
  cd ${BASE_DIR}
  git clone https://github.com/micropython/micropython.git
fi 

export BUILD_VERBOSE=1
cd ${BASE_DIR}/micropython
git submodule update --init
make -C mpy-cross V=1
git submodule init lib/berkeley-db-1.xx
git submodule update

# make esp32
#cd ${BASE_DIR}/micropython/ports/esp32
#make V=1

# make unix
cd ${BASE_DIR}/micropython/ports/unix
make deplibs
make axtls V=1
make V=1
make test

# install some python modules
#${BASE_DIR}/micropython/ports/unix/micropython -m upip install micropython-pystone
${BASE_DIR}/micropython/ports/unix/micropython -m upip install micropython-os

if [ -f "${BASE_DIR}/micropython/ports/unix/micropython" ]
then
  echo "Success building micropython binary for this platform"
else
  echo "Fail sauce."
fi
