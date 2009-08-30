--[[----------------------------------------------------------------------------

PixelpostUploadTask.lua
Upload photos to Pixelpost

--------------------------------------------------------------------------------

ADOBE SYSTEMS INCORPORATED
 Copyright 2007 Adobe Systems Incorporated
 All Rights Reserved.

NOTICE: Adobe permits you to use, modify, and distribute this file in accordance
with the terms of the Adobe license agreement accompanying it. If you have received
this file from a source other than Adobe, then your use, modification, or distribution
of it requires the prior written permission of Adobe.

------------------------------------------------------------------------------]]

	-- Lightroom API
local LrDialogs = import 'LrDialogs'
local LrErrors = import 'LrErrors'
local LrFileUtils = import 'LrFileUtils'
local LrHttp = import 'LrHttp'
local LrPathUtils = import 'LrPathUtils'

	-- Pixelpost plugin
require 'PixelpostAPI'


--============================================================================--

PixelpostUploadTask = {}

--------------------------------------------------------------------------------
-- Map Lightroom dialog property values to Pixelpost API values.

local function booleanToNumber( value )
	return value and 1 or 0
end

local privacyToNumber = {
	private = 0,
	public = 1,
}

local safetyToNumber = {
	safe = 1,
	moderate = 2,
	restricted = 3,
}

local contentTypeToNumber = {
	photo = 1,
	screenshot = 2,
	other = 3,
}

--------------------------------------------------------------------------------

local function checkForPreviousUploads( exportSession )

	-- Check for photos that have been uploaded already.

	local existingPixelpostIds = {}
			-- key: (LrPhoto)
			-- value: Pixelpost photo ID from previous upload

	local numExisting = 0

	exportSession.catalog:withCatalogDo( function()

		for photo in exportSession:photosToExport() do
	
			photo:withSettingsForPluginDo( 'org.pixelpost.lightroom.export.pixelpost', function( settings )
	
				local pixelpostPhotoId = settings.photo_id
				if pixelpostPhotoId then
					numExisting = numExisting + 1
					existingPixelpostIds[ photo ] = pixelpostPhotoId
				end
	
				return false -- hint that nothing was changed
		
			end )
	
		end
	
	end )

	-- If there were pre-existing photos, ask the user what to do about them.
	
	if numExisting > 0 then

		-- Ask user what to do about existing images.
		
		local response = LrDialogs.confirm(
							LOC "$$$/Pixelpost/AlreadyUploaded/Error=Some of these images have been uploaded already. What would you like to do?",
							LOC "$$$/Pixelpost/AlreadyUploaded/Hint=",
							LOC "$$$/Pixelpost/AlreadyUploaded/ActionSkip=Skip",
							LOC "$$$/LrDialogs/Cancel=Cancel",
							LOC "$$$/Pixelpost/AlreadyUploaded/ActionReplace=Replace" )
		
		if response == 'cancel' then
			LrErrors.throwCanceled()
		end
		
		if response == 'ok' then
		
			-- User said "Skip" these images. Remove them from the export manifest.
			
			for photo in pairs( existingPixelpostIds ) do
				exportSession:removePhoto( photo )
			end
	
		end
	
	end
	
	-- Return the map of photos to existing Pixelpost IDs.
		
	return existingPixelpostIds

end

--------------------------------------------------------------------------------

function PixelpostUploadTask.processRenderedPhotos( functionContext, exportContext )


	local postKey, uploadURL = PixelpostAPI.getPostKeyAndURL()

	-- Check for photos that have been uploaded already.
	
	local exportSession = exportContext.exportSession
	local existingPixelpostIds = checkForPreviousUploads( exportSession )

	-- Make a local reference to the export parameters.
	
	local exportParams = exportContext.propertyTable
	
	-- Set progress title.

	local nPhotos = exportSession:countRenditions()

	local progressScope = exportContext:configureProgress{
						title = nPhotos > 1
									and LOC( "$$$/Pixelpost/Upload/Progress=Uploading ^1 photos to Pixelpost", nPhotos )
									or LOC "$$$/Pixelpost/Upload/Progress/One=Uploading one photo to Pixelpost",
					}

	-- Save off uploaded photo IDs so we can take user to those photos later.
	
	local uploadedPhotoIds = {}

	-- Iterate through photo renditions.

	for i, rendition in exportContext:renditions{ stopIfCanceled = true } do
	
		-- Get next photo.

		local photo = rendition.photo
		local success, pathOrMessage = rendition:waitForRender()
		
		-- Check for cancellation again after photo has been rendered.
		
		if progressScope:isCanceled() then break end
		
		if success then

			-- Build up common metadata for this photo.
	
			local title, description,tags
			
			photo.catalog:withCatalogDo( function()

				title = photo:getFormattedMetadata 'title'
				if not title or #title == 0 then
					title = LrPathUtils.leafName( pathOrMessage )
				end
				
				description = photo:getFormattedMetadata 'caption'
			
			
				-- Merge XMP & specfied Export tags
				tags1 = photo:getFormattedMetadata 'keywordTags'
				
				tags2 = exportParams.addTags
				
				if not tags1 or #tags1 == 0 then
					tags1 = ''
				end
				
				if not tags2 or #tags2 == 0 then
					tags2 = ''
				end

				tags =	string.format( '%s, %s', tags1, tags2 )
											
				
				
			end )
			
			
			-- local tags
			
			local content_type = contentTypeToNumber[ exportParams.contentType ]
			local categories = exportParams.addCategories
			local autoDate = exportParams.autoDate
			local allowComments = exportParams.allowComments
			
			-- See if we previously uploaded this photo.
			
			local pixelpostPhotoId

--[[		TO DO: Hold off on this until we can replace photos...
			photo:withSettingsForPluginDo( 'org.pixelpost.lightroom.export.pixelpost', function( settings )

				pixelpostPhotoId = settings.photo_id
	
				return false -- hint that nothing was changed
		
			end )
]]--

			-- Upload or replace the photo.
			
			if pixelpostPhotoId then
			
				error "TO DO: Not yet ready to replace existing photos on Pixelpost."
			
			else
				pixelpostPhotoId = PixelpostAPI.uploadPhoto{
										filePath = pathOrMessage,
										title = title,
										description = description,
										tags = tags,
										categories = categories,
										autodate = autoDate,
										allow_comments = allowComments,
									}
				
				-- TO DO: Delete the individual photo file after completion.
				-- Note: This is just a better space-saving operation. LR
				-- will delete the folder of generated files at the end of the
				-- export since we requested that they be written to a temporary
				-- location.
	
				-- Record this Pixelpost ID with the photo so we know to replace
				-- instead of upload.
				
				photo.catalog:withCatalogDo( function()

					photo:withSettingsForPluginDo( 'org.pixelpost.lightroom.export.pixelpost', function( settings )
				
						settings.photo_id = pixelpostPhotoId

					end )
				
				end )
			
				-- When done with photo, delete temp file. There is a cleanup step that happens later,
				-- but this will help manage space in the event of a large upload.
				
				LrFileUtils.delete( pathOrMessage )
				
			end
			
			-- Remember this in the list of photos we uploaded.

			uploadedPhotoIds[ #uploadedPhotoIds + 1 ] = pixelpostPhotoId
		
		end
		
	end

	-- Take user to uploaded photos.
	
		-- TO DO: What happens if there are 1000 photos uploaded?
	
	if #uploadedPhotoIds > 0 then
		
		-- local newPhotosURL = uploadURL .. '?ids=' .. table.concat( uploadedPhotoIds, ',' )
		-- LrHttp.openUrlInBrowser( newPhotosURL )
	end

end
