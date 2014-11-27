# Script for generating .pot template localization files for FreePBX
# Based on the old script written during the Bandwidth years
# Requires gettext, php, and perl

# This file should be run from the Weblate directory containing all of the
# repositories as individual subdirectories.
# In our case this is now /usr/share/weblate/weblate/repos/freepbx on the
# current server at weblate.freepbx.org

# Note: In order for this script to work properly, it requires the following
# files:
#     -  xmlprocess.php (used to get xml elements from module.xml files)
#     -  license.txt (contains whatever license is current at the time
#        of pot file generation

# **** TODO List ****
# Come up with something to handle framework/core
# Check on weblate commands necessary to make sure the weblate DB doesnt
# get messed up when we generate, commit, and pull new files from git

# Git preparation through Weblate's manage.py

# Commit any uncommitted changes
# /usr/local/bin/python2.7 manage.py commitgit --all

# Push all commits
# /usr/local/bin/python2.7 manage.py pushgit --all

# Update all repositories
# /usr/local/bin/python2.7 manage.py updategit --all


# First, get the current directory and make it into a variable
pwd=`dirname $(readlink -f $0)`
cd $pwd

# Check for arguments, if there aren't any then list all the directories and 
# make that the variable known as $mod
if [ -d $1 ] && [ "$1" != "" ]; then
   mod=$1/
else
   mod=$(ls -d */)
fi

echo "Creating new POT template files for modules"

for modules in $mod
do

   # Special case framework and core because they are different from others
   if [ "${modules%%/}" = "framework" ]; then
      # TODO Code to handle framework here
      echo "This is framework, we're not done with this part of the script yet"
   else
   if [ "${modules%%/}" = "core" ]; then
      # TODO Code to handle core here
      echo "This is core, we're not done with this part either"
   else

# Now that we're done making amp.pot from core/framework, we can move on to the
# other modules which are handled normally.

      # $modules has a slash on the end of it, we can get rid of it by using %%/
      echo "Checking if module ${modules%%/} has an i18n directory"
      # spit out the module.xml in a <modulename>.i18.php so that we can grab 
      # it with the find
      if [ -d ${modules}i18n ]; then
         echo "Found directory ${modules}i18n, creating temp file"
         # We will make a fake temporary php file to hold some strings that 
         # will be wrangled from some non-php places
         echo -e "<?php \nif (false) {" > $modules${modules%%/}.i18n.php

         # Come up with an equivalent to module_admin using PHP to create these
         # files. The reason we have to do this is because module_admin requires
         # a fully installed PBX as it reads from the DB. We only have source 
         # code to work with here.
         
         # By the way, the old command was:
         #/var/lib/asterisk/bin/module_admin i18n ${modules%%/} >> $modules${rawname%%/}.i18n.php

         # Do the following commands from the repository's directory
         pushd ./${modules%%/}/

         # It might be a good idea to pull from git before doing anything, just
         # to make sure that files are up to date. We should be pulling from the
         # "master" branch since that is where localization work is done.
         # If any translation changes are not committed yet, this is going to
         # cause problems, so I am leaving it commented out for now. 
         # git pull

         # Now we need to get the necessary parts of module.xml - namely, 
         # <name>, <category>, and <description>, and then anything that is 
         # inside of <menuitems>
         # MAKE SURE THAT xmlprocess.php IS IN THE SAME DIRECTORY AS THIS SCRIPT
         # Otherwise you'll miss out on some important translation strings...
         # We run this script and tack its output onto the fake php file
         echo -e `php ../xmlprocess.php; >> ${modules%%/}.i18n.php` >> ${modules%%/}.i18n.php

         # Next we will use some grep commands to get the necessary parts of 
         # install.php - which are category, name, and description parts of the
         # $set array contained in each module's install.php
         # There is some string manipulation done to get things in the proper
         # formatting and account for inconsistencies in the source files.
         IFS=';'
         arr=( $(cat install.php | grep "\$set\[" | grep "'category'") )
         for x in ${arr[@]}
            do
               stringins=`echo "$x" | perl -pe 's:^[\s\S]*?\$set\[\S{1}\S+?\S{1}\]\s*=\s*\S{1}([\s\S]*)\S{1}\s*$:$1:g' | tr -d "\n"`
               echo -e '_("'$stringins'")' >> ${modules%%/}.i18n.php
            done
         arr=( $(cat install.php | grep "\$set\[" | grep "'name'") )
         for x in ${arr[@]}
            do
               stringins=`echo "$x" | perl -pe 's:^[\s\S]*?\$set\[\S{1}\S+?\S{1}\]\s*=\s*\S{1}([\s\S]*)\S{1}\s*$:$1:g' | tr -d "\n"`
               echo -e '_("'$stringins'")' >> ${modules%%/}.i18n.php
            done
         arr=( $(cat install.php | grep "\$set\[" | grep "'description'") )
         for x in ${arr[@]}
            do
               stringins=`echo "$x" | perl -pe 's:^[\s\S]*?\$set\[\S{1}\S+?\S{1}\]\s*=\s*\S{1}([\s\S]*)\S{1}\s*$:$1:g' | tr -d "\n"`
               echo -e '_("'$stringins'")' >> ${modules%%/}.i18n.php
            done

         # Finish off the fake php file's if structure with the necessary 
         # "}" and "?>"
         echo -e "}\n?>\n" >> ${modules%%/}.i18n.php
         # Leave the module's repo directory
         popd

         # Now we are ready to get started on scanning php code for translatable
         # strings with xgettext command
         echo "Creating ${modules%%/}.pot file, extracting text strings"
         # We use -wholename so we get recursive results for modules with 
         # nested php code
         find . -wholename "./${modules%%/}/*.php" | xargs xgettext --no-location --from-code=UTF-8 -L PHP -o ${modules%%/}/i18n/${modules%%/}.tmp --keyword=_ -
         sed --in-place ${modules%%/}/i18n/${modules%%/}.tmp  --expression='s/CHARSET/utf-8/'
					
         # Now add the copyright and the license info to the.pot file
         cat license.txt > ${modules%%/}/i18n/${modules%%/}.pot

         # Remove the first six lines of the .tmp file and put it in the pot file
         /bin/sed '1,6d' ${modules%%/}/i18n/${modules%%/}.tmp >> ${modules%%/}/i18n/${modules%%/}.pot

         echo "Removing temp files..."
         #rm $modules${rawname%%/}.i18n.php
#         rm ${modules%%/}/i18n/${modules%%/}.tmp
         echo "Commiting changes to git..."
         pushd $modules
         #git commit -am "Weblate server script auto-updated .pot file localization template."
         #git push
         echo "Normally would run a git command here to commit the changes"
         popd
      fi
   fi
   fi
   done

   # Remove the .tmp file created above for amp.pot generation
   # This may not be needed after creating the new code for framework and core
   #rm ../ampfiles.tmp

# All done!
echo "All pot files created and committed to git."
