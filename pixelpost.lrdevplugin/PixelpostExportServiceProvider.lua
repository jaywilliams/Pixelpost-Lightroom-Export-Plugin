--[[----------------------------------------------------------------------------

PixelpostExportServiceProvider.lua
Export service provider description for Lightroom Pixelpost uploader

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

	-- Lightroom SDK
local LrColor = import "LrColor"

	-- Pixelpost plugin
require 'PixelpostExportDialogSections'
require 'PixelpostUploadTask'


--============================================================================--

return {
	
	hideSections = { 'exportLocation', 'postProcessing' },

	allowFileFormats = { 'JPEG' },
	
	allowColorSpaces = { 'sRGB' },
	
	hidePrintResolution = true,

	--image = "pixelpost_logo.png",
	--image_alignment = "left",
	--background_color = LrColor( "white" ),
	
	exportPresetFields = {
		{ key = 'autoDate', default = '1' },
		{ key = 'allowComments', default = 'A' },
		{ key = 'addTags', default = '' },
		{ key = 'addCategories', default = '' },
		{ key = 'ftpPassword', default = '' },
		{ key = 'postKey', default = '' },
		{ key = 'uploadURL', default = 'http://example.com/admin/pp_upload.php' },
	},

	startDialog = PixelpostExportDialogSections.startDialog,
	sectionsForTopOfDialog = PixelpostExportDialogSections.sectionsForTopOfDialog,
	sectionsForBottomOfDialog = PixelpostExportDialogSections.sectionsForBottomOfDialog,
	
	processRenderedPhotos = PixelpostUploadTask.processRenderedPhotos,
	
}
