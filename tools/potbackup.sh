#!/bin/bash
for potfile in `find . -wholename "*.pot"`
do
   echo "Backing up "$potfile
   cp $potfile ${potfile}.bak
done

