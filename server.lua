local mReady = false
local onWar = false
local MAX_GANGZONES = 0
local switch = false

FrakCD = {}
FrakCDEnemy = {}
gangZones = {}
inWar = {
	attackerGang,
	attackingGang,
	attackerGName,
	attackingGName,
	safetime = 0,
	zone
}
local zoneTimer = 720
local killInWar = {}

RegisterServerEvent('checkIfInWar')
AddEventHandler('checkIfInWar', function(source)
	if onWar then
		 TriggerEvent('ls:getUser', source, function(users)
			if inWar.attackerGang == users.member or inWar.attackingGang == users.member then
				killInWar[source] = true
			end
		 end)
	end
end)


local orgSpawns = {
	{106.81072998047,-1941.1547851563,10.861600875854},
	{1273.9725341797,-1711.1239013672,54.771492004395},
	{-14.727194786072,-1432.9182128906,31.117149353027},
	{-623.72937011719,-1620.1171875,33.010547637939},
	{-111.88785552979,-11.222958564758,70.519546508789}
}



RegisterServerEvent('playerSpawn')
AddEventHandler('playerSpawn', function()
	TriggerEvent('checkIfInWar', source)
	if killInWar[source] == nil or killInWar[source] == false then
-- Šeit būs slimnīcas script, ka guļ uz zemes player
	else
		TriggerEvent('ls:getUser', source, function(users)
			local ped = GetPlayerPed(source)
			--respawnPed(ped, users.member)
			TriggerClientEvent('respawnPed', source, ped, users.member)
			killInWar[source] = false
			print(table.unpack(orgSpawns[users.member]))
		end)
	end
end)

AddEventHandler('onMySQLReady', function ()
	mReady = true
end)

Citizen.CreateThread(
    function()
	
	while true do
		if onWar then
			if switch then
				local players = GetPlayers()
				for _, source in ipairs(players) do
					TriggerClientEvent('flashGZ', source, inWar.zone, inWar.attackerGang)
				end
			else
				local players = GetPlayers()
				for _, source in ipairs(players) do
					TriggerClientEvent('flashGZ', source, inWar.zone, inWar.attackingGang)
				end
			end
			switch = not switch
		end
		
		if inWar.safetime ~= 0 then
			inWar.safetime = inWar.safetime - 1
			
			if inWar.safetime == 60 or inWar.safetime == 120 then
				SendFMes(inWar.attackerGang, "^1[F] Jums atlikušas " .. inWar.safetime .. " sekundes, lai sagatavotos!")
				SendFMes(inWar.attackingGang, "^1[F] Jums atlikušas " .. inWar.safetime .. " sekundes, lai sagatavotos!")
			elseif inWar.safetime == 0 then
				SendFMes(inWar.attackerGang, "^1[F] Sagatavošanās laiks ir beidzies! Kad zonā nebūs jūsu bandas spēlētāji, tā tiks pretiniekiem!")
				SendFMes(inWar.attackingGang, "^1[F] Sagatavošanās laiks ir beidzies! Kad zonā nebūs jūsu bandas spēlētāji, tā tiks pretiniekiem!")
			end
		elseif onWar then
			local inZone = {}
			local players = GetPlayers()
			for _, source in ipairs(players) do
				TriggerEvent('es:getPlayerFromId', _, function(user)
					TriggerEvent('ls:getUser', source, function(users)
						if users.member == inWar.attackerGang or users.member == inWar.attackingGang then
							if PlayerToKvadrat(user.getCoords(), gangZones[inWar.zone]) and users then
								inZone[users.member] = 1
							end
						end
					end)
				end)
			end
			if inZone[inWar.attackerGang] and not inZone[inWar.attackingGang] then -- Uzbruceeji win
				for i=1,5,1
				do
					SendFMes(i, "^1[F] " .. inWar.attackerGName .. " vinnēja un ieguva jaunu teritoriju!")
				end
				
				MySQL.Async.execute("UPDATE gangzone SET fraction = @fraction WHERE `id` = @ids", {ids = inWar.zone, fraction = inWar.attackerGang}, function(done)
					if callback then
						callback(true)
					end
				end)
				local players = GetPlayers()
				for _, source in ipairs(players) do
					TriggerClientEvent('flashGZ', source, inWar.zone, inWar.attackerGang)
				end
				
				onWar = false
			elseif inZone[inWar.attackingGang] and not inZone[inWar.attackerGang] then-- Aizstavoshie win
				for i=1,5,1
				do
					SendFMes(i, "^1[F] " .. inWar.attackingGName .. " aizstaveja savu territoriju!")
				end
				
				MySQL.Async.execute("UPDATE gangzone SET fraction = @fraction WHERE `id` = @ids", {ids = inWar.zone, fraction = inWar.attackingGang}, function(done)
					if callback then
						callback(true)
					end
				end)
				local players = GetPlayers()
				for _, source in ipairs(players) do
					TriggerClientEvent('flashGZ', source, inWar.zone, inWar.attackingGang)
				end

				onWar = false
			elseif not inZone[inWar.attackerGang] and not inZone[inWar.attackingGang] then
				zoneTimer = zoneTimer - 1
				if zoneTimer <= 0 then
					for i=1,5,1
					do
						SendFMes(i, "^1[F] " .. inWar.attackingGName .. " aizstaveja savu territoriju!")
					end
					
					MySQL.Async.execute("UPDATE gangzone SET fraction = @fraction WHERE `id` = @ids", {ids = inWar.zone, fraction = inWar.attackingGang}, function(done)
						if callback then
							callback(true)
						end
					end)
					local players = GetPlayers()
					for _, source in ipairs(players) do
						TriggerClientEvent('flashGZ', source, inWar.zone, inWar.attackingGang)
					end

					onWar = false
				end
			end
		end
		
		for key,value in pairs(FrakCD) do --actualcode
			if FrakCD[key] > 0 then
				FrakCD[key] = FrakCD[key] - 1
				if FrakCD[key] == 0 then
					SendFMes(key, "[F] Tava banda/mafija atkal var karot par zonu!")
				end
			end
		end
		
		for key,value in pairs(FrakCDEnemy) do
			if FrakCDEnemy[key] > 0 then
				FrakCDEnemy[key] = FrakCDEnemy[key] - 1
			end
		end
	
		Wait( 1000 )
	end
	
end)

