reaper.Undo_BeginBlock()


--------------------------------------------------------------------------------
------------------------------- Get cut length ---------------------------------
--------------------------------------------------------------------------------

time_start,time_end = reaper.GetSet_LoopTimeRange(0,0,0,0,0)
dur = time_end-time_start
ripp_one = reaper.GetToggleCommandState(40310)
ripp_all = reaper.GetToggleCommandState(40311)
 

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
     
     item_offset=reaper.GetMediaItemInfo_Value(item[i], "D_SNAPOFFSET")          
     
     if item_pos+item_offset==time_end then
     
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
--------- Select all items that start after cursor position on track -----------

-------------------------- Ripple Track Mode -----------------------------------
--------------------------------------------------------------------------------

function Select_Items_After_Pos_OneTrack()

local item={}

itemnumbers=reaper.CountMediaItems()                                          -- Count number of items --

  for i=0,itemnumbers-1 do                                                    -- Initiate loop for the number of items --
  
     item[i]=reaper.GetMediaItem(0,i)                                        
     
     item_pos=reaper.GetMediaItemInfo_Value(item[i], "D_POSITION")           
     
     item_length=reaper.GetMediaItemInfo_Value(item[i], "D_LENGTH")           
     
     item_track = reaper.GetMediaItemTrack(item[i])
     
     item_offset=reaper.GetMediaItemInfo_Value(item[i], "D_SNAPOFFSET")                   
     
     
     if reaper.IsTrackSelected(item_track) == false then
       
        reaper.SetMediaItemSelected(item[i],0)
        
     elseif item_pos+item_offset==time_end then
             
        reaper.SetMediaItemSelected(item[i],1)
     
     elseif item_pos<time_end and item_pos+item_length>time_end then                   
     
        reaper.SetMediaItemSelected(item[i],0)
        
     elseif item_pos<=time_end and item_pos+item_length<time_end then                   
     
        reaper.SetMediaItemSelected(item[i],0)
        
     elseif time_end==item_pos then                                               
     
        reaper.SetMediaItemSelected(item[i],1)
    
     elseif item_pos>=time_end-1 then                                               
          
        reaper.SetMediaItemSelected(item[i],1)
       
     end

        reaper.UpdateArrange()
     end                                                                      -- ENDLOOP through selected items --
                                                                       
end

--------------------------------------------------------------------------------
---------------------------- Select next items ---------------------------------

----------------------------- No Ripple Mode -----------------------------------
--------------------------------------------------------------------------------

function Select_Next_Items()

local item={}

itemnumbers=reaper.CountMediaItems()                                          -- Count number of items --

  for i=0,itemnumbers-1 do                                                    -- Initiate loop for the number of items --
  
     item[i]=reaper.GetMediaItem(0,i)                                        
     
     item_pos=reaper.GetMediaItemInfo_Value(item[i], "D_POSITION")           
     
     item_length=reaper.GetMediaItemInfo_Value(item[i], "D_LENGTH")           
     
     item_track = reaper.GetMediaItemTrack(item[i])
     
     item_offset=reaper.GetMediaItemInfo_Value(item[i], "D_SNAPOFFSET")                   
     
     
     if reaper.IsTrackSelected(item_track) == false then
       
        reaper.SetMediaItemSelected(item[i],0)
        
     elseif item_pos+item_offset==time_end then
             
        reaper.SetMediaItemSelected(item[i],1)
     
     else
     
        reaper.SetMediaItemSelected(item[i],0)

        reaper.UpdateArrange()
     end                                                                      -- ENDLOOP through selected items --
   end                                                                    
end
--------------------------------------------------------------------------------
---------------------------- Split and Remove Items ----------------------------
--------------------------------------------------------------------------------

--if  time_end > 0 then 
  if ripp_all == 0 then
  reaper.Main_OnCommand(41384,0) -- smart cut --
  else
  
  reaper.Main_OnCommand(40309,0) -- ripple off --
  reaper.Main_OnCommand(41384,0) -- smart cut --
  reaper.Main_OnCommand(40311,0) -- ripple all -
  
  --reaper.Main_OnCommand(40289,0) -- unselect all items -- 
  --reaper.Main_OnCommand(40718,0) -- select items on selected tracks in time selection --
  --reaper.Main_OnCommand(40061,0) -- split items at time selection --
  --reaper.Main_OnCommand(40129,0) -- delete items--
  end
--else 
--return
--end
  
--------------------------------------------------------------------------------
------------------------- Move Items Left by duration --------------------------
--------------------------------------------------------------------------------

if ripp_all == 1 then Select_Items_After_Pos_AllTracks()
else return
--elseif ripp_all == 1 then Select_Items_After_Pos_AllTracks()
--elseif ripp_one == 0 and ripp_all == 0 then Select_Next_Items()
end
  

reaper.ApplyNudge(0,0,0,1,dur,true,0)
reaper.Main_OnCommand(40630,0) -- go to start of time selection --
reaper.Main_OnCommand(40084,0) -- rewind a little bit --
reaper.Main_OnCommand(40635,0) -- remove time seleciton --
reaper.Main_OnCommand(40289,0) -- unselect all items -- 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

reaper.Undo_EndBlock("Cut according to ripple mode",0)

