--[[----------------------------------------------------------------------------

ExportToPixelpost.lua
Main script to drive Pixelpost export process

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
local LrApplication = import 'LrApplication'
local LrExportSession = import 'LrExportSession'
local LrTasks = import 'LrTasks'


LrTasks.startAsyncTask( function()

	local activeCatalog = LrApplication.activeCatalog()
	local filmstrip = activeCatalog.targetPhotos
	
	local exportSession = LrExportSession{
								exportSettings = {
									LR_exportServiceProvider = 'org.pixelpost.lightroom.export.pixelpost',
									privacy = 'private',
								},
								photosToExport = filmstrip }
	
	exportSession:doExportOnCurrentTask()

end )
