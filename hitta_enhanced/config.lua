Config = {}

Config.DisableStretch = true -- this disables the allowing of stretch for all players.
Config.AimAssist = true -- Disable aim assist (mainly for controller).
Config.HealthRegeneration = true -- if true disables player regenerating health.
Config.WeaponWheel = true -- disables the native gta weapon wheel.
Config.VehicleRewards = true -- disables random vehicle having stuff inside.
Config.RandomDrops = true -- stop peds from droping weapons.
Config.NoDispatch = true -- disable emergency vehicles from responding to scenarios.
Config.NoCover = true -- dont allow players to take cover on walls.

Config.HandsUp = {
    enabled = true, -- whether should handsup be enabled.
    keybind = true, -- enable keybind for handsup by default is with command.
    key = 'X', -- key for usage by default (players can change it for themselfs).
    command = 'handsup' -- command to put ur hands up.
}

Config.PointFinger = {
    enabled = true, -- whether should pointing be enabled.
    keybind = true, -- enable keybind for pointing by default is with command.
    key = 'B', -- key for usage by default (players can change it for themselfs).
    command = 'pointfinger', -- command to start pointing finger.
    vehiclepoint = false -- enable pointing finger while in vehicle.
}

Config.Crouch = {
    enabled = true, -- enable player crouching.
    keybind = true, -- enable keybind for crouching by default is with command.
    key = 'LCONTROL', -- key for usage by default (player can cahnge it for themselfs).
    command = 'crouch', -- command to start crouching.
    overridestealth = true, -- stop player from entering into stealthmode if duck and crouch key are the same.
    firstperson = true, -- if true disables first person in crouch mode.
}

Config.BunnyHop = {
    bmx = true, -- disable bunnyhoping while on bmx, note: this will disable jumping while player on bmx.
    player = true -- disable player spam jumping and bunnyhoping.
}