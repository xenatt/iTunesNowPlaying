on searchencode(theText)
	set AppleScript's text item delimiters to " "
	set theTextItems to text items of theText
	set AppleScript's text item delimiters to "+"
	set theText to theTextItems as string
	set AppleScript's text item delimiters to {""}
	set AppleScript's text item delimiters to "%0A"
	set theTextItems to text items of theText
	set AppleScript's text item delimiters to ""
	set theText to theTextItems as string
	set AppleScript's text item delimiters to {""}
	return theText
end searchencode

on urlencode(theText)
	set theTextEnc to ""
	set theTextEnc to do shell script "echo \"" & theText & "\" | perl -p -e 's/([^A-Za-z0-9])/sprintf(\"%%%02X\", ord($1))/seg'"
	return theTextEnc
end urlencode
tell application "System Events"
	if not (exists application process "iTunes") then
		tell application "iTunes" to activate
	else
		tell application "iTunes"
			if not (get player state as string) = "play" then
				tell application "iTunes" to play
			end if
		end tell
	end if
	
end tell

tell application "System Events"
	try
		tell application "iTunes"
			set curTrack to current track
			set ucurTrack to name of curTrack as string
			set curAlbum to album of curTrack as string
			set curArtist to artist of curTrack as string
		end tell
	end try
end tell
set k to urlencode(ucurTrack)
if curArtist is not "" then
	set k to k & " " & urlencode(curArtist)
end if
if curAlbum is not "" then
	set k to k & " " & urlencode(curAlbum)
end if
set k to searchencode(k) as text

set u to "https://itunes.apple.com/search?country=th&media=media&entity=musicTrack&term=" & k
set ds to "curl --silent '" & u & "'" as text
set y to do shell script "y=`" & ds & " | sed -e 's/[{}]/''/g' | awk -v k=\"text\" '{n=split($0,a,\",\"); for (i=1; i<=n; i++) print a[i]}' | grep trackViewUrl | head -1`;i=`echo ${#y}`;let e=$i-18;echo ${y:17:$e};" as text

if y is "" then
	set k to urlencode(ucurTrack)
	if curArtist is not "" then
		set k to k & " " & urlencode(curArtist)
	end if
	set k to searchencode(k) as text
	set u to "https://itunes.apple.com/search?country=th&media=media&entity=musicTrack&term=" & k
	set ds to "curl --silent '" & u & "'" as text
	set y to do shell script "y=`" & ds & " | sed -e 's/[{}]/''/g' | awk -v k=\"text\" '{n=split($0,a,\",\"); for (i=1; i<=n; i++) print a[i]}' | grep trackViewUrl | head -1`;i=`echo ${#y}`;let e=$i-18;echo ${y:17:$e};" as text
end if

on copyTrackAndAlbumToTwitter(theTrack, theAlbum, theArtist, TheURL)
	tell application "System Events"
		set tweet to "#NowPlaying " & theTrack
		if theArtist is not "" then
			set tweet to tweet & " - " & theArtist
		end if
		if theAlbum is not "" then
			set tweet to tweet & " - " & theAlbum
		end if
		delay 0.6 -- to make sure the clipboard will be set correctly
		if TheURL is not "" then
			set tweet to tweet & " " & TheURL
		end if
		set the clipboard to tweet as text
		tell process "Notification Center"
			click menu bar item 1 of menu bar 1
			try
				click button 2 of UI element 1 of row 2 of table 1 of scroll area 1 of window "window"
			on error errMsg
				click button 1 of UI element 1 of row 2 of table 1 of scroll area 1 of window "window"
			end try
			try
				keystroke "v" using {command down}
			end try
			--delay 0.5 -- to make sure the clipboard will be set correctly
			keystroke "D" using {command down, shift down}
			keystroke space
			delay 0.5 -- to make sure the clipboard will be set correctly
			key code 53
		end tell
	end tell
end copyTrackAndAlbumToTwitter


copyTrackAndAlbumToTwitter(ucurTrack, curAlbum, curArtist, y)
