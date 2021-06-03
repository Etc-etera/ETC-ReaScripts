reaper.Undo_BeginBlock()


--------------------------------------------------------------------------------
------------------------------- Get cut length ---------------------------------
--------------------------------------------------------------------------------
cursor_pos = reaper.GetCursorPosition()
ripp_one = reaper.GetToggleCommandState(40310)
ripp_all = reaper.GetToggleCommandState(40311)

if ripp_all == 1 then set_selection = reaper.NamedCommandLookup("_SWS_SAFETIMESEL")
                      reaper.Main_OnCommand(set_selection,0)
end

time_start,time_end = reaper.GetSet_LoopTimeRange(0,0,0,0,0)
dur = time_end-time_start
 

--------------------------------------------------------------------------------
-------------- Select all items that start after cursor position ---------------
--------------------------- Ripple All Mode ------------------------------------
--------------------------------------------------------------------------------

function Select_Items_After_Pos_AllTracks() 

local item={}
itemnumbers=reaper.CountMediaItems()                                          -- Count number of items --
  for i=0,itemnumbers-1 do                                                    -- Initiate loop for the number of items --
     item[i]=reaper.GetMediaItem(0,i)                                        
     item_pos=reaper.GetMediaItemInfo_Value(item[i], "D_POSITION")           
     item_length=reaper.GetMediaItemInfo_Value(item[i], "D_LENGTH") 
     item_offset=reaper.GetMediaItemInfo_Value(item[i], "D_FADEINLEN")   
     item_fade=reaper.GetMediaItemInfo_Value(item[i], "D_FADEINLEN_AUTO")
     if item_pos+item_offset==time_end then
        reaper.SetMediaItemSelected(item[i],1)
     elseif item_pos+item_fade==time_end then
        reaper.SetMediaItemSelected(item[i],1)
     elseif item_pos<time_end and item_pos+item_length>time_end then                   
        reaper.SetMediaItemSelected(item[i],0)
     elseif item_pos<time_end and item_pos+item_length<time_end then                   
        reaper.SetMediaItemSelected(item[i],0)
     elseif time_end==item_pos+item_offset then                                              
        reaper.SetMediaItemSelected(item[i],1)
     elseif item_pos>=time_end-1 then                                               
        reaper.SetMediaItemSelected(item[i],1)
     end
        reaper.UpdateArrange()
     end                                                                      -- ENDLOOP through selected items --
end

--------------------------------------------------------------------------------
---------------------------- Split and Remove Items ----------------------------
--------------------------------------------------------------------------------


if ripp_all == 0 then
    reaper.Main_OnCommand(41384,0) -- smart cut --
  else
    reaper.Main_OnCommand(40309,0) -- ripple off --
    reaper.Main_OnCommand(41384,0) -- smart cut --
    reaper.Main_OnCommand(40311,0) -- ripple all --
    
    
end

--------------------------------------------------------------------------------
------------------------- Move Items Left by duration --------------------------
--------------------------------------------------------------------------------

if ripp_all == 1 then Select_Items_After_Pos_AllTracks()
  else return
end

  reaper.ApplyNudge(0,0,0,1,dur,1,0)
 
  reaper.Main_OnCommand(40635,0) -- remove selection
  reaper.Main_OnCommand(40289,0) -- unselect all items

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

reaper.Undo_EndBlock("Edit: Cut items/tracks/envelope points (depending on focus) within time selection, if any (smart cut)",0)

