on run argv
  set processName to item 1 of argv
  tell application "System Events"
    tell process processName
      if (count of menu bars) >= 2 then
        set statusRect to my quotaRadarItemRect(menu bar 2)
        if statusRect is not "" then return statusRect
      end if

      repeat with barIndex from 1 to count of menu bars
        set statusRect to my quotaRadarItemRect(menu bar barIndex)
        if statusRect is not "" then return statusRect
      end repeat
    end tell
  end tell
end run

on quotaRadarItemRect(menuBarRef)
  tell application "System Events"
    repeat with itemIndex from 1 to count of menu bar items of menuBarRef
      set itemRef to menu bar item itemIndex of menuBarRef
      try
        set itemDescription to description of itemRef
        set itemHelp to help of itemRef
        if itemHelp contains "Quota Radar" or itemDescription contains "status menu" then
          set itemPosition to position of itemRef
          set itemSize to size of itemRef
          return (item 1 of itemPosition as text) & "," & (item 2 of itemPosition as text) & "," & (item 1 of itemSize as text) & "," & (item 2 of itemSize as text)
        end if
      end try
    end repeat
  end tell
  return ""
end quotaRadarItemRect
