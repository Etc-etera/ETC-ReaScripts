reaper.Undo_BeginBlock()

ripp_one = reaper.GetToggleCommandState(40310)
ripp_all = reaper.GetToggleCommandState(40311)

if      ripp_all == 1 then
        RippleState = All
        reaper.Main_OnCommand(40309,0) -- set ripple off --

elseif  ripp_one == 1 then
        RippleState = ONE
        reaper.Main_OnCommand(40309,0) -- set ripple off --
end

Tracks = reaper.CountSelectedTracks()
Items = reaper.CountSelectedMediaItems()
if Tracks >= 2 then reaper.MB("Too many tracks selected","Error",0) return
elseif Items == 0 then reaper.MB("Nothing Selected","Error",0) return
else

  reaper.Main_OnCommand(40698,0) -- copy
  reaper.Main_OnCommand(40179,0) -- set to mono L
  reaper.Main_OnCommand(40001,0) -- insert new track
  reaper.Main_OnCommand(40290,0) -- set selection to items
  reaper.Main_OnCommand(42398,0) -- paste
  reaper.Main_OnCommand(40180,0) -- set to mono R
  reaper.Main_OnCommand(40630,0) -- go to start of time selection
  reaper.Main_OnCommand(40635,0) -- remove time selection
  reaper.Main_OnCommand(40289,0) -- unselect items
end

if ripp_all == 1 then
  reaper.Main_OnCommand(40311,0) -- set ripple all --
elseif ripp_one == 1 then
  reaper.Main_OnCommand(40310,0) -- set ripple one --
end

reaper.UpdateArrange()
reaper.Undo_EndBlock("Split or Mix to Mono",0)
