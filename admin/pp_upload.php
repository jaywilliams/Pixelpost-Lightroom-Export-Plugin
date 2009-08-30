<?php


// EXTERNAL APP UPLOAD v2.1
// For use with the Pixelpost Uploader & Lightroom Plugin
// Created by: Jay Williams <myd3.com>


/**
 * This is the "master password" that allows external apps to upload photos to Pixelost.
 * Make sure the key is LONG and hard to guess.  You can always copy-paste the key into
 * the application you are wanting to use if it is too long to type.
 * 
 * For a good post key, check out this site: https://www.grc.com/passwords.htm
 **/
define("POSTKEY", "ChangeMe");

/**
 * When you enter categories, you can have the application automatically create 
 * new categories if the one you entered does not exist.  To enable this feature,
 * change the text from false to true.
 **/
define("CREATECAT", false);



























////////// DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING! ////////// 


// Based off of the code from:

// SVN file version:
// $Id: index.php 517 2008-01-16 20:01:47Z d3designs $


// Pixelpost version 1.7


error_reporting(0);

$PHP_SELF = "index.php";



// Cheep hack to allow loading of vars on addons page
if(!isset($_GET['view'])){


// Passkey Check
if(!isset($_GET['post_key_hash']) || $_GET['post_key_hash'] != md5(POSTKEY)){
//	exit();
	die ("ERROR: Incorrect Post Key");
}


if(isset($_GET['mode']) AND $_GET['mode'] == 'validate'){
	die('OK');
}elseif(isset($_GET['mode']) AND $_GET['mode'] == 'upload'){
	// Continue on our way...
}else{
	die('ERROR: Incorrect Mode');
}


ob_start();


// Translate to Pixelpost format:
$_POST['headline'] = $_POST['title'];
$_POST['body'] = $_POST['description'];
$_POST['tags'] = trim($_POST['tags'],', ');


// $_POST['allow_comments'] = $cfgrow["global_comments"];
// $_POST['allow_comments'] = 'A';


$_FILES['userfile'] = $_FILES['photo'];



// $_POST['headline'] = urldecode($_POST['headline']);
// $_POST['categories'] = urldecode($_POST['categories']);
// $_POST['autodate'] = urldecode($_POST['autodate']);
// $_POST['body'] = urldecode($_POST['body']);


// if($_POST['autodate'] == "Post one day after last post"){
// 	$_POST['autodate'] = 1; // Post one day after last post
// }else if($_POST['autodate'] == "Use exif date"){
// 	$_POST['autodate'] = 3; // Use exif date
// }else{
// 	$_POST['autodate'] = 2; // Post Now
// }

// Hack to get adons to work
$_GET['view'] = '';
$_GET['x'] = 'save';

// Hack to get post slug to auto-generate titles
$_POST['postslug'] = "";

// variable saying we are inside admin panel (i.e. to use in addons)
$admin_panel = 1;

session_start();

if (isset($_GET['errors']) && $_SESSION["pixelpost_admin"]){
	error_reporting(E_ALL ^ E_NOTICE);
	
}elseif(isset($_GET['errorsall']) && $_SESSION["pixelpost_admin"]){
	error_reporting(E_ALL);
	
}

require("../includes/pixelpost.php");
require("../includes/functions.php");
// Pixelpost Version
$version = "MS43LjEgKEJldHRlciB0aGFuIEV2ZXIpIC0gSmFudWFyeSAyMDA4";

$pixelpost_prefix_used = $pixelpost_db_prefix;
start_mysql('../includes/pixelpost.php','admin');

// added to allow upgrades
// This will be 0 for clean install, 1.3 for that version, 1.4+ for newer versions...
$installed_version = Get_Pixelpost_Version($pixelpost_db_prefix);
if( $installed_version < 1.71 )
{
	// header("Location: install.php");
	die('ERROR: Version Mismatch!');
	// exit;
}

// Changed to allow upgrades
if($cfgquery = mysql_query("select * from ".$pixelpost_db_prefix."config"))
{
	$cfgrow = mysql_fetch_assoc($cfgquery);
	$upload_dir = $cfgrow['imagepath'];
} else {
	// header("Location: install.php");
	die('ERROR: Can\'t load config');
	// exit;
}
// always include the default language file (English) if it exists. That way if we forget to update the variables in the alternative language files
// the English ones are shown.
if (file_exists("../language/admin-lang-english.php"))
{
	require("../language/admin-lang-english.php");
}
// now replace the contents of the variables with the selected language.
/* Special language file for Admin-Section, default is english */
// if($cfgrow = sql_array("SELECT * FROM ".$pixelpost_db_prefix."config"))
// {
// 	if (file_exists("../language/admin-lang-".$cfgrow['admin_langfile'].".php"))
// 	{
// 		$admin_lang_file_name = "admin-lang-".$cfgrow['admin_langfile'];
// 	}
// 	else
// 	{
// 		if (file_exists("../language/admin-lang-english.php"))
// 		{
// 			$admin_lang_file_name = "admin-lang-english";
// 		}
// 		else
// 		{
// 			echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
// 					 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
// 					<html>
// 					<head><title="Error, missing language file"></head><body>
// 					<hr/><p style="color:black;font-weight:bold;margin-left:20%;font-family:verdana,arial,sans-serif;">Attention! Take care, that at least the file <br /><br />
// 					<i style="color:red;font-size:bigger">admin-lang-english.php</i><br />
// 					<br />sits in the directory <i style="color:red;font-size:bigger">language</i>.<br /><br />
// 					You can find this file in the Pixelpost-ZIP-File in the directory <i style="color:red;font-size:bigger">language</i>.<br />
// 					<br />Please upload it to your server!</p><hr/></body></html>';
// 			exit;
// 		}
// 	}
// }

// require("../language/".$admin_lang_file_name.".php");

// check whether the language-files for the public part exist
// if (file_exists("../language/lang-".$cfgrow['langfile'].".php"))
// {
// 	require("../language/lang-".$cfgrow['langfile'].".php");
// }
// else
// {
// 	echo '<b>$admin_lang_error :</b><br />$admin_start_1 <b>"lang-' .$cfgrow['langfile'] .'.php"</b> $admin_start_2';
// 	exit;
// }

/************************ BEGINNING OF LOGIN STUFF ************************/

// forgot password?
// include('pass_recovery.php');

// autologin data are valid and cookies are set for a week (604800 seconds)
// if(($cfgrow['admin'] == $_COOKIE['pp_user']) AND (sha1($cfgrow['password'].$_SERVER["REMOTE_ADDR"]) === $_COOKIE['pp_password']) AND !isset($_SESSION["pixelpost_admin"]))
// {
//   error_reporting('E_ALL');
//   unset($login);
//   $_SESSION["pixelpost_admin"] = $cfgrow['password'];
//   setcookie( "pp_user", $_COOKIE['pp_user'], time()+604800);
//   setcookie( "pp_password", sha1($cfgrow['password'].$_SERVER["REMOTE_ADDR"]), time()+604800);
// }
// 
// if($_GET['x'] == "login")
// {
// 	$cfgrow_password = md5($_POST['password']);
// 	if(($cfgrow['admin'] == $_POST['user']) AND ($cfgrow_password == $cfgrow['password']))
// 	{
// 		error_reporting('E_ALL');
// 		// login is valid, set session
// 		unset($login);
// 		$_SESSION["pixelpost_admin"]  = $cfgrow_password;
// 
// 		// set autologin cookie
// 		if($_POST['remember'] == 'on')
// 		{
// 			setcookie( "pp_user", clean($_POST['user']), time()+604800);
// 			setcookie( "pp_password", sha1($cfgrow_password.$_SERVER["REMOTE_ADDR"]), time()+604800);
// 		}
// 		header("Location:index.php");
// 	}
// 	else
// 	{
//       $loginmessage = "$admin_start_userpw <br />
//         <a href='#' onclick=\"flip('askforpass'); return false;\">$admin_start_pw_forgot</a><br /><br />
//         ";
// 	}
// } // if (login = yes) end

// if($_GET['x'] == "logout")
// {
// 	unset($_SESSION["pixelpost_admin"]);
// 	setcookie( "pp_user", "", time()-36000);
// 	setcookie( "pp_password", "", time()-36000);
// 	header("Location:index.php");
// }

// Force LOGIN
   $cfgrow_password = $cfgrow['password'];
	$_POST['user'] = $cfgrow['admin'];


      // login is valid, set session
      	$_SESSION["pixelpost_admin"]  = $cfgrow_password;
 $_GET["_SESSION"]["pixelpost_admin"] = '';
$_POST["_SESSION"]["pixelpost_admin"] = '';

if(!isset($_SESSION["pixelpost_admin"]))
{
	// cookie is not set, send them to a form
	$login = "true";
} else {
	// cookie exists, check for validity
	if($cfgrow['password'] != $_SESSION["pixelpost_admin"])	$login = "true";
}

/************************ END OF LOGIN STUFF ************************/

//------------- addons in admin panel begins
// refresh the addons table
$dir = "../addons/";
refresh_addons_table($dir);

$addon_admin_functions = array(0 => array('function_name' => '','workspace' => '','menu_name' => '','submenu_name' => ''));
create_admin_addon_array();

if($cfgrow['crop']=="12c" && isset($_SESSION["pixelpost_admin"]))
{
	require("../includes/12cropimageinc.php");
}
//------------- addons in admin panel ends



    
 // if (login = yes) end

// <?php
if
($cfgrow['crop']=="12c" &&  ( (!isset($_GET['view']) && isset($_GET['x']) && $_GET['x']=='save')  ||  ($_GET['view']=="images" && isset($_GET['id'])))){
	require("../includes/12cropimageincscripts.php");
}
eval_addon_admin_workspace_menu('admin_html_head');

eval_addon_admin_workspace_menu('admin_main_menu'); 

// new image
//include('new_image.php');

// SVN file version:
// $Id: new_image.php 516 2008-01-16 19:51:02Z d3designs $

if(!isset($_SESSION["pixelpost_admin"]) || $cfgrow['password'] != $_SESSION["pixelpost_admin"] || $_GET["_SESSION"]["pixelpost_admin"] == $_SESSION["pixelpost_admin"] || $_POST["_SESSION"]["pixelpost_admin"] == $_SESSION["pixelpost_admin"] || $_COOKIE["_SESSION"]["pixelpost_admin"] == $_SESSION["pixelpost_admin"])
{
	die ("Try another day!!");
}

//require("../includes/exifer1_5/exif.php");

// if no page is specified return a new post / image upload thing
// if($_GET['view'] == "")
// {
	$show_image_after_upload = True; // For default behavior this is set to 'True' you can change this to false in your addons in the new image page

   // save new post
	if($_GET['x'] == "save")
	{
		$headline = clean($_POST['headline']);
		$body = clean($_POST['body']);

		if(isset($_POST['alt_headline']))
		{
 		  //Obviously we would like to use the alternative language
			$alt_headline = clean($_POST['alt_headline']);
			$alt_body =  clean($_POST['alt_body']);
			$alt_tags = clean($_POST['alt_tags']);
		}
		else
		{
			$alt_headline = "";
			$alt_body =  "";
			$alt_tags = "";
		}

		$comments_settings = clean($_POST['allow_comments']);
	  $datetime =
             intval($_POST['post_year'])."-".
             intval($_POST['post_month'])."-".
             intval($_POST['post_day'])." ".
             intval($_POST['post_hour']).":".
             intval($_POST['post_minute']).":".date('s');

		if( $_POST['autodate'] == 1)
		{
			$query = mysql_query("select datetime + INTERVAL 1 DAY from ".$pixelpost_db_prefix."pixelpost order by datetime desc limit 1");
			$row = mysql_fetch_row($query);
			if( $row) $datetime = $row[0];	// If there is none, will default to the other value
		}
		else if( $_POST['autodate'] == 2)
		{
			$datetime = gmdate("Y-m-d H:i:s",time()+(3600 * $cfgrow['timezone']));
		}
		else if($_POST['autodate'] == 3)// exifdate
		{
			// New, JFK: post date from EXIF
			// delay action to later point. We don't know the filename yet...
			// just set a flag so we know what to do later on
			$postdatefromexif = TRUE;
		};

	  if($headline == "")
	  {
			echo  "
  		 <div id='warning'>$admin_lang_ni_missing_data</div><p/>
       <script type='text/javascript'>
			 <!--
			 document.location = '#warnings'
			 -->
		 </script>";
	    exit;
	  }

		$status = "no";

	  // prepare the file
		if($_FILES['userfile'] != "")
		{
			$userfile = strtolower($_FILES['userfile']['name']);
			$tz = $cfgrow['timezone'];

			if($cfgrow['timestamp']=='yes')	$time_stamp_r = gmdate("YmdHis",time()+(3600 * $tz)) .'_';

			$uploadfile = $upload_dir .$time_stamp_r .$userfile;

			// NEW WORKSPACE ADDED
      eval_addon_admin_workspace_menu('image_upload_start');

			if(move_uploaded_file($_FILES['userfile']['tmp_name'], $uploadfile))
			{
				chmod($uploadfile, 0644);
				$result = check_upload($_FILES['userfile']['error']);
				$filnamn =strtolower($_FILES['userfile']['name']);
				$filnamn = $time_stamp_r .$filnamn;
				$filtyp = $_FILES['userfile']['type'];
				$filstorlek = $_FILES['userfile']['size'];
				$status = "ok";

				//Get the exif data so we can store it.
				// what about files that don't have exif data??
				include_once('../includes/functions_exif.php');

				$exif_info_db = serialize_exif($uploadfile);

				if($postdatefromexif == TRUE)
				{
					// since we all ready escaped everything for database commit we have
					// strip the slashes before we can use the exif again.
					$exif_info = stripslashes($exif_info_db);
					$exif_result=unserialize_exif($exif_info);
					$exposuredatetime = $exif_result['DateTimeOriginalSubIFD'];
					if($exposuredatetime!='')
					{
						list($exifyear,$exifmonth,$exifday,$exifhour,$exifmin, $exifsec) = split('[: ]', $exposuredatetime);
				    $datetime = date("Y-m-d H:i:s", mktime($exifhour, $exifmin, $exifsec, $exifmonth, $exifday, $exifyear));
				  }
				  else	$datetime = gmdate("Y-m-d H:i:s",time()+(3600 * $tz));
	      }
	      // NEW WORKSPACE ADDED
        eval_addon_admin_workspace_menu('image_upload_succesful');
			}
			else
			{
				// something went wrong, try to describe what
				if($_FILES['userfile']['error']!='0')	$result = check_upload($_FILES['userfile']['error']);
				else	$result = "$admin_lang_ni_upload_error ";

				echo "<div id='warning'>$admin_lang_error  ";
				echo "<br/>$result";

				if(!is__writable($upload_dir))	echo "<br/>$admin_lang_pp_img_chmod1";

				echo "</div><hr/>";

	 			// NEW WORKSPACE ADDED
        eval_addon_admin_workspace_menu('image_upload_failed');
			} // end move
		} // end prepare of file ($_FILES['userfile'] != "")

	  // insert post in mysql
		$image = $filnamn;

		if($status == "ok")
		{
			$query = "INSERT INTO ".$pixelpost_db_prefix."pixelpost (datetime,headline,body,image,alt_headline,alt_body,comments,exif_info)
			VALUES('$datetime','$headline','$body','$image','$alt_headline','$alt_body','$comments_settings','$exif_info_db')";
			$result = mysql_query($query) || die("Error: ".mysql_error().$admin_lang_ni_db_error);

	    $theid = mysql_insert_id(); //Gets the id of the last added image to use in the next "insert"

			if(isset($_POST['category']))
			{
				$query_val = array();
	
				foreach($_POST['category'] as $val)
				{
					$val = clean($val);
					$query_val[] = "(NULL,'$val','$theid')";
				}
	
				$query_st = "INSERT INTO ".$pixelpost_db_prefix."catassoc (id,cat_id,image_id) VALUES ".implode(",", $query_val).";";
				$result = mysql_query($query_st) || die("Error: ".mysql_error());
	    }
	    // done

			// workspace: image_uploaded
			eval_addon_admin_workspace_menu('image_uploaded');

			// save tags
			save_tags_new(clean($_POST['tags']),$theid);

			// save the alt_tags to if the variable is set
			if($cfgrow['altlangfile'] != 'Off')	save_tags_new(clean($_POST['alt_tags']),$theid,"alt_");

			// workspace: image_uploaded
			eval_addon_admin_workspace_menu('upload_finished');
		} // end status ok
	} // end save

	if(isset($status) && $status == 'ok')
	{
		unset($alt_headline, $alt_tags, $alt_body, $_POST['category'], $_POST['autodate'], $_POST['post_year'], $_POST['post_month'], $_POST['post_day'], $_POST['post_hour'], $_POST['post_minute'], $_POST['allow_comments']);
	}

	if($_GET['x'] == "save" && $status == "ok")
	{
		$headline = pullout($_POST['headline']);
		$body = pullout($_POST['body']);
		$headline = htmlspecialchars($headline,ENT_QUOTES);
		$body = htmlspecialchars($body,ENT_QUOTES);
		$to_echo = "
		 <div id='caption'>$admin_lang_ni_posted: $headline</div>
		 <div class='content'>$body<br/>
		 $datetime<br/><a href=\"$PHP_SELF?view=images&id=$theid\">[$admin_lang_imgedit_edit]</a><p>
		 ";

		// Check if the '12c' is selected as the crop then add 3 buttons to the page '+', '-', and 'crop'
		if($cfgrow['crop']=='12c')
		{
			$to_echo .="
						 $admin_lang_ni_crop_nextstep<br/>
						 <input type='button' name='Submit1' value='".$txt['cropimage']."' onclick=\"cropCheck('def','".$filnamn ."');\"/>
						 <input type='button' name='Submit3' value='".$txt['smaller']."' onmousedown=\"cropZoom('in');\" onmouseup='stopZoom();'/>
						 <input type='button' name='Submit4' value='".$txt['bigger']."' onmousedown=\"cropZoom('out');\" onmouseup='stopZoom();'/>
						 <br/> ";
		};

		echo $to_echo; // tag of content div still open

		//create thumbnail
		if(function_exists('gd_info'))
		{
			$gd_info = gd_info();

			if($gd_info != "")
			{
				$thumbnail = $filnamn;
				$thumbnail = createthumbnail($thumbnail);

				eval_addon_admin_workspace_menu('thumb_created');

				// if crop is not '12c' use the oldfashioned crop
				if($cfgrow['crop']!='12c')
				{
					if($show_image_after_upload)	echo "<img src='".$cfgrow['imagepath'].$filnamn."'/>";

					echo "</div><!-- end of content div -->" ; // close content div
				}// end if
				/* else it is '12c' crop and show cropdiv and the cropping frame
						at the bottom of the page.
				*/
				else
				{
				// set the size of the crop frame according to the uploaded image
					setsize_cropdiv ($filnamn);
				//--------------------------------------------------------
					$for_echo ="
						<img src='".$cfgrow['imagepath'].$filnamn."' id='myimg'/>
						<div id='cropdiv'>
						<table width='100%' height='100%' border='1' cellpadding='0' cellspacing='0' bordercolor='#000000'>
						<tr>
						<td><img src='".$spacer."'/></td>
						</tr>
						</table>
						</div> <!-- end of crop div -->
						<div id='editthumbnail'>
						<hidden>$admin_lang_ni_crop_background</hidden>
						</div><!-- end of editthumbnail id -->

					</div> <!-- end of content div -->  ";
					echo $for_echo;
				//--------------------------------------------------------
				} // end else
			} // gd info
		} // function_exists
	}



//////// END OF IMAGE UPLOAD SCRIPT ////////

eval_addon_admin_workspace_menu('admin_main_menu_contents');

$output = ob_get_contents();
ob_end_clean();

if($status == 'ok'){
	// Our job is done...
	// Let the program know!
	echo "OK";
}else{
	// ERROR!
	echo "ERROR: \n";
	echo $output;
}

// LOGOUT AT END
unset($_SESSION["pixelpost_admin"]);
setcookie( "pp_user", "", time()-36000);
setcookie( "pp_password", "", time()-36000);


}// End if Get View
?>