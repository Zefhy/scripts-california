ESX = nil

local HasAlreadyEnteredMarker = false
local LastZone = nil

local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}

local Licenses = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('token_1995:esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('token_1995:esx_weashop:loadLicenses')
AddEventHandler('token_1995:esx_weashop:loadLicenses', function(licenses)
	for i = 1, #licenses, 1 do
		Licenses[licenses[i].type] = true
	end
end)

function OpenMainMenu(zone)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'wea_cat', {
		title = "Catégories d'armes",
		elements = {
			{label = "Arme Blanche", value = 'nolicense'},
			{label = "Permis port d'armes légères", value = 'wl_1'}
		}
	}, function(data, menu)
		if data.current.value == 'nolicense' then
			OpenShopMenu(data.current.value, zone)
		elseif data.current.value == 'wl_1' then
			if Licenses['weapon'] then
				OpenShopMenu(data.current.value, zone)
			else
				OpenBuyLicenseMenu(data.current.value, zone)
			end
		end
	end, function(data, menu)
		CurrentAction = 'shop_menu'
		CurrentActionMsg = _U('shop_menu')
		CurrentActionData = {zone = zone}
	end)
end

function OpenBuyLicenseMenu(action, zone)
	local licensePrice = 0
	local licenseType = nil

	if action == 'wl_1' then
		licensePrice = Config.LicensePrice
		licenseType = 'weapon'
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_license', {
		title = _U('buy_license'),
		elements = {
			{label = _U('no'), value = 'no'},
			{label = _U('yes'), rightlabel = {'$' .. licensePrice}, value = 'yes'}
		}
	}, function(data, menu)
		if data.current.value == 'yes' then
			TriggerServerEvent('token_1995:esx_weashop:buyLicense', licensePrice, licenseType)
		end

		menu.close()
	end, function(data, menu)
	end)
end

function OpenShopMenu(action, zone)
	local elements = {}
	local itemList = nil

	if action == 'nolicense' then
		itemList = Config.Zones[zone].Items
	elseif action == 'wl_1' then
		itemList = Config.Zones[zone].Items1
	end

	if itemList == nil then return end

	for i = 1, #itemList, 1 do
		local item = itemList[i]

		table.insert(elements, {
			label = item.label,
			rightlabel = {'$' .. item.price},
			value = item.name,
			price = item.price
		})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop', {
		title = _U('shop'),
		elements = elements
	}, function(data, menu)
		TriggerServerEvent('token_1995:esx_weashop:buyItem', data.current.value, data.current.price, zone)
	end, function(data, menu)
	end)
end

AddEventHandler('token_1995:esx_weashop:hasEnteredMarker', function(zone)
	CurrentAction = 'shop_menu'
	CurrentActionMsg = _U('shop_menu')
	CurrentActionData = {zone = zone}
end)

AddEventHandler('token_1995:esx_weashop:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

Citizen.CreateThread(function()
	for k, v in pairs(Config.Zones) do
		for i = 1, #v.Pos, 1 do
			local blip = AddBlipForCoord(v.Pos[i].x, v.Pos[i].y, v.Pos[i].z)
      
			SetBlipSprite(blip, 110)
			SetBlipDisplay(blip, 4)
			SetBlipScale(blip, 0.8)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName(_U('map_blip'))
			EndTextCommandSetBlipName(blip)
		end
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local coords = GetEntityCoords(PlayerPedId(), false)

		for k, v in pairs(Config.Zones) do
			for i = 1, #v.Pos, 1 do
				if (Config.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true) < Config.DrawDistance) then
					DrawMarker(Config.Type, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.b, 255, false, false, 2, true, false, false, false)
				end
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local coords = GetEntityCoords(PlayerPedId(), false)
		local isInMarker = false
		local currentZone = nil

		for k, v in pairs(Config.Zones) do
			for i = 1, #v.Pos, 1 do
				if (GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true) < Config.Size.x) then
					isInMarker  = true
					ShopItems   = v.Items
					currentZone = k
					LastZone    = k
				end
			end
		end

		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('token_1995:esx_weashop:hasEnteredMarker', currentZone)
		end
    
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('token_1995:esx_weashop:hasExitedMarker', LastZone)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			SetTextComponentFormat('STRING')
			AddTextComponentSubstringPlayerName(CurrentActionMsg)
			EndTextCommandDisplayHelp(0, 0, 1, -1)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'shop_menu' then
					OpenMainMenu(CurrentActionData.zone)
				end
				CurrentAction = nil
			end
		end
	end
end)

RegisterNetEvent('token_1995:esx_weashop:useClip')
AddEventHandler('token_1995:esx_weashop:useClip', function()
	local playerPed = PlayerPedId()
	if IsPedArmed(playerPed, 4) then
		local hash = GetSelectedPedWeapon(playerPed)
		if hash ~= nil then
			TriggerServerEvent('token_1995:esx_weashop:removeClip')
			AddAmmoToPed(playerPed, hash,25)
			ESX.ShowNotification("Tu as ~g~utilisé un chargeur")
		else
			ESX.ShowNotification("Tu n'as pas d'arme en main")
		end
	else
		ESX.ShowNotification("Ce type de munition ne convient pas")
	end
end)