
local IsWide, IsPointing, handsUp, IsCrouched, ForceCrouch, Aimed, Cooldown = false, false, false, false, false, false, false, false, false
local CooldownTime = 1200
local nextCheck = GetGameTimer() + 1500

if Config.HandsUp.enabled then
    RegisterCommand(Config.HandsUp.command, function()
        if not handsUp then
           animDict('missminuteman_1ig_2')
           playAnim(GetPlayerPed(-1), 'missminuteman_1ig_2', 'handsup_enter')
           handsUp = true
        else
           ClearPedTasks(GetPlayerPed(-1))
           handsUp = false
        end
    end)

    TriggerEvent('chat:addSuggestion', Config.HandsUp.command, 'Put your handsup')

    if Config.HandsUp.keybind then
        RegisterKeyMapping(Config.HandsUp.command, 'Hands Up', 'keyboard', Config.HandsUp.key)
    end
end

if Config.BunnyHop.bmx then
    CreateThread(function()
        local bmx = GetHashKey('bmx')
        while true do
            local sleep = 0

            local playerPed = PlayerPedId()
            local InVehicle = IsPedInAnyVehicle(playerPed)

            if InVehicle and GetEntityModel(bmx) then
                DisableControlAction(0, 102, true)
            end

            Wait(sleep)
        end
    end)
end

if Config.BunnyHop.player then
    local bunnyHopCounter = 0
    local jumpDisabled = false

    CreateThread(function()
        while true do
            local sleep = 100

            local playerPed = GetPlayerPed(-1)
            local InVehicle = IsPedInAnyVehicle(playerPed)

            if not InVehicle then
                if jumpDisabled and bunnyHopCounter > 0 and IsPedJumping(playerPed) then
                    SetPedToRagdoll(playerPed, 1000, 1000, 3, 0, 0, 0)
                    bunnyHopCounter = 0
                end

                if not jumpDisabled and IsPedJumping(playerPed) then
                    jumpDisabled = true
                    bunnyHopCounter = 3500 / 100
                    Wait(1000)
                end

                if bunnyHopCounter > 0 then
                    bunnyHopCounter = bunnyHopCounter - 1
                else
                    if jumpDisabled then
                        bunnyHopCounter = 0
                        jumpDisabled = false
                    end
                end
            else
                Wait(500)
            end

            Wait(sleep)
        end
    end)
end

if Config.DisableStretch then
    CreateThread(function()
        while true do
            local sleep = 1200

            local stretch = GetIsWidescreen()
            if not stretch and not IsWide then
                antiStretch()
                IsWide = true
            elseif stretch and IsWide then
                IsWide = false
            end
            Wait(sleep)
        end
    end)
end

if Config.PointFinger.enabled then
    RegisterCommand(Config.PointFinger.command, function()
        if IsPedInAnyVehicle(PlayerPedId()) and not Config.PointFinger.vehiclepoint then
            return
        end
        
        StartPointing()
    end)

    if Config.PointFinger.keybind then
        RegisterKeyMapping(Config.PointFinger.command, 'Point Finger', "keyboard", Config.PointFinger.key)
    end
end

if Config.Crouch.enabled then
    RegisterCommand(Config.Crouch.command, function()
        if Config.Crouch.overridestealth then
	        DisableControlAction(0, 36, true)
        end
	    if not Cooldown then
		    ForceCrouch = not ForceCrouch

		    if ForceCrouch then
			    CreateThread(CrouchLoop)
		    end

		    Cooldown = true
		    SetTimeout(CooldownTime, function()
			    Cooldown = false
		    end)
	    end
    end)

    if Config.Crouch.keybind then
        RegisterKeyMapping(Config.Crouch.command, 'Crouch', 'keyboard', Config.Crouch.key)
    end
end


