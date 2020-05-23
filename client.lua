local defaultDataSet = {
    ["pos"] = { x=0, y=0, z=0 }, -- Position of the player (vector(x, y, z))
    ["icon"] = 6, -- Player blip id (will change with vehicles)
}

local temp = {}

-- Table to keep track of the updated data
local beenUpdated =  {}

function updateData(name, value)
    defaultDataSet[name] = value
end


-- Define the variable used to open/close the tab
local tabEnabled = false
local tabLoaded = false --false
local mapEnabled = false

function REQUEST_NUI_FOCUS(bool)
    if bool == true then
        SendNUIMessage({showtab = true})
    else
        SendNUIMessage({hidetab = true})
    end
    return bool
end

RegisterNUICallback(
    "tablet-bus",
    function(data)
        -- Do tablet hide shit
        if data.load then
            print("GangZone Loaded")
            tabLoaded = true
			TriggerServerEvent('drawGZ')
        elseif data.hide then
            TriggerEvent("gzmap")
        elseif data.click then
        -- if u need click events
        end
    end
)

RegisterNetEvent('drawing')
AddEventHandler('drawing', function(zones, player)
	SendNUIMessage({
		type = "gangzone",
		zone = zones,
		speletajs = player
	})
end)

RegisterNetEvent('gzmap')
AddEventHandler('gzmap', function()
	mapEnabled = not mapEnabled
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
	SendNUIMessage({
		type = "showMap",
		toggle = mapEnabled,
		posx = x,
		posy = y
	})
	SetNuiFocus(mapEnabled, mapEnabled)
end)

RegisterNetEvent('flashGZ')
AddEventHandler('flashGZ', function(zona, fraction)
	SendNUIMessage({
		type = "flash",
		zone = zona,
		frac = fraction
	})
end)

local orgSpawns = {
	{106.81072998047,-1941.1547851563,10.861600875854},
	{1273.9725341797,-1711.1239013672,54.771492004395},
	{-14.727194786072,-1432.9182128906,31.117149353027},
	{-623.72937011719,-1620.1171875,33.010547637939},
	{-111.88785552979,-11.222958564758,70.519546508789}
}
local reviveWait = 90 -- Change the amount of time to wait before allowing revive (in seconds) (This feature is not in use yet!)

-- Turn off automatic respawn here instead of updating FiveM file.
AddEventHandler('onClientMapStart', function()
	Citizen.Trace("RPRevive: Disabling le autospawn.")
	exports.spawnmanager:spawnPlayer() -- Ensure player spawns into server.
	Citizen.Wait(2500)
	exports.spawnmanager:setAutoSpawn(false)
	Citizen.Trace("RPRevive: Autospawn is disabled.")
end)

--function respawnPed(ped, mem)
RegisterNetEvent('respawnPed')
AddEventHandler('respawnPed', function(ped, mem)
	SetEntityCoordsNoOffset(ped, orgSpawns[mem][1], orgSpawns[mem][2], orgSpawns[mem][3], false, false, false, true)
	NetworkResurrectLocalPlayer(orgSpawns[mem][1], orgSpawns[mem][2], orgSpawns[mem][3], 0, true, false) 

	SetPlayerInvincible(ped, false) 

	--TriggerEvent('playerSpawned', orgSpawns[mem][1], orgSpawns[mem][2], orgSpawns[mem][3], 0)
	ClearPedBloodDamage(ped)
end)

AddEventHandler("baseevents:onPlayerDied", function(player, reason, pos)
    --if(GetPlayerName(killer) ~= nil and GetPlayerName(source) ~= nil)then
	TriggerServerEvent('playerDeath')
    --end
end)

AddEventHandler('spawnmanager:playerSpawned', function(spawn)
	--TriggerServerEvent('playerSpawn')
end)

RegisterNetEvent('setPos')
AddEventHandler('setPos', function(pos)
	SetEntityCoords(GetPlayerPed(-1),pos, 1, 0, 0, 1)
end)

Citizen.CreateThread(
    function()
	while true do
		if NetworkIsPlayerActive(PlayerId()) and tabLoaded then

			-- Update position, if it has changed
			local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
			local x1,y1,z1 = defaultDataSet["pos"].x, defaultDataSet["pos"].y, defaultDataSet["pos"].z

			local dist = Vdist(x, y, z, x1, y1, z1)

			if (dist >= 5) then
				updateData("pos", {x = x, y=y, z=z})
			end

			SendNUIMessage({
				type = "updatePlayer",
				player = defaultDataSet
			});

		end
		Citizen.Wait(100)
	end
end)

Citizen.CreateThread(
    function()
        -- Wait for nui to load or just timeout
        local l = 0
        local timeout = false
        while not tabLoaded do
            Citizen.Wait(0)
            l = l + 1
            if l > 500 then
                tabLoaded = true --
                timeout = true
            end
        end

        if timeout == true then
            print("GangZone failed to load")
        -- return ---- Quit
        end


        REQUEST_NUI_FOCUS(false) -- This is just in case the resources restarted whilst the NUI is focused.

        while true do
			ped = GetPlayerPed(-1)
			if IsEntityDead(ped) then
				-- ShowInfoRevive('~r~You Are Dead ~w~Please wait ~y~'.. tostring(reviveWait) ..' Seconds ~w~ before choosing an action')
				TriggerServerEvent('playerSpawn')

				SetPlayerInvincible(ped, true)
				SetEntityHealth(ped, 1)

				ShowInfoRevive('~y~ You Are Dead. ~w~Use ~p~E ~y~ to Revive or ~p~R ~y~to Respawn')

				if ( IsControlJustReleased( 0, 38 ) or IsDisabledControlJustReleased( 0, 38 ) ) and GetLastInputMethod( 0 ) then 
						revivePed(ped)
						
				elseif ( IsControlJustReleased( 0, 45 ) or IsDisabledControlJustReleased( 0, 45 ) ) and GetLastInputMethod( 0 ) then
					TriggerServerEvent('playerSpawn')
					--respawnPed(ped, coords)

					--allowRespawn = false
					--respawnCount = respawnCount + 1
					--math.randomseed( playerIndex * respawnCount )
				end
			end
            -- Control ID 20 is the 'Z' key by default
            -- 244 = M
            -- Use https://wiki.fivem.net/wiki/Controls to find a different key
            if (IsControlJustPressed(0, 244)) then
                tabEnabled = not tabEnabled -- Toggle tablet visible state
				if tabEnabled then
					SendNUIMessage({showtab = true})
				else
					SendNUIMessage({hidetab = true})
				end
            end
			if IsPauseMenuActive() and tabEnabled then
				SendNUIMessage({hidetab = true})
				inPause = true
			elseif inPause and tabEnabled then
				tabEnabled = true
				SendNUIMessage({showtab = true})
				inPause = false
			end
			
			
			
			
			if (mapEnabled) then
                local ped = GetPlayerPed(-1)
                DisableControlAction(0, 1, mapEnabled) -- LookLeftRight
                DisableControlAction(0, 2, mapEnabled) -- LookUpDown
                DisableControlAction(0, 24, mapEnabled) -- Attack
                DisablePlayerFiring(ped, mapEnabled) -- Disable weapon firing
                DisableControlAction(0, 142, mapEnabled) -- MeleeAttackAlternate
                DisableControlAction(0, 106, mapEnabled) -- VehicleMouseControlOverride
            end
			
            Citizen.Wait(1)
        end
		
    end
)

function ShowInfoRevive(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentSubstringPlayerName(text)
	DrawNotification(true, true)
end