RegisterServerEvent('drawGZ')
AddEventHandler("drawGZ", function()
	local i = 0
	repeat
		i = i + 1
		zones = MySQL.Sync.fetchAll('SELECT * FROM gangzone WHERE `id`=@identifier;', {identifier = i})
		if zones[1] then
			TriggerClientEvent('drawing', source, zones[1], GetPlayerIdentifier(source))
			gangZones[i] = zones[1]
			if(i > MAX_GANGZONES) then
				MAX_GANGZONES = gangZones[i].id
			end
		end
	until(i > MAX_GANGZONES)
end)

TriggerEvent('es:addCommand', 'gzmap', function(source, args, user)
	TriggerClientEvent('gzmap', source)
end)

function SendFMes(member, message)
	local players = GetPlayers()
	for _, i in ipairs(players) do
		TriggerEvent('ls:getUser', i, function(user)
			if user.member == member then
				TriggerClientEvent('chatMessage', i, message)
			end
		end)
	end
end

function PlayerToKvadrat(playerPos, zona)
	local min_x = tonumber(zona.ginfo1)
	local max_x = tonumber(zona.ginfo3)
	local min_y = tonumber(zona.ginfo2)
	local max_y = tonumber(zona.ginfo4)
	
    if((playerPos.x <= max_x and playerPos.x >= min_x) and (playerPos.y <= max_y and playerPos.y >= min_y)) then
		return 1
	end
end

--[[
	0 - None
	1 - GSG
	2 - Ballas
	3 - Rifa
	4 - Aztec
	5 - Vagos
]]

function IsAGang(member)
	if(member == 1 or member == 2 or member == 3 or member == 4 or member == 5) then
		return 1
	end
end

TriggerEvent('es:addCommand', 'capture', function(source, args, user)
	TriggerEvent('ls:getUser', source, function(users)
		if not IsAGang(users.member) then
			TriggerClientEvent('ShowWarning', source, "~r~Si funkcija pieejama tikai bandas locekliem!")
			return 1
		end
		if(users.rank >= 7) then
			if FrakCD[users.member] and FrakCD[users.member] > 0 then
				TriggerClientEvent('ShowWarning', source, "~r~Jus varesiet karot pec " .. FrakCD[users.member] .. " sekundem!")
				return 1
			end
			if onWar then
				TriggerClientEvent('ShowWarning', source, "~r~Kada no bandam jau karo!")
				return 1
			end
			for g=1,MAX_GANGZONES,1
			do
				if PlayerToKvadrat(user.getCoords(), gangZones[g]) then
					if gangZones[g].fraction == users.member then
						TriggerClientEvent('ShowWarning', source, "~r~Jus nevarat iekarot savas bandas zonu!")
						return 1
					end
					if FrakCDEnemy[gangZones[g].fraction] and FrakCDEnemy[gangZones[g].fraction] > 0 then
						TriggerClientEvent('ShowWarning', source, "~r~Banda jau karoja!")
						TriggerClientEvent('ShowWarning', source, "~r~Jus varesiet karot ar so bandu pec " .. FrakCDEnemy[gangZones[g].fraction] .. " sekundem!")
						return 1
					end
			
					local attackerName = MySQL.Sync.fetchAll('SELECT name FROM fraction WHERE `id`=@ids;', {ids = users.member})
					local attackingName = MySQL.Sync.fetchAll('SELECT name FROM fraction WHERE `id`=@ids;', {ids = gangZones[g].fraction})

					SendFMes(gangZones[g].fraction, "^1[F] Jūsu zonai uzbrūk banda " .. attackerName[1].name .. ", jums ir 5 minūtes, lai sagatavotos")
					SendFMes(gangZones[g].fraction, "^1[F] Ja pēc laika iztecēšanas jūs nebūsiet zonā, tā pāries " .. attackerName[1].name)
					SendFMes(users.member, "^1[F] " .. GetPlayerName(source) .. " sāka zonas iekarošanu pret " .. attackingName[1].name .. ". Jums ir 5 minūtes, lai sagatavotos")
					
					onWar = true
					inWar.safetime = 300
					inWar.attackingGang = gangZones[g].fraction
					inWar.attackerGang = users.member
					inWar.attackerGName = attackerName[1].name
					inWar.attackingGName = attackingName[1].name 
					inWar.zone = g
					FrakCD[users.member] = 1200
					FrakCDEnemy[gangZones[g].fraction] = 1200
					zoneTimer = 720
					
					break
				end
			end
		else
			TriggerClientEvent('ShowWarning', source, "~r~Funkcija pieejama no 7 ranga!")
		end
	end)
end)

