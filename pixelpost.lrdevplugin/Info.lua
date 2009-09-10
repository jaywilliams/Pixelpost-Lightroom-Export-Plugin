--[[----------------------------------------------------------------------------

Info.lua
Summary information for Pixelpost sample plugin

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.


------------------------------------------------------------------------------]]

return {

	LrSdkVersion = 2.0,
	LrSdkMinimumVersion = 2.0, -- minimum SDK version required by this plugin

	LrToolkitIdentifier = 'org.pixelpost.lightroom.export.pixelpost',
	LrPluginName = LOC "$$$/Pixelpost/Pixelpost=Pixelpost",
	
	-- LrLibraryMenuItems = {
	-- 	title = LOC "$$$/Pixelpost/ExportUsingDefaults=Export to Pixelpost Using Defaults",
	-- 	file = 'ExportToPixelpost.lua',
	-- 	enabledWhen = 'photosAvailable',
	-- },
	
	-- LrExportMenuItems = {
	-- 	-- {
	-- 	-- 	title = LOC "$$$/Pixelpost/EnterAPIKey=Enter Pixelpost Post Key...",
	-- 	-- 	file = 'EnterPostKey.lua',
	-- 	-- },
	-- 	{
	-- 		title = LOC "$$$/Pixelpost/ExportUsingDefaults=Export to Pixelpost Using Defaults",
	-- 		file = 'ExportToPixelpost.lua',
	-- 		enabledWhen = 'photosAvailable',
	-- 	},
	-- },
	
	LrExportServiceProvider = {
		title = LOC "$$$/Pixelpost/Pixelpost=Pixelpost",
		file = 'PixelpostExportServiceProvider.lua',
		builtInPresetsDir = "presets",
	},
	
	VERSION = { major=2, minor=0, revision=0, build=2, },

}
