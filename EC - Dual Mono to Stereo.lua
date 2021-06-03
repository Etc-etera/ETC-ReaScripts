reaper.Undo_BeginBlock()

ItemCount = reaper.CountSelectedMediaItems()
if ItemCount <= 1 then reaper.MB("Please select two concurrent items.","Error",0)
return
else end
 
TrackCount = reaper.CountSelectedTracks()
if TrackCount >= 3 then reaper.MB("Please select items accross two track only.","Error",0)
return
else end

---------------------------------

Track1 = reaper.GetSelectedTrack(0,0)
Track2 = reaper.GetSelectedTrack(0,1)

for i=0, ItemCount-1 do

  item = reaper.GetSelectedMediaItem(0,i)
  take = reaper.GetActiveTake(item)
  track = reaper.GetMediaItemTrack(item)
  
  
  reaper.SetMediaItemInfo_Value(item,"B_ALLTAKESPLAY",1)
  
  if track == Track1 then
    reaper.SetMediaItemTakeInfo_Value(take,"D_PAN",-1)
  elseif track == Track2 then 
    reaper.SetMediaItemTakeInfo_Value(take,"D_PAN",1)
  else
  end
end

reaper.Main_OnCommand(40919,0) -- set item mix behaveour to always mix
reaper.Main_OnCommand(40438,0) -- implode items accross track into takes
reaper.Main_OnCommand(42432,0) -- Glue Items

reaper.Undo_EndBlock("Combine dual mono to stereo",0)
