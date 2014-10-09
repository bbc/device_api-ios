#!/bin/bash

# `menu_click`, by Jacob Rus, September 2006
# 
# Accepts a list of form: `{"Finder", "View", "Arrange By", "Date"}`
# Execute the specified menu item.  In this case, assuming the Finder 
# is the active application, arranging the frontmost folder by date.

on menu_click(mList)
    local appName, topMenu, r

    -- Validate our input
    if mList's length < 3 then error "Menu list is not long enough"

    -- Set these variables for clarity and brevity later on
    set {appName, topMenu} to (items 1 through 2 of mList)
    set r to (items 3 through (mList's length) of mList)

    -- This overly-long line calls the menu_recurse function with
    -- two arguments: r, and a reference to the top-level menu
    tell application "System Events" to my menu_click_recurse(r, ((process appName)'s ¬
        (menu bar 1)'s (menu bar item topMenu)'s (menu topMenu)))
end menu_click

on menu_click_recurse(mList, parentObject)
    local f, r

    -- `f` = first item, `r` = rest of items
    set f to item 1 of mList
    if mList's length > 1 then set r to (items 2 through (mList's length) of mList)

    -- either actually click the menu item, or recurse again
    tell application "System Events"
        if mList's length is 1 then
          set enabledProp to (value of attribute "AXEnabled" of parentObject's menu item f) as string  
          if (enabledProp is equal to "true")
            click parentObject's menu item f
          else
            error "'" & name of parentObject's menu item f & "' menu item is not enabled"
          end if
        else
            my menu_click_recurse(r, (parentObject's (menu item f)'s (menu f)))
        end if
    end tell
end menu_click_recurse

on ios_sim_reset()
  menu_click({"iPhone Simulator", "iOS Simulator", "Reset Content and Settings…"})

  tell application "System Events"
    tell process "iPhone Simulator"
      tell window 1
          click button "Reset"
      end tell
    end tell
  end tell
end ios_sim_reset

on ios_sim_quit()
  menu_click({"iPhone Simulator", "iOS Simulator", "Quit iOS Simulator"})
end ios_sim_quit

on ios_sim_home()
  menu_click({"iPhone Simulator", "Hardware", "Home"})
end ios_sim_home

on ios_sim_get_props()
  set deviceType to ""
  set osVersion to ""
  tell application "System Events"
    tell process "iPhone Simulator"
    set hardwareMenu to menu 1 of menu bar item "Hardware" of menu bar 1
      set allUIElements to entire contents of hardwareMenu
      repeat with anElement in allUIElements
        try
          set marked to (value of attribute "AXMenuItemMarkChar" of anElement) as string
          if (marked is not equal to "") then
            set menuTitle to value of attribute "AXTitle" of anElement
            if deviceType is equal to "" then
              set deviceType to menuTitle
            else
              set osVersion to menuTitle
              exit repeat
            end if
            set allUIElements to entire contents of anElement         
          end if
        end try
      end repeat
    end tell
  end tell
  return deviceType & " - " & osVersion
end ios_sim_get_props

on run argv
  if item 1 of argv is equal to "reset"
  return ios_sim_reset()
  end
  if item 1 of argv is equal to "close"
  return ios_sim_quit()
  end
  if item 1 of argv is equal to "home"
  return ios_sim_home()
  end
  if item 1 of argv is equal to "getprops"
  return ios_sim_get_props()
  else
    return "Invalid parameter: " & item 1 of argv
  end

end run