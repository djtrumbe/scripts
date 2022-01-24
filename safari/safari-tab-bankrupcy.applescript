property defaultAccountName : "iCloud"
property defaultFolderName : "Bookmarks"

global html
global processedURLs

on appendLineWithDoc(theDoc)
	tell application "Safari"
		tell theDoc
			try
				my appendHTML("    <li>")
				my appendHTML("<a href=\"" & URL & "\">")
				my appendHTML(name)
				my appendHTML("</a></li>" & return)
				set processedURLs to processedURLs & (URL as string)
			end try
		end tell
	end tell
end appendLineWithDoc

on appendHTML(htmlString)
	set html to html & htmlString
end appendHTML

on defaultFolder()
	tell application "Notes"
		if not (exists account defaultAccountName) then
			display dialog "Cound not find account '" & defaultAccountName & "'!"
			tell me to quit
		end if
		
		if exists folder defaultFolderName of account defaultAccountName then
			return folder defaultFolderName of account defaultAccountName
		end if
		
		make new folder at account defaultAccountName with properties {name:defaultFolderName}
	end tell
end defaultFolder

on run
	set currentDate to do shell script "date +'%Y-%m-%d'"
	set computerName to do shell script "/usr/sbin/scutil --get ComputerName"
	
	set noteTitle to currentDate & " Browser URL Archive on " & computerName & return
	set html to return & currentDate & " " & (time string) of (current date) & return
	my appendHTML("<ul>" & return)
	set processedURLs to {}
	
	tell application "Safari"
		set windowCount to number of windows
		activate
		
		--loop through opened windows
		repeat with w from 1 to windowCount
			
			set n to 0
			try -- this will fail for the downloads window
				set n to count tabs of window w
			end try
			
			repeat with t in every tab of window w
				my appendLineWithDoc(t)
			end repeat
			
		end repeat
	end tell
	
	my appendHTML("</ul>" & return)
	
	if (count of processedURLs) > 0 then
		set f to my defaultFolder()
		tell application "Notes"
			make new note at f with properties {body:html, name:noteTitle}
			activate
		end tell
	end if
end run
