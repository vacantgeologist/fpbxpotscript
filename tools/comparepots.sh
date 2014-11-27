#!/bin/bash

# A script for comparing new pot files to old ones that should be backed up
# first with the backuppots.sh script. The comparison is made with comm, and
# outputs lines that are in the old pot file and not in the new one, so we can
# check and make sure that nothing is missing.

# Note: It's normal for pot files to change as the software develops. Typos
# get fixed, new lines added and old ones deleted, etc. This can just be used
# as a precautionary measure to make sure your script isn't leaving out
# anything that should be there but isn't. Unfortunately, the results have to
# be checked by hand, which is no fun.

for potfile in `find . -wholename "*.pot"`
   do
      echo $potfile
      comm -13 <(sort $potfile) <(sort ${potfile}.bak)
   done