RegisterServerEvent('kw:getFraction')
AddEventHandler("kw:getFraction", function(id, cb)
	fractions = MySQL.Sync.fetchAll('SELECT * FROM fraction WHERE `id`=@ids;', {ids = id})
	
	cb(fractions[1])
end)

TriggerEvent('es:addAdminCommand', 'makeleader', 2, function(source, args, user)
	if(args[1] == nil or args[2] == nil) then
		TriggerClientEvent('chatMessage', source, "/makeleader (speletaja ID) (organizacija)")
		return
	end
	local pirmais = tonumber(args[1])
	local otrais = tonumber(args[2])
	if(pirmais > 0 and otrais > 0) then
		MakeLeader(source, args[1], args[2])
	else
		TriggerClientEvent('chatMessage', source, "/makeleader (speletaja ID) (organizacija)")
		return
	end
end, function(source, args, user)
     TriggerClientEvent('ShowWarning', source, "~r~Tev nav pieejas sai komandai!")
end, {"player, fraction-id"})

TriggerEvent('es:addAdminCommand', 'removeleader', 2, function(source, args, user)
	local pirmais = tonumber(args[1])
	if(args[1] == nil or pirmais <= 0) then
		TriggerClientEvent('chatMessage', source, "/removeleader (speletaja ID)")
		return
	end
    RemoveLeader(source, args[1], args[2])
end, function(source, args, user)
     TriggerClientEvent('ShowWarning', source, "~r~Tev nav pieejas sai komandai!")
end, {"player, fraction-id"})


function MakeLeader(source, user, org)
	if(GetPlayerPing(user) <= 0) then
		TriggerClientEvent('ShowWarning', source, "~r~Speletajs neeksiste!")
		return
	end
	TriggerEvent('ls:getUser', user, function(usr)
		if(usr.leader > 0) then
			TriggerClientEvent('ShowWarning', source, "~r~Speletajs jau ir lideris!")
			return
		end
		TriggerEvent('kw:getFraction', org, function(frac)
			if(frac.leader ~= "None") then
				TriggerClientEvent('ShowWarning', source, "~r~Organizacijai jau ir lideris!")
				return
			end

			identifiers = GetPlayerIdentifier(user)
			MySQL.Async.execute("UPDATE users SET leader = @orgs, member = @orgs, rank = 10 WHERE `identifier` = @identifier", {orgs = org, identifier = identifiers}, function(done)
				if callback then
					callback(true)
				end
			end)
			MySQL.Async.execute("UPDATE fraction SET leader = @identifier, assistant = 'None' WHERE `id` = @orgs", {orgs = org, identifier = identifiers}, function(done)
				if callback then
					callback(true)
				end
			end)
			TriggerClientEvent('ShowWarning', source, usr.name .. " tagad ir " .. frac.name .. " lideris!")

		end)
	end)
end

function RemoveLeader(source, user)
	if(GetPlayerPing(user) <= 0) then
		TriggerClientEvent('ShowWarning', source, "~r~Speletajs neeksiste!")
		return
	end
	TriggerEvent('ls:getUser', user, function(usr)
		if(usr.leader == 0) then
			TriggerClientEvent('ShowWarning', source, "~r~Speletajs nav lideris!")
			return
		end
		TriggerEvent('kw:getFraction', usr.leader, function(frac)
			identifiers = GetPlayerIdentifier(user)
			MySQL.Async.execute("UPDATE users SET leader = 0, member = 0, rank = 0 WHERE `identifier` = @identifier", {identifier = identifiers}, function(done)
				if callback then
					callback(true)
				end
			end)
			MySQL.Async.execute("UPDATE fraction SET leader = 'None', assistant = 'None' WHERE `id` = @orgs", {orgs = usr.leader}, function(done)
				if callback then
					callback(true)
				end
			end)
			TriggerClientEvent('ShowWarning', source, usr.name .. " vairs nav " .. frac.name .. " lideris!")

		end)
	end)
end