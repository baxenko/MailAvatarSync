(* 
   Avatarize - Auto Avatar Fetcher for macOS Mail
   
   Installation:
   Save this script as "Avatarize.scpt" to:
   ~/Library/Application Scripts/com.apple.mail/
   
   Usage:
   Add a Rule in Mail.app -> "Run AppleScript" -> Select "Avatarize"
*)

using terms from application "Mail"
	on perform mail action with messages theMessages for rule theRule
		repeat with eachMessage in theMessages
			try
				set senderString to sender of eachMessage
				set theEmail to my extractEmail(senderString)
				set theName to my extractName(senderString)
				
				if theEmail is not "" then
					my processEmail(theName, theEmail)
				end if
			on error errMsg
				-- Errors are logged to Console.app (filter by "MailAvatarRule")
				my logLog("Error processing msg: " & errMsg)
			end try
		end repeat
	end perform mail action with messages
end using terms from

-- === Main Logic ===

on processEmail(theName, theEmail)
	set avatarPath to my findAvatar(theEmail)
	
	if avatarPath is "" then return
	
	-- Read image data into memory
	try
		set imgData to (read (POSIX file avatarPath) as picture)
	on error
		return
	end try
	
	-- Apply to Contacts
	try
		tell application "Contacts"
			set foundPeople to (every person whose value of emails contains theEmail)
			
			if foundPeople is not {} then
				-- CASE 1: CONTACT EXISTS
				set targetPerson to item 1 of foundPeople
				
				-- Only update if the contact has no photo
				if (image of targetPerson) is missing value then
					set image of targetPerson to imgData
					save
					my logLog("Updated photo for existing contact: " & name of targetPerson)
				end if
			else
				-- CASE 2: CONTACT DOES NOT EXIST -> CREATE NEW COMPANY
				
				-- If name is empty, fallback to email address
				if theName is "" then set theName to theEmail
				
				-- Create a new person with "Company" flag enabled
				-- Note: We put the name into 'organization' field
				set newPerson to make new person with properties {organization:theName, company:true, first name:"", last name:""}
				
				make new email at end of emails of newPerson with properties {label:"work", value:theEmail}
				set image of newPerson to imgData
				save
				
				my logLog("Created new Company Contact: " & theName)
			end if
		end tell
		
		-- Cleanup temporary file
		try
			do shell script "rm -f " & quoted form of avatarPath
		end try
		
	on error errMsg
		my logLog("Contacts error: " & errMsg)
	end try
end processEmail

-- === Avatar Fetching Strategy ===

on findAvatar(emailAddr)
	-- 1. Check Gravatar
	set md5Hash to my getMD5(emailAddr)
	set gravatarUrl to "https://www.gravatar.com/avatar/" & md5Hash & "?d=404&s=256"
	
	set p to my downloadImage(gravatarUrl)
	if p is not "" then return p
	
	-- 2. Check Domain Logos (for businesses)
	set domainPart to my extractDomain(emailAddr)
	if my isGeneric(domainPart) is true then return ""
	
	-- Source A: Clearbit
	set url1 to "https://logo.clearbit.com/" & domainPart & "?size=256"
	set p1 to my downloadImage(url1)
	if p1 is not "" then return p1
	
	-- Source B: FaviconKit
	set url2 to "https://api.faviconkit.com/" & domainPart & "/256"
	set p2 to my downloadImage(url2)
	if p2 is not "" then return p2
	
	return ""
end findAvatar

on downloadImage(urlStr)
	try
		set tmpFile to do shell script "mktemp -t avatar_dl"
		
		-- Download using curl:
		-- -L: Follow redirects
		-- -s: Silent mode
		-- -f: Fail silently on HTTP errors (404)
		-- --max-time 4: Timeout after 4 seconds
		do shell script "curl -L -s -f --max-time 4 " & quoted form of urlStr & " -o " & quoted form of tmpFile
		
		-- Check file size (ignore files smaller than 500 bytes to avoid broken icons)
		set fSize to (do shell script "stat -f%z " & quoted form of tmpFile) as integer
		if fSize < 500 then
			do shell script "rm -f " & quoted form of tmpFile
			return ""
		end if
		
		-- Convert/Normalize to PNG using sips (Crucial for Contacts.app compatibility)
		set pngFile to tmpFile & ".png"
		do shell script "sips -s format png --resampleHeightWidthMax 256 " & quoted form of tmpFile & " --out " & quoted form of pngFile & " >/dev/null 2>&1"
		
		-- Remove original download, keep the PNG
		do shell script "rm -f " & quoted form of tmpFile
		
		return pngFile
	on error
		return ""
	end try
end downloadImage

-- === Utilities ===

on extractEmail(s)
	if s contains "<" then
		set oldDelims to AppleScript's text item delimiters
		set AppleScript's text item delimiters to {"<", ">"}
		try
			set res to text item 2 of s
		on error
			set res to s
		end try
		set AppleScript's text item delimiters to oldDelims
		return res
	else
		return s
	end if
end extractEmail

on extractName(s)
	if s contains "<" then
		set oldDelims to AppleScript's text item delimiters
		set AppleScript's text item delimiters to "<"
		set res to text item 1 of s
		set AppleScript's text item delimiters to oldDelims
		return res
	else
		return s
	end if
end extractName

on extractDomain(e)
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "@"
	try
		set res to text item 2 of e
	on error
		set res to ""
	end try
	set AppleScript's text item delimiters to oldDelims
	return res
end extractDomain

on getMD5(s)
	-- Normalize string: lowercase + trim whitespace + calculate MD5
	set cleanStr to do shell script "echo " & quoted form of s & " | tr '[:upper:]' '[:lower:]' | xargs"
	return do shell script "md5 -q -s " & quoted form of cleanStr
end getMD5

on isGeneric(d)
	if d is "" then return true
	-- List of generic email providers where domain logo is irrelevant for the user
	set blacklist to {"gmail.com", "googlemail.com", "outlook.com", "hotmail.com", "live.com", "icloud.com", "me.com", "mac.com", "yahoo.com", "yandex.ru", "mail.ru", "bk.ru", "inbox.ru", "proton.me"}
	if d is in blacklist then return true
	return false
end isGeneric

on logLog(msg)
	do shell script "logger -t 'MailAvatarRule' " & quoted form of msg
end logLog
