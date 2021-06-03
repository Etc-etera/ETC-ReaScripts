reaper.Main_OnCommand(40625, 0)  -- set start time selection --
local time_start, time_end = reaper.GetSet_LoopTimeRange(0,0,0,0,0)
reaper.GetSet_LoopTimeRange(1,0,time_start,time_start+0.0001,0)