CreateThread(function()
    local playerPed = GetPlayerPed(-1)
    local playerId = PlayerId()

    while true do
        local sleep = true

        if Config.AimAssist then
            local sleep = false
            if IsPedArmed(playerPed, 4) then
                SetPlayerLockonRangeOverride(playerId, 2.0)
            end
        end

        if Config.HealthRegeneration then
            local sleep = false
            SetPlayerHealthRechargeMultiplier(playerId, 0.0)
        end

        if Config.WeaponWheel then
            local sleep = false
            BlockWeaponWheelThisFrame()
            DisableControlAction(0, 37,true)
        end

        if Config.VehicleRewards then
            local sleep = false
            DisablePlayerVehicleRewards(playerId)
        end

        if Config.RandomDrops then
            local sleep = false
            RemoveAllPickupsOfType(0xDF711959) -- carbine rifle
            RemoveAllPickupsOfType(0xF9AFB48F) -- pistol
            RemoveAllPickupsOfType(0xA9355DCD) -- pumpshotgun
        end

        if Config.NoDispatch then
            for b = 1, 15 do
                EnableDispatchService(b, false)
            end
        end

        Wait(sleep and 1500 or 0)
    end

    if Config.NoCover then
        SetPlayerCanUseCover(playerId, false)
    end
end)

antiStretch = function()
    CreateThread(function()
        while IsWide do
            local sleep = 0
            DrawRect(0.5, 0.5, 1.0, 1.0, 255, 0, 0, 170)
            DrawAdvancedText(0.45, 0.5, 0.005, 0.0028, 0.4, 'This aspect ratio is not allowed, please change your settings.\nSome of allowed aspect ratios are:', 255, 255, 255, 255, 10)
            DrawAdvancedText(0.65, 0.528, 0.005, 0.0028, 0.4, ' (5:3, 16:9, 16:10)', 255, 255, 255, 255, 10)
            Wait(sleep)
        end
    end)
end

ResetCrouch = function()
    local playerPed = PlayerPedId()
	SetPedMaxMoveBlendRatio(playerPed, 1.0)
	ResetPedMovementClipset(playerPed, 0.55)
	ResetPedStrafeClipset(playerPed)
	SetPedCanPlayAmbientAnims(playerPed, true)
	SetPedCanPlayAmbientBaseAnims(playerPed, true)
	ResetPedWeaponMovementClipset(playerPed)
	IsCrouched = false
end

AnimSet = function(dict)
	while not HasAnimSetLoaded(dict) do
		Wait(5)
		RequestAnimSet(dict)
	end
end

CanCrouch = function()
    local playerPed = PlayerPedId()
	if IsPedOnFoot(playerPed) and not IsPedInAnyVehicle(playerPed, false) and not IsPedJumping(playerPed) and not IsPedFalling(playerPed) and not IsPedDeadOrDying(playerPed) then
		return true
	else
		return false
	end
end

Crouch = function()
    local playerPed = PlayerPedId()
	SetPedUsingActionMode(playerPed, false, -1, "DEFAULT_ACTION")
	SetPedMovementClipset(playerPed, 'move_ped_crouched', 0.55)
	SetPedStrafeClipset(playerPed, 'move_ped_crouched_strafing') -- it force be on third person if not player will freeze but this func make player can shoot with good anim on crouch if someone know how to fix this make request :D
	SetWeaponAnimationOverride(playerPed, "Ballistic")
	IsCrouched = true
	Aimed = false
end

SetPlayerAimSpeed = function()
    local playerPed = PlayerPedId()
	SetPedMaxMoveBlendRatio(playerPed, 0.2)
	Aimed = true
end

IsPlayerFreeAimed = function()
    local playerId = PlayerId()
	if IsPlayerFreeAiming(playerId) or IsAimCamActive()  then
		return true
	else
		return false
	end
end

CrouchLoop = function()
	AnimSet('move_ped_crouched')
	while ForceCrouch do

        if Config.Crouch.firstperson then
		    DisableFirstPersonCamThisFrame()
        end

		local now = GetGameTimer()
		if now >= nextCheck then
			local playerPed = PlayerPedId()
			local playerID = GetPlayerIndex()
			nextCheck = now + 1500
		end

		local CanDo = CanCrouch()
		if CanDo and IsCrouched and IsPlayerFreeAimed() then
			SetPlayerAimSpeed()
		elseif CanDo and (not IsCrouched or Aimed) then
			Crouch()
		elseif not CanDo and IsCrouched then
			ForceCrouch = false
			ResetCrouch()
		end

		Wait(5)
	end
	ResetCrouch()
	RemoveAnimDict('move_ped_crouched')
