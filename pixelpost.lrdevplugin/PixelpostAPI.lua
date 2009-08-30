--[[----------------------------------------------------------------------------

PixelpostAPI.lua
Common code to initiate Pixelpost API requests

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
local LrErrors = import 'LrErrors'
local LrFunctionContext = import 'LrFunctionContext'
local LrHttp = import 'LrHttp'
local LrMD5 = import 'LrMD5'
local LrPathUtils = import 'LrPathUtils'
local LrTasks = import 'LrTasks'
local LrView = import 'LrView'
local LrXml = import 'LrXml'

local prefs = import 'LrPrefs'.prefsForPlugin()

local bind = LrView.bind
local share = LrView.share


local logger = import 'LrLogger'( 'PixelpostAPI' )

-- Commment this out if you want log files disabled:
logger:enable('logfile')

local debug, info, warn, err = logger:quick( 'debug', 'info', 'warn', 'err' )



--============================================================================--

PixelpostAPI = {}

--------------------------------------------------------------------------------

local simpleXmlMetatable = {
	__tostring =	-- This isn't supposed to be picked up by LuaDocs
		function( self ) return self._value end
}

--------------------------------------------------------------------------------

local traverse

traverse = function( node )

	local type = string.lower( node:type() )

	if type == "element" then
		local element = setmetatable( {}, simpleXmlMetatable )
		element._name = node:name()
		element._value = node.text and node:text() or nil
		
		local count = node:childCount()
		for i = 1,count do
			local name, value = traverse( node:childAtIndex( i ) )
			if name and value then
				element[ name ] = value
			end
		end

		if type == 'element' then
			for k,v in pairs( node:attributes() ) do
				element[ k ] = v.value
			end
		end
		
		return element._name, element
	end

end

--------------------------------------------------------------------------------

local function xmlElementToSimpleTable( xmlString )
	local name, value = traverse( LrXml.parseXml( xmlString ) )
	return value
end

--------------------------------------------------------------------------------

-- We can't include a Pixelpost Post key with the source code for this plugin, so
-- we require you obtain one on your own and enter it through this dialog.

--------------------------------------------------------------------------------

function PixelpostAPI.showPostKeyDialog( message )

	LrFunctionContext.callWithContext( 'PixelpostAPI.showPostKeyDialog', function( context )

		local f = LrView.osFactory()
	
		local properties = LrBinding.makePropertyTable( context )
		properties.postKey = prefs.postKey
		properties.uploadURL = prefs.uploadURL
	
		local contents = f:column {
			bind_to_object = properties,
			spacing = f:control_spacing(),
			fill = 1,
	
			f:static_text {
				title = LOC "$$$/Pixelpost/PostKeyDialog/Message=In order to use this plugin, you must obtain an Post key from your Pixelpost photoblog. Login to your photoblog and go to the Addons page.  There it will display the current Post Key & URL.",
				fill_horizontal = 1,
				width_in_chars = 55,
				height_in_lines = 2,
				size = 'small',
			},
	
			message and f:static_text {
				title = message,
				fill_horizontal = 1,
				width_in_chars = 55,
				height_in_lines = 2,
				size = 'small',
				text_color = import 'LrColor'( 1, 0, 0 ),
			} or 'skipped item',
			
			f:row {
				spacing = f:label_spacing(),
				
				f:static_text {
					title = LOC "$$$/Pixelpost/PostKeyDialog/Key=Post Key:",
					alignment = 'right',
					width = share 'title_width',
				},
				
				f:edit_field { 
					fill_horizonal = 2,
					width_in_chars = 35, 
					height_in_lines = 2,
					value = bind 'postKey',
						-- TO DO: Should validate Post key (16 hex digits, etc.).
				},
			},
			
			f:row {
				spacing = f:label_spacing(),
				
				f:static_text {
					title = LOC "$$$/Pixelpost/PostKeyDialog/URL=Upload URL:",
					alignment = 'right',
					width = share 'title_width',
				},
				
				f:edit_field { 
					fill_horizonal = 2,
					width_in_chars = 35, 
					height_in_lines = 2,
					value = bind 'uploadURL',
				},
			},
		}
		
		local result = LrDialogs.presentModalDialog( 
			{
				title = LOC "$$$/Pixelpost/PostKeyDialog/Title=Enter Your Pixelpost Post Key", 
				contents = contents,
				-- accessoryView = f:push_button {
				-- 	title = LOC "$$$/Pixelpost/PostKeyDialog/GoToPixelpost=Where do I find my Post Key?",
				-- 	action = function()
				-- 		LrHttp.openUrlInBrowser( "http://www.pixelpost.org/services/api/keys/" )
				-- 	end
				-- },
			} 
		)
		
		if result == 'ok' then
	
			prefs.postKey = properties.postKey
			prefs.uploadURL = properties.uploadURL
		
		else
		
			LrErrors.throwCanceled()
		
		end
	
	end )
	
end

--------------------------------------------------------------------------------

function PixelpostAPI.getPostKeyAndURL()

	local postKey, uploadURL, message = prefs.postKey, prefs.uploadURL
	
	while not(
		type( postKey ) == 'string' and #postKey > 6 and
		type( uploadURL ) == 'string' and #uploadURL > 35 -- and string.sub(#uploadURL,0,7)  == 'http://'
	) do
	
		local message
		-- if postKey then
			message = LOC "$$$/Pixelpost/PostKeyDialog/Invalid=Please make sure you have filled out both the Post Key & the URL entirely."
		-- end
		
		-- if uploadURL then
		-- 	message = LOC "$$$/Pixelpost/PostKeyDialog/Invalid=The url below is too short."
		-- 	-- message = string.sub(#uploadURL,7)
		-- end

		PixelpostAPI.showPostKeyDialog( message )

		postKey, uploadURL = prefs.postKey, prefs.uploadURL
	
	end
	
	return postKey, uploadURL

end

--------------------------------------------------------------------------------

function PixelpostAPI.makeApiSignature( params )

	-- If no Post key, add it in now.
	
	local postKey, uploadURL = PixelpostAPI.getPostKeyAndURL()
	
	if not params.post_key_hash then
		-- params.post_key = postKey
		params.post_key_hash = LrMD5.digest(postKey)
	end

	-- Get list of arguments in sorted order.

	local argNames = {}
	for name in pairs( params ) do
		table.insert( argNames, name )
	end
	
	table.sort( argNames )

	-- Build the secret string to be MD5 hashed.
	
	local allArgs = uploadURL
	for _, name in ipairs( argNames ) do
		if params[ name ] then  -- might be false
			allArgs = string.format( '%s%s%s', allArgs, name, params[ name ] )
		end
	end
	
	-- MD5 hash this string.

	return LrMD5.digest( allArgs )

end

--------------------------------------------------------------------------------

function PixelpostAPI.callRestmode( params )

	-- Automatically add Post key.
	
	local postKey, uploadURL = PixelpostAPI.getPostKeyAndURL()
	
	if not params.post_key_hash then
		params.post_key_hash = LrMD5.digest(postKey)
	end
	
	-- Build up the URL for this function.
	
	-- params.api_sig = PixelpostAPI.makeApiSignature( params ) 
	local url = string.format( '%s?mode=%s', uploadURL ,assert( params.mode ) )
	
	for name, value in pairs( params ) do

		if name ~= 'mode' and value then  -- the 'and value' clause allows us to ignore false

			-- URL encode each of the params.
			
			value = string.gsub( value, '([^ !#-$&-*,%-%.0-;@-~])', function( c ) return string.format( '%%%02X', string.byte( c ) ) end )
			value = string.gsub( value, ' ', '+' )
			params[ name ] = value

			url = string.format( '%s&%s=%s', url, name, value )

		end

	end

	-- Call the URL and wait for response.

	info( 'calling Pixelpost API via URL:', url )

	local response = LrHttp.get( url )

	-- All responses are XML. Parse it now.

	-- local simpleXml = xmlElementToSimpleTable( response )
	
	if response == 'OK' then
		info( 'Pixelpost API returned status OK' )
		return response
	else

		warn( 'Pixelpost API returned error', response )

		LrErrors.throwUserError( LOC "$$$/Pixelpost/Error/API=Oh no!\nIt looks like we were unable to connect to Pixelpost! Please verify that your Post Key & URL are set correctly.")
	end
	


	-- if simpleXml.stat == 'ok' then
	-- 
	-- 	info( 'Pixelpost API returned status OK' )
	-- 	return simpleXml, response
	-- 
	-- else
	-- 
	-- 	warn( 'Pixelpost API returned error', simpleXml.err and simpleXml.err.msg )
	-- 
	-- 	LrErrors.throwUserError( LOC( "$$$/Pixelpost/Error/API=Pixelpost API returned an error message (function ^1, message ^2)",
	-- 						tostring( params.mode ),
	-- 						tostring( simpleXml.err and simpleXml.err.msg ) ) )
	-- 
	-- end

end

--------------------------------------------------------------------------------

function PixelpostAPI.uploadPhoto( params )

	-- Prepare to upload.
	
	assert( type( params ) == 'table', 'PixelpostAPI.uploadPhoto: params must be a table' )
	
	local postKey, uploadURL = PixelpostAPI.getPostKeyAndURL()
	
	-- local uploadURL = params.photo_id and uploadURL or uploadURL
	
	-- if params.photo_id
	-- end
	
	
	
	-- local postUrl = params.photo_id and 'http://pixelpost.org/services/replace/' or 'http://pixelpost.org/services/upload/'
	
	-- local params.photo_id = uploadURL

	info( 'uploading photo', params.filePath )
	info( 'password', params.ftppassword )
	info( 'autoDate', params.autodate )
	info( 'postKey', postKey )
	info( 'uploadURL', uploadURL )

	local filePath = assert( params.filePath )
	params.filePath = nil
	
	local fileName = LrPathUtils.leafName( filePath )
	
	-- params.auth_token = params.auth_token or prefs.token
	
	-- if not params.post_key_hash then
		-- params.post_key = postKey
		-- params.post_key_hash = LrMD5.digest(postKey)
	-- end
	-- parms.post_key = postKey
	-- parms.mode = 'upload'
	-- params.api_sig = PixelpostAPI.makeApiSignature( params )
	local post_key_hash = LrMD5.digest(postKey)
	
	
	local mimeChunks = {}
	
	for argName, argValue in pairs( params ) do
		if argName ~= 'post_key_hash' then
			mimeChunks[ #mimeChunks + 1 ] = { name = argName, value = argValue }
			info( argName, argValue )
		end
	end

	-- mimeChunks[ #mimeChunks + 1 ] = { name = 'api_sig', value = params.api_sig }
	mimeChunks[ #mimeChunks + 1 ] = { name = 'photo', fileName = fileName, filePath = filePath, contentType = 'application/octet-stream' }
	
	-- Post it and wait for confirmation.
	
	-- local url = tostring( uploadURL,'?post_key_hash=',post_key_hash)
	
	local post_url = string.format( '%s?post_key_hash=%s&mode=upload',
						uploadURL, post_key_hash )
	
	info( 'post_url: ' .. post_url )
	-- info( 'uploadURL: ' ..  uploadURL )
	
	local result = LrHttp.postMultipart( post_url , mimeChunks )
	
	-- Parse Pixelpost response for photo ID.
	-- info( 'result: ' ..  result )

	if result == 'OK' then
		return result
	else
		-- LrErrors.throwUserError( LOC( "$$$/Pixelpost/Error/API/Upload=Pixelpost API returned an error message (function upload, message ^1)",
							-- tostring( result ) ) )
		warn( 'Pixelpost API returned error', result )					
		LrErrors.throwUserError( LOC "$$$/Pixelpost/Error/API=Oh no!\nIt looks like we were unable to connect to Pixelpost! Please verify that your Post Key & URL are set correctly.")
		
	end
	

	-- local simpleXml = xmlElementToSimpleTable( result )
	-- if simpleXml.stat == 'ok' then
	-- 
	-- 	return simpleXml.photoid._value
	-- 
	-- else
	-- 
	-- 	LrErrors.throwUserError( LOC( "$$$/Pixelpost/Error/API/Upload=Pixelpost API returned an error message (function upload, message ^1)",
	-- 						tostring( simpleXml.err and simpleXml.err.msg ) ) )
	-- 
	-- end

end

--------------------------------------------------------------------------------

function PixelpostAPI.openAuthUrl()

	-- Request the frob that we need for authentication.

	local data = PixelpostAPI.callRestmode{ mode = 'pixelpost.auth.getFrob' }
	
	-- Get the frob from the response.
	
	local frob = assert( data.frob._value )

	-- Do the authentication. (This is not a standard REST call.)

	local postKey, uploadURL = PixelpostAPI.getPostKeyAndURL()
	
	local authApiSig = PixelpostAPI.makeApiSignature{ perms = 'delete', frob = frob }

	local authURL = string.format( '%s?post_key=%s&perms=delete&frob=%s&api_sig=%s',
						uploadURL, postKey, frob, authApiSig )
-- uploadURL
	LrHttp.openUrlInBrowser( authURL )

	return frob

end
