#!/bin/bash
dir=$(ls -d */)

for i18ndirs in $dir
do
   if [ -d ${i18ndirs}i18n ]; then
      pushd $i18ndirs
         echo "Resetting "$i18ndirs
         git fetch origin
         git reset --hard origin/master
      popd
   fi
done