end

IsPlayerAiming = function(player)
    return IsPlayerFreeAiming(player) or IsAimCamActive() or IsAimCamThirdPersonActive()
end

CanPlayerPoint = function(playerId, playerPed)
    if not DoesEntityExist(playerPed) or IsPedOnAnyBike(playerPed) or IsPlayerAiming(playerId) or IsPedFalling(playerPed) or IsPedInjured(playerPed) or IsPedInMeleeCombat(playerPed) or IsPedRagdoll(playerPed) or not IsPedHuman(playerPed) then
        return false
    end

    return true
end

PointingStopped = function()
    local playerPed = PlayerPedId()

    RequestTaskMoveNetworkStateTransition(playerPed, 'Stop')
    SetPedConfigFlag(playerPed, 36, false)
    if not IsPedInjured(playerPed) then
        ClearPedSecondaryTask(playerPed)
    end
    RemoveAnimDict("anim@mp_point")
end

PointingThread = function()
    CreateThread(function()
        local playerId = PlayerId()
        local playerPed = PlayerPedId()

        while IsPointing do
            Wait(0)

            if not CanPlayerPoint(playerId, playerPed) then
                IsPointing = false
                break
            end

            local camPitch = GetGameplayCamRelativePitch()
            if camPitch < -70.0 then
                camPitch = -70.0
            elseif camPitch > 42.0 then
                camPitch = 42.0
            end

            camPitch = (camPitch + 70.0) / 112.0

            local camHeading = GetGameplayCamRelativeHeading()
            local cosCamHeading = math.cos(camHeading)
            local sinCamHeading = math.sin(camHeading)

            if camHeading < -180.0 then
                camHeading = -180.0
            elseif camHeading > 180.0 then
                camHeading = 180.0
            end

            camHeading = (camHeading + 180.0) / 360.0
            local coords = GetOffsetFromEntityInWorldCoords(playerPed, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
            local _rayHandle, blocked = GetShapeTestResult(StartShapeTestCapsule(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, playerPed, 7))

            SetTaskMoveNetworkSignalFloat(playerPed, 'Pitch', camPitch)
            SetTaskMoveNetworkSignalFloat(playerPed, 'Heading', (camHeading * -1.0) + 1.0)
            SetTaskMoveNetworkSignalBool(playerPed, 'isBlocked', blocked)
            SetTaskMoveNetworkSignalBool(playerPed, 'isFirstPerson', GetCamViewModeForContext(GetCamActiveViewModeContext()) == 4)
        end

        PointingStopped()
    end)
end

StartPointing = function()
    local playerPed = PlayerPedId()
    if not CanPlayerPoint(PlayerId(), playerPed) then
        return
    end

    IsPointing = not IsPointing

    -- If we should point and the animation was loaded, then start pointing
    if IsPointing and LoadAnim("anim@mp_point") then
        SetPedConfigFlag(playerPed, 36, true)
        TaskMoveNetworkByName(playerPed, 'task_mp_pointing', 0.5, false, 'anim@mp_point', 24)
        -- Start thread
        PointingThread()
    end
end

LoadAnim = function(dict)
    if not DoesAnimDictExist(dict) then
        return false
    end

    local timeout = 2000
    while not HasAnimDictLoaded(dict) and timeout > 0 do
        RequestAnimDict(dict)
        Wait(5)
        timeout = timeout - 5
    end
    if timeout == 0 then
        DebugPrint("Loading anim dict " .. dict .. " timed out")
        return false
    else
        return true
    end
end

animDict = function(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(1)
    end
end

playAnim = function(player, dict, clip)
    TaskPlayAnim(player, dict, clip, 8.0, 8.0, -1, 50, 0, false, false, false)
end

DrawAdvancedText = function(x,y ,w,h,sc, text, r,g,b,a,font)
    SetTextFont(font)
    SetTextScale(sc, sc)
    SetTextColour(r, g, b, a)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1+w, y - 0.02+h)
end