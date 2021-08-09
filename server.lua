
local ACTIVE_EMERGENCY_PERSONNEL = {}

RegisterServerEvent("gblips:add")
AddEventHandler("gblips:add", function(person)
	ACTIVE_EMERGENCY_PERSONNEL[person.src] = person
	for k, v in pairs(ACTIVE_EMERGENCY_PERSONNEL) do
		TriggerClientEvent("gblips:updateAll", k, ACTIVE_EMERGENCY_PERSONNEL)
	end
	TriggerClientEvent("gblips:toggle", person.src, true)
end)

RegisterServerEvent("gblips:wypierdol")
AddEventHandler("gblips:wypierdol", function(src)

	ACTIVE_EMERGENCY_PERSONNEL[src] = nil

	for k, v in pairs(ACTIVE_EMERGENCY_PERSONNEL) do
		TriggerClientEvent("gblips:wypierdol", tonumber(k), src)
	end

	TriggerClientEvent("gblips:toggle", src, false)
end)


AddEventHandler("playerDropped", function()
	if ACTIVE_EMERGENCY_PERSONNEL[source] then
		ACTIVE_EMERGENCY_PERSONNEL[source] = nil
	end
end)

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
	ESX = obj
end)

AddEventHandler('esx:onAddInventoryItem', function(source, item, count)
	if item.name == 'ggps' then
		TriggerEvent('grachu:dodajgpsa', source)
	end
end)

RegisterServerEvent('grachu:policeAction')
AddEventHandler('grachu:policeAction', function(src)
	local xPlayer = ESX.GetPlayerFromId(src)
	imieGracza = GetCharacterName(src)
	praca = xPlayer.job.grade_label
	for k,v in pairs(ACTIVE_EMERGENCY_PERSONNEL) do
		TriggerClientEvent('grachu:policeAction', tonumber(k), imieGracza, praca, src)
	end
end)

AddEventHandler('esx:onRemoveInventoryItem', function(source, item, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	if item.name == 'ggps' and item.count < 1 then
		TriggerEvent("gblips:wypierdol", source)
		if xPlayer.job.name == 'police' then
			TriggerEvent('grachu:policeAction', source)
		end
	end
end)

AddEventHandler('esx_policejob:confiscatePlayerItem', function(target, itemType, itemName, amount)
	local xTarget = ESX.GetPlayerFromId(target)
	if xTarget.job.name == 'police' and itemType == 'item_standard' and itemName == 'ggps' then
		TriggerEvent('grachu:policeAction', target)
	end
end)

RegisterServerEvent("grachu:akcjazgpsem")
AddEventHandler("grachu:akcjazgpsem", function(cosie)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local iloscGps = xPlayer.getInventoryItem('ggps').count
	if cosie == '1' then
		if iloscGps > 0 then
			xPlayer.removeInventoryItem('ggps', 1)
			Wait(1000)
			xPlayer.addInventoryItem('ggps', 1)
			TriggerClientEvent('esx:showNotification', _source, 'GPS zrestartowany.')
		end
	elseif cosie == '2' then
		if iloscGps > 0 then
			xPlayer.removeInventoryItem('ggps', 1)
			TriggerClientEvent('esx:showNotification', _source, 'GPS zniszczony.')
		end
	end
end)

RegisterServerEvent("grachu:dodajgpsa")
AddEventHandler("grachu:dodajgpsa", function(source)
local _source = source
local imieGracza = 'Nieznany'
local xPlayer  = ESX.GetPlayerFromId(_source)
local praca = ''
local przedrostek = '[???]'
local kolorek = 20

if xPlayer == nil then return end

if xPlayer.job.name == 'police' then
	kolorek = 3
	imieGracza = GetCharacterName(_source)
	praca = xPlayer.job.grade_label
	przedrostek = '[LSPD]'
elseif xPlayer.job.name == 'ambulance' then
	kolorek = 1
	imieGracza = GetCharacterName(_source)
	praca = xPlayer.job.grade_label
	przedrostek = '[EMS]'
end
	TriggerEvent("gblips:add", {name = '# '..przedrostek..' '..imieGracza..' ['..praca..']', src = _source, color = kolorek})
end)

function GetCharacterName(source)
	local result = MySQL.Sync.fetchAll('SELECT * FROM users WHERE identifier = @identifier',
	{
	['@identifier'] = GetPlayerIdentifiers(source)[1]
	})
	return result[1].firstname .. ' ' .. result[1].lastname
end

ESX.RegisterUsableItem('ggps', function(source)
	TriggerClientEvent('grachu:menugpsa', source)
	Wait(1500)
end)

