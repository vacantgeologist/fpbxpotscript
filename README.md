#What the files are

###weblatescript.sh
This is the main script that is modified from the old one to scan necessary files for translatable strings. It depends on license.txt and xmlprocess.php.

###xmlprocess.php
Used by weblatescript.sh to get the required strings from each module's module.xml. It was easier to do this in php than in bash because php has the simpleXML stuff.

###addnewstrings2po.sh
This is a short script to update each language's po file after the .pot template has been generated/updated by weblatescript.sh. We could include this in weblatescript.sh later on if the functionality is useful there (it probably will be).

###tools/revertpots.sh
When testing the above scripts I was working with the repos from FreePBX's Stash server. This can be used to reset the pot files to their repository state when you want to start over.

###tools/potbackup.sh
Backup existing pot files so that they can be compared with new results.

###tools/comparepots.sh
Compare the two pot files generated by weblatescript.sh and potbackup.sh to see how many lines existed in the original that are not in the new version. This was mostly used to make sure that weblatescript.sh wasn't passing over any important strings that it should have been picking up.

