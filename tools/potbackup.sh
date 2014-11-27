#!/bin/bash

# Quick command for making a backup of current pot files. Use this before
# generating new ones, and the you can use comparepots.sh to compare the old
# and new files afterward and see what changed.

for potfile in `find . -wholename "*.pot"`
do
   echo "Backing up "$potfile
   cp $potfile ${potfile}.bak
done

