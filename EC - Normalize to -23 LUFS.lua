selitems = reaper.CountSelectedMediaItems(0)

normalize = reaper.NamedCommandLookup("_BR_NORMALIZE_LOUDNESS_ITEMS23")
reaper.Main_OnCommand(normalize,0)

for i=0, selitems-1 do 
  item = reaper.GetSelectedMediaItem(0,i)
  take = reaper.GetActiveTake(item)
  track = reaper.GetMediaItemTrack(item)
  source = reaper.GetMediaItemTake_Source(take)
  channels = reaper.GetMediaSourceNumChannels(source)
  chanmode = reaper.GetMediaItemTakeInfo_Value(take, "I_CHANMODE")
  D_VOL = reaper.GetMediaItemTakeInfo_Value(take, "D_VOL")
  D_Vol_dB = 20*math.log(D_VOL,10)
  pan_law = (reaper.GetMediaTrackInfo_Value(track, "D_PANLAW"))
  if pan_law == -1 then 
    pan_law_dB = 0
    else
    pan_law_dB = 20*math.log(pan_law,10)
  end 
  

  
  if reaper.IsMediaItemSelected(item) == true then
  
    if channels == 2 then
      if chanmode == 0.0 or chanmode == 1.0 then -- If Stereo in stereo mode, subtract pan law DONE
         New_Vol_dB = D_Vol_dB - pan_law_dB 
         New_Vol = 10^(New_Vol_dB/20) 
         reaper.SetMediaItemTakeInfo_Value(take,"D_VOL", New_Vol)
         
      elseif chanmode == 2.0 or chanmode == 3.0 or chanmode == 4.0 then -- If Stereo in mono mode, subtract pan law - 3dB DONE
       New_Vol_dB = D_Vol_dB - pan_law_dB - 3
       New_Vol = 10^(New_Vol_dB/20) 
       reaper.SetMediaItemTakeInfo_Value(take,"D_VOL",New_Vol)
      end
      
    elseif channels == 1 then -- If mono, subtract pan law - 3dB DONE
       New_Vol_dB = D_Vol_dB - pan_law_dB -3
       New_Vol = 10^(New_Vol_dB/20) 
       reaper.SetMediaItemTakeInfo_Value(take,"D_VOL",New_Vol)
    end
    
  elseif reaper.IsMediaItemSelected(item) == false then
    i = i+1

  end


i = i+1

end

reaper.UpdateArrange()
