--[[----------------------------------------------------------------------------

PixelpostUser.lua
Pixelpost user account management

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
local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'

local prefs = import 'LrPrefs'.prefsForPlugin()


--============================================================================--

PixelpostUser = {}

--------------------------------------------------------------------------------

local function storedCredentialsAreValid()

	return prefs.token -- and prefs.nsid and prefs.username and prefs.fullname

end

--------------------------------------------------------------------------------

local function notLoggedIn( propertyTable )

	propertyTable.token = nil
	
	-- prefs.nsid = nil
	-- prefs.username = nil
	-- prefs.fullname = nil
	prefs.postKey = nil
	prefs.uploadURL = nil
	prefs.token = nil

	propertyTable.accountStatus = LOC "$$$/Pixelpost/AccountStatus/NotLoggedIn=This plugin must have a valid Post Key & URL before it can be used."
	propertyTable.loginButtonTitle = LOC "$$$/Pixelpost/LoginButton/NotLoggedIn=Enter Key"
	propertyTable.loginButtonEnabled = true
	propertyTable.validAccount = false

end

--------------------------------------------------------------------------------

local doingLogin = false

function PixelpostUser.login( propertyTable )

	if doingLogin then return end
	doingLogin = true

	LrFunctionContext.postAsyncTaskWithContext( 'Validate',
	function( context )

		-- Clear any existing login info.
	
		notLoggedIn( propertyTable )

		propertyTable.accountStatus = LOC "$$$/Pixelpost/AccountStatus/LoggingIn=Validating..."
		propertyTable.loginButtonEnabled = false
		
		-- Make sure login is valid when done, or is marked as invalid.
		
		context:addCleanupHandler( function()

			doingLogin = false

			if not storedCredentialsAreValid() then
				notLoggedIn( propertyTable )
			end
			
			-- Hrm. New API doesn't make it easy to show what operation failed.
			-- LrDialogs.message( LOC "$$$/Pixelpost/LoginFailed=Failed to connect to Pixelpost" )

		end )
		
		-- Make sure we have an Post key.
		
		PixelpostAPI.getPostKeyAndURL()

		-- Show request for authentication dialog.
	
		-- local authRequestDialogResult = LrDialogs.confirm(
		-- 			LOC "$$$/Pixelpost/AuthRequestDialog/Message=Lightroom needs your permission to upload images to your Pixelpost photoblog.",
		-- 			LOC "$$$/Pixelpost/AuthRequestDialog/HelpText=If you click Authorize, you will be taken to a web page in your web browser where you can log in. When you're finished, return to Lightroom to complete the authorization.",
		-- 			LOC "$$$/Pixelpost/AuthRequestDialog/AuthButtonText=Authorize",
		-- 			LOC "$$$/LrDialogs/Cancel=Cancel" )
		-- 	
		-- 		if authRequestDialogResult == 'cancel' then
		-- 			return
		-- 		end
	
		-- Request the frob that we need for authentication.
		
		propertyTable.accountStatus = LOC "$$$/Pixelpost/AccountStatus/WaitingForPixelpost=Waiting for response from server..."

		require 'PixelpostAPI'
		-- local frob = PixelpostAPI.openAuthUrl()
	
		-- local waitForAuthDialogResult = LrDialogs.confirm(
		-- 	LOC "$$$/Pixelpost/WaitForAuthDialog/Message=Return to this window once you've authorized Lightroom on pixelpost.org.",
		-- 	LOC "$$$/Pixelpost/WaitForAuthDialog/HelpText=Once you've granted permission for Lightroom (in your web browser), click the Done button below.",
		-- 	LOC "$$$/Pixelpost/WaitForAuthDialog/DoneButtonText=Done",
		-- 	LOC "$$$/LrDialogs/Cancel=Cancel" )
		-- 	
		-- if waitForAuthDialogResult == 'cancel' then
		-- 	return
		-- end
	
		-- User has OK'd authentication. Get the user info.
		
		-- propertyTable.accountStatus = LOC "$$$/Pixelpost/AccountStatus/WaitingForPixelpost=Waiting for response..."

		local data = PixelpostAPI.callRestmode{ mode = 'validate', frob = frob }
		
		-- Now we can read the Pixelpost user credentials. Save off to prefs.
	
		-- local auth = assert( data.auth )
	
		-- prefs.nsid = auth.user.nsid
		-- prefs.username = auth.user.username
		-- prefs.fullname = auth.user.fullname
		-- prefs.token = auth.token._value
		-- propertyTable.token = prefs.token
		
			prefs.token = 'OK'
			propertyTable.token = 'OK'
		
	end )

end

--------------------------------------------------------------------------------

function PixelpostUser.verifyLogin( propertyTable )

	-- Observe changes to prefs and update status message accordingly.

	local function updateStatus()
	
		if storedCredentialsAreValid() then
			-- local displayUserName = prefs.fullname
			-- if not displayUserName or #displayUserName == 0 then
				-- displayUserName = prefs.username
			-- end
			-- propertyTable.accountStatus = LOC( "$$$/Pixelpost/AccountStatus/LoggedIn=Logged in as ^1", displayUserName )
			propertyTable.accountStatus = LOC "$$$/Pixelpost/AccountStatus/LoggedIn=Ready to upload"
			propertyTable.loginButtonTitle = LOC "$$$/Pixelpost/LoginButton/LoggedIn=Change Key"
			propertyTable.loginButtonEnabled = true
			propertyTable.LR_canExport = true
		else
			notLoggedIn( propertyTable )
		end
	
	end

	propertyTable:addObserver( 'token', updateStatus )
	updateStatus()
	
end
