--[[----------------------------------------------------------------------------

PixelpostExportDialogSections.lua
Export dialog customization for Lightroom Pixelpost uploader

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
local LrBinding = import 'LrBinding'
local LrView = import "LrView"

local bind = LrView.bind
local share = LrView.share

--============================================================================--

PixelpostExportDialogSections = {}

-------------------------------------------------------------------------------

function PixelpostExportDialogSections.startDialog( propertyTable )
end

-------------------------------------------------------------------------------

function PixelpostExportDialogSections.sectionsForTopOfDialog( f, propertyTable )

	return {
	
		{
			title = LOC "$$$/Pixelpost/ExportDialog/Account=Pixelpost Account",
			
			synopsis = bind 'accountStatus',

			f:row {
				spacing = f:control_spacing(),

				f:static_text {
					title = LOC "$$$/Pixelpost/ExportDialog/UploadURL=Upload Url:",
					width = share 'labelWidth',
					alignment = 'right',
				},
				
				f:edit_field {
					value = bind 'uploadURL',
					width_in_chars = 40
				},
			},
			f:row {
				spacing = f:control_spacing(),

				f:static_text {
					title = LOC "$$$/Pixelpost/ExportDialog/postKey=Post Key:",
					width = share 'labelWidth',
					alignment = 'right',
				},
				
				f:password_field {
					value = bind 'postKey',
					width_in_chars = 40
				},
			},
		},
	
	}

end

-------------------------------------------------------------------------------

local kSafetyTitles = {
	safe = LOC "$$$/Pixelpost/ExportDialog/Safety/Safe=Safe",
	moderate = LOC "$$$/Pixelpost/ExportDialog/Safety/Moderate=Moderate",
	restricted = LOC "$$$/Pixelpost/ExportDialog/Safety/Restricted=Restricted",
}

function PixelpostExportDialogSections.sectionsForBottomOfDialog( f, propertyTable )

	return {
		{
			title = LOC "$$$/Pixelpost/ExportDialog/Organize=Batch Publish Options",

			spacing = f:control_spacing() / 2,

--[[			-- out of time to implement this]]--
			f:row {
				margin_bottom = f:control_spacing() / 2,

				f:static_text {
					title = LOC "$$$/Pixelpost/ExportDialog/autoDate=Date & Time:",
					alignment = 'right',
					width = share 'labelWidth',
				},

				f:popup_menu {
					value = bind 'autoDate', 
					-- enabled = bind 'addToPhotoset',
					items = {
						-- TO DO: Should really be populated from live data. ;-)
						{ title = "Post Now", value = '2' },
						{ title = "Post Three Days After Last Post", value = '1' },
						{ title = "Use EXIF Date", value = '3' },
					},
				},
			},


			f:row {
				f:static_text {
					title = LOC "$$$/Pixelpost/ExportDialog/AddTags=Add Tags:",
					alignment = 'right',
					width = share 'labelWidth',
				},

				f:edit_field {
					value = bind 'addTags',
					fill_horizontal = 1,
				},
			},

			f:row {
				f:spacer {
					width = share 'labelWidth',
				},

				f:static_text {
					title = LOC "$$$/Pixelpost/ExportDialog/TagMergeNote=These tags will be combined with the exported keywords from each photo.",
					fill_horizontal = 1,
					height_in_lines = 2,
					width_in_chars = 32,
				},
			},
			
			-- Categories:
			
			f:row {
				f:static_text {
					title = LOC "$$$/Pixelpost/ExportDialog/AddTags=Add Categories:",
					alignment = 'right',
					width = share 'labelWidth',
				},

				f:edit_field {
					value = bind 'addCategories',
					fill_horizontal = 1,
				},
			},

			f:row {
				f:spacer {
					width = share 'labelWidth',
				},

				f:static_text {
					title = LOC "$$$/Pixelpost/ExportDialog/TagMergeNote=You can enter specfic categores you would like each photo to be included in.",
					fill_horizontal = 1,
					height_in_lines = 2,
					width_in_chars = 32,
				},
			},
			
		f:row {
			margin_bottom = f:control_spacing() / 2,

			f:static_text {
				title = LOC "$$$/Pixelpost/ExportDialog/allowComments=Comment Settings:",
				alignment = 'right',
				width = share 'labelWidth',
			},

		f:popup_menu {
			value = bind 'allowComments', 
			-- enabled = bind 'addToPhotoset',
			items = {
				-- TO DO: Should really be populated from live data. ;-)
				{ title = "Publish Instantly", value = 'A' },
				{ title = "To Moderation Que", value = 'M' },
				{ title = "Disable Commenting", value = 'F' },
			},
		},		
			},	
		
			-- Categories:
			
			f:row {
				f:static_text {
					title = LOC "$$$/Pixelpost/ExportDialog/ftpPassword=FTP password:",
					alignment = 'right',
					width = share 'labelWidth',
				},

				f:password_field {
					value = bind 'ftpPassword',
					fill_horizontal = 1,
				},
			},

			f:row {
				f:spacer {
					width = share 'labelWidth',
				},

				f:static_text {
					title = LOC "$$$/Pixelpost/ExportDialog/FTPNote=When using the \"FTP_permissions Addon\", which changes the CHMOD settings of the image and thumbnails folder, you need to supply the FTP password.",
					fill_horizontal = 1,
					height_in_lines = 2,
					width_in_chars = 32,
				},
			},
		
		},

	}

end
