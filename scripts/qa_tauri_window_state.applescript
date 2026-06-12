on run argv
  set processName to item 1 of argv
  tell application "System Events"
    tell process processName
      set output to "process=" & processName & "\nwindows=" & (count of windows)
      repeat with i from 1 to count of windows
        set currentWindow to window i
        set windowPosition to position of currentWindow
        set windowSize to size of currentWindow
        set output to output & "\n" & i & ": " & (name of currentWindow as text) & " pos=" & (item 1 of windowPosition as text) & "," & (item 2 of windowPosition as text) & " size=" & (item 1 of windowSize as text) & "," & (item 2 of windowSize as text)
      end repeat
      return output
    end tell
  end tell
end run
