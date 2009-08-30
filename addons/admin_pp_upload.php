<?php

// EXTERNAL APP UPLOAD v2
// For use with the Pixelpost Uploader & Lightroom Plugin
// Created by: Jay Williams <myd3.com>









////////// THE POSTKEY CAN BE SET BY EDITING THE PP_UPLOAD.PHP 
////////// FILE LOCATED IN THE ADMIN FOLDER










if($_GET['view'] == 'addons'){
	$pp_upload = include("../admin/pp_upload.php");
	
	if(CREATECAT == true){
		$pp_createcat_status = "true";
	}else{
		$pp_createcat_status = "false";
	}
	
	if(!$pp_upload){
		$pp_pp_upload_status = "<strong>ERROR! Can not find the file 'pp_upload.php' in the admin folder!</strong><br /><br />";
	}else{
		$pp_pp_upload_status = "<strong>Upload URL:</strong> {$cfgrow['siteurl']}admin/pp_upload.php<br />
		<strong>Post Key:</strong> ".POSTKEY."<br />
		<strong>Auto-Create New Categories:</strong> $pp_createcat_status<br />";
	}
}



$addon_name = "External App Upload";
$addon_description = "<p><strong>INFO</strong><br /><br />
$pp_pp_upload_status
</p>
<p>
<em>Settings can be changed by editing the file 'pp_upload.php' located in the Admin folder.</em>
</p>


<p>Created by Jay Williams (<a href=\"http://myd3.com/\">myd3.com</a>)</p>
";
$addon_version = "2.1";

add_admin_functions('categories_header','admin_html_head','','');
// your function to show a new page under a submenu in admin panel


function process_categories_trim(&$value)
{	// Trim each element of the array
   $value = trim($value);
}

function process_categories($tags){

	// strip bad characters
	$tags =  ereg_replace('[^[:space:]a-zA-Z0-9,]', '', $tags);
	// remove extra spaces
	$tags = preg_replace('/\s\s+/', ' ', $tags);
	// remove spaces on front or back
	$tags = trim($tags);
	// convert spaces to an array
	$tags = split(',', $tags);
	
	// run trim on each element of the array
	array_walk($tags, 'process_categories_trim');
	
	// remove any blanks
	foreach($tags as $key => $value) {
	  if($value == "" || $value == null || $value == " ") {
		unset($tags[$key]);
	  }
	} 
	// remove any duplicates
	$tags = array_unique($tags);
	
	sort($tags);
	
	return $tags;

}

function categories_header(){
	/*
echo "<pre>";
var_dump(process_categories($_GET['categories']));
echo "</pre>";
*/
	global $cfgrow ,$pixelpost_db_prefix;
	if($_GET['x']=="save" and isset($_POST['categories']))
	{
		
				if (isset($_POST['categories'])){
					$tags = process_categories($_POST['categories']);
						#echo "Pass #3 of 3<BR>\n";
			#	echo "EXECUTE MYSQL TAGS!!!";
				unset($_POST['category']);
				
				$categories = categories_array(false);
				
				$i = 0;
				while($i < count($tags)){
				$cat_id = array_search(strtolower($tags[$i]), $categories);
					if($cat_id){
					$category[] = $cat_id;
					}elseif(CREATECAT == true){
					$query  ="INSERT INTO ".$pixelpost_db_prefix."categories(id,name) VALUES(NULL,'".$tags[$i]."')";
					$result = mysql_query($query) || die("Error: ".mysql_error());
					$cat_id = mysql_insert_id();
					$category[] = $cat_id;
					}
				$i++;
				}
				
				// subsetude tags for categories
				$_POST['category'] = $category;
				
			}
    }

	}

function categories_array($alpha)
{
	global $pixelpost_db_prefix;

 $query = mysql_query("select * from ".$pixelpost_db_prefix."categories order by id asc");

	 $i = 0;
	 
	 
	 if($alpha == true){
	 
	 while ($row = mysql_fetch_array($query, MYSQL_ASSOC)) {
   $categories[$i] = $row["name"];
   $i++;
	}	
	sort($categories);
	return $categories;

	 }else{
	 
	 while ($row = mysql_fetch_array($query, MYSQL_ASSOC)) {
   $categories[$row["id"]] = strtolower($row["name"]);
	}	
	return $categories; 
	 
	 
	 }
 
}


?>