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

	-- Can't export until we've validated the login.

	propertyTable.LR_canExport = false

	-- Make sure we're logged in.

	require 'PixelpostUser'
	PixelpostUser.verifyLogin( propertyTable )

	propertyTable:addObserver( 'validAccount',
		function()
			propertyTable.LR_canExport = propertyTable.validAccount
		end )
		
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
					title = bind 'accountStatus',
					alignment = 'right',
					fill_horizontal = 1,
				},

				f:push_button {
					width = 90,
					title = bind 'loginButtonTitle',
					enabled = bind 'loginButtonEnabled',
					action = function()
						require 'PixelpostUser'
						PixelpostUser.login( propertyTable )
					end,
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
	
		-- {
		-- 	title = LOC "$$$/Pixelpost/ExportDialog/PrivacyAndSafety=Privacy and Safety",
		-- 	synopsis = function( props )
		-- 		
		-- 		local summary = {}
		-- 		
		-- 		local function add( x )
		-- 			if x then
		-- 				summary[ #summary + 1 ] = x
		-- 			end
		-- 		end
		-- 		
		-- 		if props.privacy == 'private' then
		-- 			add( LOC "$$$/Pixelpost/ExportDialog/Private=Private" )
		-- 			if props.privacy_family then
		-- 				add( LOC "$$$/Pixelpost/ExportDialog/Family=Family" )
		-- 			end
		-- 			if props.privacy_friends then
		-- 				add( LOC "$$$/Pixelpost/ExportDialog/Friends=Friends" )
		-- 			end
		-- 		else
		-- 			add( LOC "$$$/Pixelpost/ExportDialog/Public=Public" )
		-- 		end
		-- 		
		-- 		local safetyStr = kSafetyTitles[ props.safety ]
		-- 		if safetyStr then
		-- 			add( safetyStr )
		-- 		end
		-- 		
		-- 		-- Etc. (rest left as an exercise for the reader)
		-- 		
		-- 		return table.concat( summary, " / " )
		-- 		
		-- 	end,
		-- 	
		-- 	place = 'horizontal',
		-- 	
		-- 			f:column {
		-- 				spacing = f:control_spacing() / 2,
		-- 				fill_horizontal = 1,
		-- 	
		-- 				f:row {
		-- 					f:static_text {
		-- 						title = LOC "$$$/Pixelpost/ExportDialog/Privacy=Privacy:",
		-- 						alignment = 'right',
		-- 						width = share 'labelWidth',
		-- 					},
		-- 	
		-- 					f:radio_button {
		-- 						title = LOC "$$$/Pixelpost/ExportDialog/Private=Private",
		-- 						checked_value = 'private',
		-- 						value = bind 'privacy',
		-- 					},
		-- 				},
		-- 	
		-- 				f:row {
		-- 					f:spacer {
		-- 						width = share 'labelWidth',
		-- 					},
		-- 	
		-- 					f:column {
		-- 						spacing = f:control_spacing() / 2,
		-- 						margin_left = 15,
		-- 						margin_bottom = f:control_spacing() / 2,
		-- 		
		-- 						f:checkbox {
		-- 							title = LOC "$$$/Pixelpost/ExportDialog/Family=Family",
		-- 							value = bind 'privacy_family',
		-- 							enabled = LrBinding.keyEquals( 'privacy', 'private' ),
		-- 						},
		-- 		
		-- 						f:checkbox {
		-- 							title = LOC "$$$/Pixelpost/ExportDialog/Friends=Friends",
		-- 							value = bind 'privacy_friends',
		-- 							enabled = LrBinding.keyEquals( 'privacy', 'private' ),
		-- 						},
		-- 					},
		-- 				},
		-- 	
		-- 				f:row {
		-- 					f:spacer {
		-- 						width = share 'labelWidth',
		-- 					},
		-- 	
		-- 					f:radio_button {
		-- 						title = LOC "$$$/Pixelpost/ExportDialog/Public=Public",
		-- 						checked_value = 'public',
		-- 						value = bind 'privacy',
		-- 					},
		-- 				},
		-- 			},
		-- 	
		-- 			f:column {
		-- 				spacing = f:control_spacing() / 2,
		-- 	
		-- 				fill_horizontal = 1,
		-- 	
		-- 				f:row {
		-- 					f:static_text {
		-- 						title = LOC "$$$/Pixelpost/ExportDialog/Safety=Safety:",
		-- 						alignment = 'right',
		-- 						width = share 'pixelpost_col2_label_width',
		-- 					},
		-- 	
		-- 					f:popup_menu {
		-- 						value = bind 'safety',
		-- 						width = share 'pixelpost_col2_popup_width',
		-- 						items = {
		-- 							{ title = kSafetyTitles.safe, value = 'safe' },
		-- 							{ title = kSafetyTitles.moderate, value = 'moderate' },
		-- 							{ title = kSafetyTitles.restricted, value = 'restricted' },
		-- 						},
		-- 					},
		-- 				},
		-- 	
		-- 				f:row {
		-- 					margin_bottom = f:control_spacing() / 2,
		-- 					
		-- 					f:spacer {
		-- 						width = share 'pixelpost_col2_label_width',
		-- 					},
		-- 	
		-- 					f:checkbox {
		-- 						title = LOC "$$$/Pixelpost/ExportDialog/HideFromPublicSite=Hide from public site areas",
		-- 						value = bind 'hideFromPublic',
		-- 					},
		-- 				},
		-- 	
		-- 				f:row {
		-- 					f:static_text {
		-- 						title = LOC "$$$/Pixelpost/ExportDialog/Type=Type:",
		-- 						alignment = 'right',
		-- 						width = share 'pixelpost_col2_label_width',
		-- 					},
		-- 	
		-- 					f:popup_menu {
		-- 						width = share 'pixelpost_col2_popup_width',
		-- 						value = bind 'type',
		-- 						items = {
		-- 							{ title = LOC "$$$/Pixelpost/ExportDialog/Type/Photo=Photo", value = 'photo' },
		-- 							{ title = LOC "$$$/Pixelpost/ExportDialog/Type/Screenshot=Screenshot", value = 'screenshot' },
		-- 							{ title = LOC "$$$/Pixelpost/ExportDialog/Type/Other=Other", value = 'other' },
		-- 						},
		-- 					},
		-- 				},
		-- 			},
		-- 		},
		-- 	
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
						{ title = "Post one day after last post", value = '1' },
						{ title = "Use exif date", value = '3' },
					},
				},
--[[
				f:push_button {
					title = LOC "$$$/Pixelpost/ExportDialog/NewPhotoset=New Photoset",
					--action = function() createNewPhotoset( propertyTable ) end,
						-- TO DO: Add a new photo set dialog.
]]--				},

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
				{ title = "Publish Instanty", value = 'A' },
				{ title = "To Moderation Que", value = 'M' },
				{ title = "Disable Commenting", value = 'F' },
			},
		},		
			},	
		
		},

	}

end
