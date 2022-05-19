#!/bin/sh

RNDM=$(od -vAn -N2 -tu2 < /dev/urandom)
echo "Random number is ${RNDM}"

sed -i -e "1s/.*/\/WCSim\/random\/seed ${RNDM}/" /annie/app/users/mnieslon/WCSim/macros/setRandomParameters.mac
