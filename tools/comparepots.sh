#!/bin/bash
for potfile in `find . -wholename "*.pot"`
   do
      #cat ${potfile}.bak | sort > ${potfile}.bak.tmp
      echo $potfile
      #cat $potfile | sort > ${potfile}.tmp
      comm -13 <(sort $potfile) <(sort ${potfile}.bak)
   done

