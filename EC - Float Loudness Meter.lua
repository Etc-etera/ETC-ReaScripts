Select_Master_Track = reaper.NamedCommandLookup("_SWS_SELMASTER")
reaper.Main_OnCommand(40297,0) -- unselect all tracks
reaper.Main_OnCommand(Select_Master_Track,0)
Master_Track = reaper.GetSelectedTrack2(0,0,1)
--Num, Name = reaper.TrackFX_GetFXName(Master_Track,2,"name")
FX_ID = reaper.TrackFX_GetByName(Master_Track,"LUFS Meter",0)

Open = reaper.TrackFX_GetOpen(Master_Track,FX_ID)

if Open == true then reaper.TrackFX_Show(Master_Track,FX_ID,2)
  else reaper.TrackFX_Show(Master_Track,FX_ID,3)
end
