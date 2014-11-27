<?php

//Load module.xml and then get the parts we need for .pot file generation
$xmldata=simplexml_load_file("module.xml") or die("Error: Cannot create object");
echo '// From module.xml - name' . '\n';
echo '_("' . trim($xmldata->name) . '")' . '\n';
echo '// From module.xml - category' . '\n';
echo '_("' . trim($xmldata->category) . '")' . '\n';
echo '// From module.xml - description' . '\n';
echo '_("' . trim($xmldata->description) . '")' . '\n';
//Logic for if there are <menuitems>
if ($xmldata->menuitems->children()) {
	echo '// From module.xml - menuitems' . '\n';
	foreach ($xmldata->menuitems->children() AS $child) {
		echo '_("' . trim($child) . '")' . '\n';
	}
}

?>
