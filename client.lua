
local ACTIVE = false
local ACTIVE_EMERGENCY_PERSONNEL = {}

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent("gblips:toggle")
AddEventHandler("gblips:toggle", function(on)

	ACTIVE = on

	if not ACTIVE then
		RemoveAnyExistingEmergencyBlips()
	end
end)

RegisterNetEvent("gblips:updateAll")
AddEventHandler("gblips:updateAll", function(personnel)
	ACTIVE_EMERGENCY_PERSONNEL = personnel
end)

RegisterNetEvent("gblips:update")
AddEventHandler("gblips:update", function(person)
	ACTIVE_EMERGENCY_PERSONNEL[person.src] = person
end)

RegisterNetEvent("gblips:wypierdol")
AddEventHandler("gblips:wypierdol", function(src)
	RemoveAnyExistingEmergencyBlipsById(src)
end)

RegisterNetEvent('grachu:policeAction')
AddEventHandler('grachu:policeAction', function(kordy)
		-- Blip
		local transG = 250
		local infoBlip = AddBlipForCoord(kordy.x, kordy.y, kordy.z)
		SetBlipSprite(infoBlip,  162)
		SetBlipColour(infoBlip,  40)
		SetBlipAlpha(infoBlip,  transG)
		SetBlipScale(infoBlip, 1.1)
		SetBlipAsShortRange(infoBlip,  1)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Utracono kontakt z nadajnikiem')
		EndTextCommandSetBlipName(infoBlip)
		while transG ~= 0 do
			Citizen.Wait(30 * 4)
			transG = transG - 1
			SetBlipAlpha(infoBlip,  transG)
			if transG == 0 then
				SetBlipSprite(infoBlip,  2)
				return
			end
		end
end)

RegisterNetEvent('grachu:policeAction')
AddEventHandler('grachu:policeAction', function(danePostaci, praca, src)
	local ped = GetPlayerPed(src)
	local kordy = GetEntityCoords(ped)

	local alpha = 250
	local radiusBlip = AddBlipForRadius(kordy.x, kordy.y, kordy.z, 50)

	SetBlipHighDetail(radiusBlip, true)
	SetBlipColour(radiusBlip, 1)
	SetBlipAlpha(radiusBlip, alpha)
	SetBlipAsShortRange(radiusBlip, true)

	local info = '[ '..praca..' ] '..danePostaci

	ESX.ShowNotification('~r~Utracono kontakt z nadajnikiem GPS: ~s~' .. info)

	TriggerEvent('grachu:policeActionBlip', kordy)

	while alpha ~= 0 do
		Citizen.Wait(30 * 4)
		alpha = alpha - 1
		SetBlipAlpha(radiusBlip, alpha)

		if alpha == 0 then
			RemoveBlip(radiusBlip)
			return
		end
	end
end)

function RemoveAnyExistingEmergencyBlips()
	for src, info in pairs(ACTIVE_EMERGENCY_PERSONNEL) do
		local possible_blip = GetBlipFromEntity(GetPlayerPed(GetPlayerFromServerId(src)))
		if possible_blip ~= 0 then
			RemoveBlip(possible_blip)
			ACTIVE_EMERGENCY_PERSONNEL[src] = nil
		end
	end
end

function RemoveAnyExistingEmergencyBlipsById(id)
		local possible_blip = GetBlipFromEntity(GetPlayerPed(GetPlayerFromServerId(id)))
		if possible_blip ~= 0 then
			RemoveBlip(possible_blip)
			ACTIVE_EMERGENCY_PERSONNEL[id] = nil
		end
end

Citizen.CreateThread(function()
	while true do
		if ACTIVE then
			for src, info in pairs(ACTIVE_EMERGENCY_PERSONNEL) do
				local player = GetPlayerFromServerId(src)
				local ped = GetPlayerPed(player)
				if GetPlayerPed(-1) ~= ped then
					if GetBlipFromEntity(ped) == 0 then
						local blip = AddBlipForEntity(ped)
						SetBlipSprite(blip, 1)
						SetBlipColour(blip, info.color)
						SetBlipAsShortRange(blip, true)
						SetBlipDisplay(blip, 4)
						SetBlipShowCone(blip, true)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString(info.name)
						EndTextCommandSetBlipName(blip)
					end
				end
			end
		end
		Wait(1)
	end
end)

RegisterNetEvent('grachu:menugpsa')
AddEventHandler('grachu:menugpsa', function()
ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'gpsmen',
	{
		title    = 'GPS',
		align    = 'center',
		elements = {
			{label = 'Zrestartuj GPS', value = '111'},
			{label = 'Zniszcz GPS', value = '222'},
		}
	},
	function(data2, menu2)
		if data2.current.value == '111' then
			menu2.close()
			TriggerServerEvent("grachu:akcjazgpsem",'1')
			Citizen.Wait(1500)
		elseif data2.current.value == '222' then
			menu2.close()
			TriggerServerEvent("grachu:akcjazgpsem",'2')
			Citizen.Wait(1500)
		end
		
	end,
	function(data2, menu2)
		menu2.close()
end)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
	TriggerEvent('esx_gps:wypierdolGPS')
	Citizen.Wait(2500)
	for i=1, #PlayerData.inventory, 1 do
		if PlayerData.inventory[i].name == 'ggps' then
			if PlayerData.inventory[i].count > 0 then
				TriggerServerEvent('grachu:dodajgpsa')
			end
		end
	end

end)