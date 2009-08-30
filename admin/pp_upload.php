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
define("POSTKEY", "40B68D78FC42AE9FCFC067FBDC80FDF059B493C33617B896C54AD8A93A08062A");

/**
 * When you enter categories, you can have the application automatically create 
 * new categories if the one you entered does not exist.  To enable this feature,
 * change the text from false to true.
 **/
define("CREATECAT", false);

$UseGoogleMapAddon = true;
$UseFTPpermissions = true;

////////// DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING! //////////


// Based off of the code from:

// SVN file version:
// $Id: index.php 517 2008-01-16 20:01:47Z d3designs $


// Pixelpost version 1.7


error_reporting(0);
$PHP_SELF = "index.php";
define('ADDON_DIR', '../addons/');

// Cheep hack to allow loading of vars on addons page
if (!isset($_GET['view']))
{
	// Passkey Check
	if (!isset($_GET['post_key_hash']) || $_GET['post_key_hash'] != md5(POSTKEY))
	{
		die("ERROR: Incorrect Post Key");
	}

	if (isset($_GET['mode']) and $_GET['mode'] == 'validate')
	{
		die('OK');
	} elseif (isset($_GET['mode']) and $_GET['mode'] == 'upload')
	{
		// Continue on our way...
	}
	else
	{
		die('ERROR: Incorrect Mode');
	}


	ob_start();

	// Translate to Pixelpost format:
	$_POST['headline'] = $_POST['title'];
	$_POST['body'] = $_POST['description'];
	//$_POST['tags'] = trim($_POST['tags'],', ');
	$_POST['tags'] = null;
	if ($UseFTPpermissions==true)
		$_POST['ftp_password_permissions'] = $_POST['ftppassword'];
	$_FILES['userfile'] = $_FILES['photo'];

	// Hack to get adons to work
	$_GET['view'] = '';
	$_GET['x'] = 'save';

	// Hack to get post slug to auto-generate titles
	$_POST['postslug'] = "";

	// variable saying we are inside admin panel (i.e. to use in addons)
	$admin_panel = 1;

	session_start();

	if (isset($_GET['errors']) && $_SESSION["pixelpost_admin"])
	{
		error_reporting(E_ALL ^ E_NOTICE);

	} elseif (isset($_GET['errorsall']) && $_SESSION["pixelpost_admin"])
	{
		error_reporting(E_ALL);

	}

	require ("../includes/pixelpost.php");
	require ("../includes/functions.php");
	// Pixelpost Version
	$version = "MS43LjEgKEJldHRlciB0aGFuIEV2ZXIpIC0gSmFudWFyeSAyMDA4";

	$pixelpost_prefix_used = $pixelpost_db_prefix;
	start_mysql('../includes/pixelpost.php', 'admin');

	$installed_version = Get_Pixelpost_Version($pixelpost_db_prefix);
	if ($installed_version < 1.71)
	{
		die('ERROR: Version Mismatch!');
	}

	// Changed to allow upgrades
	if ($cfgquery = mysql_query("select * from " . $pixelpost_db_prefix . "config"))
	{
		$cfgrow = mysql_fetch_assoc($cfgquery);
		$upload_dir = $cfgrow['imagepath'];
	}
	else
	{
		// header("Location: install.php");
		die('ERROR: Can\'t load config');
		// exit;
	}
	// always include the default language file (English) if it exists. That way if we forget to update the variables in the alternative language files
	// the English ones are shown.
	if (file_exists("../language/admin-lang-english.php"))
	{
		require ("../language/admin-lang-english.php");
	}
	// Force LOGIN
	$cfgrow_password = $cfgrow['password'];
	$_POST['user'] = $cfgrow['admin'];


	// login is valid, set session
	$_SESSION["pixelpost_admin"] = $cfgrow_password;
	$_GET["_SESSION"]["pixelpost_admin"] = '';
	$_POST["_SESSION"]["pixelpost_admin"] = '';

	if (!isset($_SESSION["pixelpost_admin"]))
	{
		// cookie is not set, send them to a form
		$login = "true";
	}
	else
	{
		// cookie exists, check for validity
		if ($cfgrow['password'] != $_SESSION["pixelpost_admin"]) $login = "true";
	}

	/************************ END OF LOGIN STUFF ************************/

	//------------- addons in admin panel begins
	// refresh the addons table
	$dir = "../addons/";
	refresh_addons_table($dir);

	$addon_admin_functions = array(0 => array('function_name' => '', 'workspace' => '', 'menu_name' => '', 'submenu_name' => ''));
	create_admin_addon_array();

	if ($cfgrow['crop'] == "12c" && isset($_SESSION["pixelpost_admin"]))
	{
		require ("../includes/12cropimageinc.php");
	}
	eval_addon_admin_workspace_menu('admin_html_head');

	eval_addon_admin_workspace_menu('admin_main_menu');


	if (!isset($_SESSION["pixelpost_admin"]) || $cfgrow['password'] != $_SESSION["pixelpost_admin"] || $_GET["_SESSION"]["pixelpost_admin"] == $_SESSION["pixelpost_admin"] || $_POST["_SESSION"]["pixelpost_admin"] == $_SESSION["pixelpost_admin"] || $_COOKIE["_SESSION"]["pixelpost_admin"] == $_SESSION["pixelpost_admin"])
	{
		die("Try another day!!");
	}

	$show_image_after_upload = true; // For default behavior this is set to 'True' you can change this to false in your addons in the new image page

	// save new post
	if ($_GET['x'] == "save")
	{
		$headline = clean($_POST['headline']);
		$body = clean($_POST['body']);

		if (isset($_POST['alt_headline']))
		{
			//Obviously we would like to use the alternative language
			$alt_headline = clean($_POST['alt_headline']);
			$alt_body = clean($_POST['alt_body']);
			$alt_tags = clean($_POST['alt_tags']);
		}
		else
		{
			$alt_headline = "";
			$alt_body = "";
			$alt_tags = "";
		}

		$comments_settings = clean($_POST['allow_comments']);
		$datetime = intval($_POST['post_year']) . "-" . intval($_POST['post_month']) . "-" . intval($_POST['post_day']) . " " . intval($_POST['post_hour']) . ":" . intval($_POST['post_minute']) . ":" . date('s');

		if ($_POST['autodate'] == 1)
		{
			$query = mysql_query("select datetime + INTERVAL 3 DAY from " . $pixelpost_db_prefix . "pixelpost order by datetime desc limit 1");
			$row = mysql_fetch_row($query);
			if ($row) $datetime = $row[0]; // If there is none, will default to the other value
		}
		else
			if ($_POST['autodate'] == 2)
			{
				$datetime = gmdate("Y-m-d H:i:s", time() + (3600 * $cfgrow['timezone']));
			}
			else
				if ($_POST['autodate'] == 3) // exifdate

				{
					// New, JFK: post date from EXIF
					// delay action to later point. We don't know the filename yet...
					// just set a flag so we know what to do later on
					$postdatefromexif = true;
				}
		;

		if ($headline == "")
		{
			echo "
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
		if ($_FILES['userfile'] != "")
		{
			$userfile = strtolower($_FILES['userfile']['name']);
			$tz = $cfgrow['timezone'];

			if ($cfgrow['timestamp'] == 'yes') $time_stamp_r = gmdate("YmdHis", time() + (3600 * $tz)) . '_';

			$uploadfile = $upload_dir . $time_stamp_r . $userfile;

			// NEW WORKSPACE ADDED
			eval_addon_admin_workspace_menu('image_upload_start');

			if (move_uploaded_file($_FILES['userfile']['tmp_name'], $uploadfile))
			{
				chmod($uploadfile, 0644);
				$result = check_upload($_FILES['userfile']['error']);
				$filnamn = strtolower($_FILES['userfile']['name']);
				$filnamn = $time_stamp_r . $filnamn;
				$filtyp = $_FILES['userfile']['type'];
				$filstorlek = $_FILES['userfile']['size'];
				$status = "ok";

				//Get the exif data so we can store it.
				// what about files that don't have exif data??
				include_once ('../includes/functions_exif.php');

				$exif_info_db = serialize_exif($uploadfile);

				if ($postdatefromexif == true)
				{
					// since we all ready escaped everything for database commit we have
					// strip the slashes before we can use the exif again.
					$exif_info = stripslashes($exif_info_db);
					$exif_result = unserialize_exif($exif_info);
					$exposuredatetime = $exif_result['DateTimeOriginalSubIFD'];
					if ($exposuredatetime != '')
					{
						list($exifyear, $exifmonth, $exifday, $exifhour, $exifmin, $exifsec) = split('[: ]', $exposuredatetime);
						$datetime = date("Y-m-d H:i:s", mktime($exifhour, $exifmin, $exifsec, $exifmonth, $exifday, $exifyear));
					}
					else  $datetime = gmdate("Y-m-d H:i:s", time() + (3600 * $tz));
				}
				// NEW WORKSPACE ADDED
				eval_addon_admin_workspace_menu('image_upload_succesful');
			}
			else
			{
				// something went wrong, try to describe what
				if ($_FILES['userfile']['error'] != '0') $result = check_upload($_FILES['userfile']['error']);
				else  $result = "$admin_lang_ni_upload_error ";

				echo "<div id='warning'>$admin_lang_error  ";
				echo "<br/>$result";

				if (!is__writable($upload_dir)) echo "<br/>$admin_lang_pp_img_chmod1";

				echo "</div><hr/>";

				// NEW WORKSPACE ADDED
				eval_addon_admin_workspace_menu('image_upload_failed');
			} // end move
		} // end prepare of file ($_FILES['userfile'] != "")

		// insert post in mysql
		$image = $filnamn;

		if ($status == "ok")
		{
			$query = "INSERT INTO " . $pixelpost_db_prefix . "pixelpost (datetime,headline,body,image,alt_headline,alt_body,comments,exif_info)
			VALUES('$datetime','$headline','$body','$image','$alt_headline','$alt_body','$comments_settings','$exif_info_db')";
			$result = mysql_query($query) || die("Error: " . mysql_error() . $admin_lang_ni_db_error);

			$theid = mysql_insert_id(); //Gets the id of the last added image to use in the next "insert"

				// GPS
				if ($UseGoogleMapAddon == true)
				{
					// since we all ready escaped everything for database commit we have
					// strip the slashes before we can use the exif again.
					$exif_info = stripslashes($exif_info_db);
					$exif_info = unserialize_exif($exif_info);
					// try to get the GPS exif data
					if (array_key_exists('LatitudeGPS', $exif_info))
					{
						if ($exif_info['Latitude ReferenceGPS'] == "S")
						{
							$imagePointLat = '-' . $exif_info['LatitudeGPS'];
						}
						else
						{
							$imagePointLat = $exif_info['LatitudeGPS'];
						}
						if ($exif_info['Longitude ReferenceGPS'] == "W")
						{
							$imagePointLng = '-' . $exif_info['LongitudeGPS'];
						}
						else
						{
							$imagePointLng = $exif_info['LongitudeGPS'];
						}
						$query = "INSERT INTO {$pixelpost_db_prefix}gmapassoc(id, parent_id, lat, lng)
				VALUES(null, '{$theid}', '{$imagePointLat}', '{$imagePointLng}')
				ON DUPLICATE KEY UPDATE lat = '$imagePointLat', lng = '$imagePointLng'";
    					mysql_query($query) or die(mysql_error());
    					// we need to update the cluster table
    					require_once ('../addons/_googlemap/libraries/php/functions.clustertable.php');
    					updateClusterTable();
					}
				}

			if (isset($_POST['category']))
			{
				$query_val = array();

				foreach ($_POST['category'] as $val)
				{
					$val = clean($val);
					$query_val[] = "(NULL,'$val','$theid')";
				}

				$query_st = "INSERT INTO " . $pixelpost_db_prefix . "catassoc (id,cat_id,image_id) VALUES " . implode(",", $query_val) . ";";
				$result = mysql_query($query_st) || die("Error: " . mysql_error());
			}
			// done

			// workspace: image_uploaded
			eval_addon_admin_workspace_menu('image_uploaded');

			// save tags
			save_tags_new(clean($_POST['tags']), $theid);

			// save the alt_tags to if the variable is set
			if ($cfgrow['altlangfile'] != 'Off') save_tags_new(clean($_POST['alt_tags']), $theid, "alt_");

		} // end status ok
	} // end save

	if (isset($status) && $status == 'ok')
	{
		unset($alt_headline, $alt_tags, $alt_body, $_POST['category'], $_POST['autodate'], $_POST['post_year'], $_POST['post_month'], $_POST['post_day'], $_POST['post_hour'], $_POST['post_minute'], $_POST['allow_comments']);
	}

	if ($_GET['x'] == "save" && $status == "ok")
	{
		//create thumbnail
		if (function_exists('gd_info'))
		{
			$gd_info = gd_info();

			if ($gd_info != "")
			{
				$thumbnail = $filnamn;
				$thumbnail = createthumbnail($thumbnail);
				eval_addon_admin_workspace_menu('thumb_created');
			} // end if
		} // function_exists
	}

	// workspace: image_uploaded
	eval_addon_admin_workspace_menu('upload_finished');


	//////// END OF IMAGE UPLOAD SCRIPT ////////

	eval_addon_admin_workspace_menu('admin_main_menu_contents');

	$output = ob_get_contents();
	ob_end_clean();

	if ($status == 'ok')
	{
		// Our job is done...
		// Let the program know!
		echo "OK";
	}
	else
	{
		// ERROR!
		echo "ERROR: \n";
		echo $output;
	}

	// LOGOUT AT END
	unset($_SESSION["pixelpost_admin"]);
	setcookie("pp_user", "", time() - 36000);
	setcookie("pp_password", "", time() - 36000);


} // End if Get View


?>