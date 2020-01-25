ESX = nil

local HasAlreadyEnteredMarker = false
local LastZone = nil

local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}

local PedCache = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('token_1995:esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

function Draw3DText(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z + 1.05)
    local gameplayCamCoords = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(gameplayCamCoords, coords, true)
	local scale = (1 / distance) * 2

    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function PlayAnim(personne, animDict, animName, duration)
	RequestAnimDict(animDict)

	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(0)
	end

	TaskPlayAnim(personne, animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
	RemoveAnimDict(animDict)
end

function PlayFarmAnim()
	Citizen.CreateThread(function()
		TaskStartScenarioInPlace(PlayerPedId(), "CODE_HUMAN_MEDIC_KNEEL", 0, false)
		Citizen.Wait(3000)
		ClearPedTasks(PlayerPedId())
		Citizen.Wait(200)
	end)
end

AddEventHandler('token_1995:farming:hasEnteredMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	
	if zone == 'FarmOrange' then
		CurrentAction = zone
		CurrentActionMsg = "Appuyez sur ~INPUT_CONTEXT~ pour ramasser des oranges"
		CurrentActionData = {}
	elseif zone == 'ProcessOrange' then
		CurrentAction = zone
		CurrentActionMsg = "Appuyez sur ~INPUT_CONTEXT~ pour traiter vos oranges"
		CurrentActionData = {}
	elseif zone == 'SellOrange' then
		CurrentAction = zone
		CurrentActionMsg = "Appuyez sur ~INPUT_CONTEXT~ pour vendre vos oranges"
		CurrentActionData = {}
	end
end)

AddEventHandler('token_1995:farming:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()

	if zone == 'FarmOrange' then
		TriggerServerEvent('token_1995:farming:stopFarm')
	elseif zone == 'ProcessOrange' then
		TriggerServerEvent('token_1995:farming:stopProcess')
	elseif zone == 'SellOrange' then
		TriggerServerEvent('token_1995:farming:stopSell')
	end
end)

RegisterNetEvent('token_1995:farming:changeMarker')
AddEventHandler('token_1995:farming:changeMarker', function(zone)
	if zone == 'FarmOrange' then
		Config.Zones.FarmOrange.activePos = Config.Zones.FarmOrange.Pos[math.random(1, #Config.Zones.FarmOrange.Pos)]
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyCoords = GetEntityCoords(PlayerPedId())

		for k, v in pairs(Config.Zones) do
			if v.pnj == true then
				if GetDistanceBetweenCoords(plyCoords, v.activePos, true) < Config.DrawTextDistance then
					Draw3DText(v.activePos, "Jacquie")
				end
			else
				if GetDistanceBetweenCoords(plyCoords, v.activePos, true) < Config.DrawDistance then
					DrawMarker(Config.MarkerType, v.activePos.x, v.activePos.y, v.activePos.z - 1.5, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 255, false, false, 2, false, false, false, false)
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	for k, v in pairs(Config.Zones) do
		if v.showTheBlip then
			local blip = AddBlipForCoord(v.blipPos)

			SetBlipSprite(blip, v.sprite)
			SetBlipDisplay(blip, 4)
			SetBlipScale(blip, v.size)
			SetBlipColour(blip, v.color)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(v.name)
			EndTextCommandSetBlipName(blip)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local plyCoords = GetEntityCoords(PlayerPedId())
		local isInMarker = false
		local currentZone = nil

		for k, v in pairs(Config.Zones) do
			if GetDistanceBetweenCoords(plyCoords, v.activePos, true) < Config.MarkerSize.x * 3 then
				isInMarker = true
				currentZone = k
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			lastZone = currentZone
			TriggerEvent('token_1995:farming:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('token_1995:farming:hasExitedMarker', lastZone)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) and IsPedOnFoot(PlayerPedId()) then
				if CurrentAction == 'FarmOrange' then
					TriggerServerEvent('token_1995:farming:startFarm', 'orange', CurrentAction)
					PlayFarmAnim()
				elseif CurrentAction == 'ProcessOrange' then
					TriggerServerEvent('token_1995:farming:startProcess', 'orange', 'orange_juice')
				elseif CurrentAction == 'SellOrange' then
					TriggerServerEvent('token_1995:farming:startSell', 'orange')
					PlayAnim(PlayerPedId(), 'mp_common', 'givetake1_a', 2500)
					PlayAnim(PedCache[CurrentAction], 'mp_common', 'givetake1_a', 2500)
				end
				
				CurrentAction = nil
			end
		end
	end
end)

Citizen.CreateThread(function()
	for k, v in pairs(Config.Zones) do
		if v.pnj == true then
			local hash = GetHashKey(v.pnjmodel)

			while not HasModelLoaded(hash) do
				RequestModel(hash)
				Citizen.Wait(10)
			end

			PedCache[k] = CreatePed("PED_TYPE_CIVMALE", v.pnjmodel, v.activePos.x, v.activePos.y, v.activePos.z - 1.05, v.heading, false, true)

			SetBlockingOfNonTemporaryEvents(PedCache[k], true)
			SetEntityAsMissionEntity(PedCache[k], true, true)
			SetEntityInvincible(PedCache[k], true)
			FreezeEntityPosition(PedCache[k], true)
			--DecorSetInt(PedCache[k], 'GamemodePed', 426)
		end
	end
end)