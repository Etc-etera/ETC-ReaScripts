-- Export all lanes for selected tracks

function copy_file(src, dest)
  local input = io.open(src, "rb")  -- Open source file in binary read mode
  if not input then
    reaper.ShowConsoleMsg("Error: Could not open source file: " .. src .. "\n")
    return
  end
  
  -- Check if destination file already exists
  local output_check = io.open(dest, "rb")
  if output_check then
    output_check:close()
    local response = reaper.ShowMessageBox("The file " .. dest .. " already exists. Do you want to proceed?", "File Exists", 1)
    if response == 2 then  -- User selected 'Cancel'
        input:close()
        return false-- Return false to indicate that the process was terminated
    end
  end
    
  local output = io.open(dest, "wb")  -- Open destination file in binary write mode
  if not output then
    reaper.ShowConsoleMsg("Error: Could not open destination file: " .. dest .. "\n")
    input:close()  -- Close the input file if opening the output file fails
    return
  end
    
  -- Read and write the content in chunks to avoid memory issues with large files
  local chunk_size = 1024  -- Adjust the chunk size as needed
  while true do
    local chunk = input:read(chunk_size)
    if not chunk then break end  -- End of file
    local success, err = output:write(chunk)
    if not success then
      reaper.ShowConsoleMsg("Error writing to destination file: " .. err .. "\n")
      input:close()
      output:close()
      return
    end
  end
  input:close()
  output:close()
end

function Glue_Lanes()
  reaper.Main_OnCommand(40289,0) -- unselect all media items
  item_count = reaper.CountMediaItems(0)
  selected_tracks = reaper.CountSelectedTracks(0)
  
  --for every selected track, do the following
  for t = 0, selected_tracks-1 do    
    track = reaper.GetSelectedTrack(0,t)
    track_lanes = reaper.GetMediaTrackInfo_Value(track, "I_NUMFIXEDLANES")
    if reaper.CountTrackMediaItems(track) == 0 then has_items = false else has_items = true end
    
    if has_items == true then
    
      -- for each lane on selected track, do the following
      for l = 0, track_lanes-1 do   
      
        -- recalculate items for each lane pass (gluing changes number of items)
        items = reaper.CountTrackMediaItems(track) 
        
        -- for all items on this track, get the first item on lane "l"
        for i = 0, items-1 do
          item = reaper.GetTrackMediaItem(track,i)
          comparison_lane = tostring(l)
          item_lane = string.gsub(tostring(reaper.GetMediaItemInfo_Value(item,"I_FIXEDLANE")),"%.0","")
          if  item_lane == comparison_lane then
            current_lane = reaper.GetMediaItemInfo_Value(item,"I_FIXEDLANE")
          else 
          end
        end
        
        -- select all items which match current lane, set above
        for i = 0, items-1 do
          item = reaper.GetTrackMediaItem(track,i)
          lane = reaper.GetMediaItemInfo_Value(item,"I_FIXEDLANE")
          if lane == current_lane then
            reaper.SetMediaItemSelected(item,1)
          else
            reaper.SetMediaItemSelected(item,0)
          end
        end
        
        _, lane_name = reaper.GetSetMediaTrackInfo_String(track, "P_LANENAME:"..l, "",0)
        

        -- Glue items
        reaper.Main_OnCommand(40290,0) -- set time selection to media items
        reaper.Main_OnCommand(40042,0) -- go to start of project
        reaper.Main_OnCommand(40625,0) -- set start of time range at cursor (start of project)
        reaper.Main_OnCommand(41588,0) -- glue items including time selection
        reaper.Main_OnCommand(40635,0) -- remove time selection
        item = reaper.GetSelectedMediaItem(0,0)
        _, track_name = reaper.GetTrackName(track)
        take = reaper.GetTake(item,0)
        source = reaper.GetMediaItemTake_Source(take)
        filename = reaper.GetMediaSourceFileName(source)
        project_name = reaper.GetProjectName(0)
        project_name = string.gsub(reaper.GetProjectName(0),".RPP","")
        if project_name == "" then project_name = "Unsaved Project" else end
        dest = (dest_path.."//"..project_name.." - "..track_name.."-"..lane_name..".wav")
        
        --copy file and then delete original
        copy_file(filename,dest) 
        os.remove(filename) 
        
        -- update project to refer to new source audioo
        new_source = reaper.PCM_Source_CreateFromFile(dest)
        reaper.SetMediaItemTake_Source(take, new_source)
        reaper.UpdateItemInProject(item)
        reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", project_name.." - "..track_name.."-"..lane_name..".wav", true)
        reaper.Main_OnCommand(40441,0) -- rebuild peaks 
        reaper.Main_OnCommand(40289,0) -- unselect all media items
        
      end -- end of lane loop
    else -- if track has no items do nothing
    end  -- end of has_items check
  end -- end of track loop
end

function Main()
  reaper.Undo_BeginBlock()
  if reaper.CountSelectedTracks(0) == 0 then reaper.MB("Please select tracks to export", "No tracks selected",0) return else end
  copy_flag, dest_path = reaper.JS_Dialog_BrowseForFolder("Select archive location", "")
  if copy_flag == 1 then
    Glue_Lanes()
  else return
  end
  reaper.Undo_EndBlock("Export Lanes",0)
  
  if reaper.MB("Would you like to reference the consolidated takes in your project?","Keep consolidated takes?",4)
    == 6 then
  else reaper.Main_OnCommand(40029,0) --undo 
  end
end

Main()


