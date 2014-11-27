#!/bin/bash

# Concept: gettext uses .pot templates which are identical to .po files, except
# that their strings are not translated. This allows .pot files to serve as a
# starting template when creating and updating language po files.

# What we are trying to do here is look at the .pot files that are getting 
# updated periodically and take new strings that don't exist in the .po files
# and add them as needed so they can be translated, while also disabling old
# translations that don't matter anymore.

# Weblate won't do this for us automatically, although it does provide some
# useful commands for running batch git commands on subprojects (repositories).

# For more info about continuous translation with Weblate, see
# http://docs.weblate.org/en/latest/admin/continuous.html

# This script will use msgmerge to update each language's po file based on the
# .pot template located in <moduledir>/i18n

# Any strings that existed in the old po file will be commented out and
# appended to the bottom, or at least that is what should happen.

# This might eventually be consolidated into the same scripts that update the
# .pot files in the first place.


if [ -d $1 ] && [ "$1" != "" ]; then
   mod=$1/
else
   mod=$(ls -d */)
fi

for modules in $mod
   do
      if [ -d ${modules}i18n ]; then
         pushd ${modules}i18n
         template=${modules%%/}.pot
         for pofile in `find . -wholename "*.po"`
            do
               msgmerge --update $pofile $template
            done
         popd
      fi
   done

# Now that the work is done we can optionally get these updates committed and
# pushed to git. Leaving these commented out by default.

# Commit any uncommitted changes
# /usr/local/bin/python2.7 manage.py commitgit --all

# Push all commits
# /usr/local/bin/python2.7 manage.py pushgit --all

# Update all repositories
# /usr/local/bin/python2.7 manage.py updategit --all
