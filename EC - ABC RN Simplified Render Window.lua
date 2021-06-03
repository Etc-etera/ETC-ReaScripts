local Netia_Syd = 
local Netia_Melb = 

------------------------------------
------- MP3 Settings Go Here -------
------------------------------------

local MP3_1 = "bDNwbcAAAAAAAAAAAgAAAP////8EAAAAwAAAAAAAAAA="
local MP3_2 = "bDNwbYAAAAAAAAAAAgAAAP////8EAAAAgAAAAAAAAAA="

------------------------------------
------------------------------------

local OS = reaper.GetOS()

------------------------------------
--------- GUI Elements -------------
------------------------------------

local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please install 'Lokasenna's GUI library v2 for Lua', available on ReaPack, then run the 'Set Lokasenna_GUI v2 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()

loadfile(lib_path .. "Classes/Class - Button.lua")()
loadfile(lib_path .. "Classes/Class - Textbox.lua")()
loadfile(lib_path .. "Classes/Class - Window.lua")()
loadfile(lib_path .. "Classes/Class - Options.lua")()
loadfile(lib_path .. "Classes/Class - Menubox.lua")()

------------------------------------
-------- Button Functions ----------
------------------------------------

function ButtonClick()
        
         -- Setting input to values --
  
  Render_Name = GUI.Val("Name")
  Render_Format = GUI.Val("Format")
  Render_Path = GUI.Val("Destination")
  Add_MP3 = GUI.Val("Format2")
  Netia = GUI.Val("Netia")
 
         -- Setting render bounds --
         
  Render_Bounds = GUI.Val("Bounds")        
         
     if      Render_Bounds == 1 then reaper.GetSetProjectInfo(0,"RENDER_SETTINGS",0,1)     -- Master Mix --
                                   reaper.GetSetProjectInfo(0,"RENDER_BOUNDSFLAG",1,1)   -- Whole Project --
     elseif  Render_Bounds == 2 then reaper.GetSetProjectInfo(0,"RENDER_SETTINGS",0,1)     -- Master Mix --
                                   reaper.GetSetProjectInfo(0,"RENDER_BOUNDSFLAG",2,1)   -- Time Selection --
     elseif  Render_Bounds == 3 then reaper.GetSetProjectInfo(0,"RENDER_SETTINGS",64,1)    -- Selected Items --
   end
 
         -- Primary Format --
  
  reaper.GetSetProjectInfo_String(0,"RENDER_PATTERN",Render_Name,1)
    if Render_Format == 1 then
       reaper.GetSetProjectInfo_String(0,"RENDER_FORMAT","ZXZhdxAAAA==",1) -- WAV, 16bit, BWF chunk --
    else
       reaper.GetSetProjectInfo_String(0,"RENDER_FORMAT","Y2FsZhAAAAAFAAAA",1) -- FLAC, 16bit --
  end
  
          -- ADD MP3 --
  
  if Add_MP3 == 1 then
         reaper.GetSetProjectInfo_String(0,"RENDER_FORMAT2","",1)
    elseif Add_MP3 == 2 then
         reaper.GetSetProjectInfo_String(0,"RENDER_FORMAT2", MP3_1,1) -- MP3, 192kbps, Q=2 --
    elseif Add_MP3 == 3 then
         reaper.GetSetProjectInfo_String(0,"RENDER_FORMAT2", MP3_2,1) -- MP3, 128kbps, Q=2 --
  end
          -- Set 48k Sample Rate --
          
  reaper.GetSetProjectInfo(0,"RENDER_SRATE", 48000, 1)

          
          -- Render Path --

         reaper.GetSetProjectInfo_String(0,"RENDER_FILE","Masters",1)


  if Netia == 2 and Render_Format == 2 or 3 and Render_Format == 2 then reaper.ShowMessageBox("Can only send a Wav to Netia.", "Error", 0)
  return end

  if Render_Name == "" then reaper.ShowMessageBox("Please give your file a name.","Error",0)
  return end
 
--------------------------------------------------------
               -- RENDER FUNCITON --
--------------------------------------------------------

reaper.Main_OnCommand(41824,0)

--------------------------------------------------------
--------------------------------------------------------



        ------------------------------------
        --- Send Rendered Item to Netia ----
        ------------------------------------

   function GetCurrentProjPath()
   local _, projfn = reaper.EnumProjects( -1, "" )
    if projfn == "" then
      return reaper.GetProjectPath("")
    else
      return string.match(projfn, ".+\\")
    end
  end
  
  Project_Path = GetCurrentProjPath()
  source   = ""..Project_Path.."".."\\Masters"..""

      if      Netia == 1 then dest = ""
      elseif  Netia == 2 then dest = Netia_Syd
      elseif  Netia == 3 then dest = Netia_Melb
      end
  file = ""..Render_Name..""..".wav"..""

 WINcopy = "robocopy "..'"'..""..source..""..'"'.." "..'"'..""..dest..""..'"'.." "..'"'..""..file..""..'"'.." /mt /z      "
 OSXcopy = "cp "..'"'..""..source.."".."\\"..""..file..""..'"'.." "..'"'..""..dest..""..'"'.." "..'"'.."         "

--reaper.ShowMessageBox(WINcopy,0,0)
--reaper.ShowMessageBox(OSXcopy,0,0)

 if     Netia == 1 then return 
 elseif OS == Win32 or Win64 and Netia == 2 or 3 then os.execute(WINcopy)
 elseif OS == OSX32 or OSX64 and Netia == 2 or 3 then os.execute(OSXcopy)
 elseif OS == Other then reaper.ShowMessageBox("Operating System not recognised", "Error", 1)
 return end
 



GUI.quit = true

end













-----

function ButtonCancel()
  GUI.quit = true
end

----

function ButtonAdvanced()
  GUI.quit = true
  reaper.Main_OnCommand(40015,0)
end

------------------------------------
----- Set Window Parameters --------
------------------------------------


      GUI.name = "Render Project"
      GUI.x, GUI.y = 400, 400
      GUI.w, GUI.h = 540, 230

------------------------------------
--------- GUI Elements -------------
------------------------------------

      GUI.New("Name", "Textbox", 1, 70, 10, 290, 20, "File name:")
      
      GUI.New("Format", "Radio", 1, 10, 64, 150, 100, "Primary Output", "WAV,FLAC")
      GUI.New("Format2", "Radio", 2, 180, 64, 180, 100, "Add MP3", "None,High Quality,Low Quality (Email)")
      GUI.New("Netia", "Radio", 2, 380, 64, 150, 100, "Send to Netia", "None,RN Syd,RN Melb")
      GUI.New("Bounds", "Menubox", 1, 380, 10, 150, 20, "","Whole Project,Time Selection,Selected Items",0,0)
      
      GUI.New("OK", "Button", 10, 430, 180, 35, 30, "OK", ButtonClick)
      GUI.New("Cancel", "Button", 10, 480, 180, 50, 30, "Cancel", ButtonCancel)
      GUI.New("Advanced", "Button", 10, 10, 180, 65, 30, "Advanced", ButtonAdvanced)


-- Execute main GUI --

GUI.Init()
GUI.Main()








