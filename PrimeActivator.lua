if myHero.charName ~= myHero.charName then return end 	

local myHero = _G.myHero

local Mode = function()
        if _G.SDK then
        	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
                        return "Combo"
                elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
                        return "LaneClear"
                elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
                        return "LaneClear"
                elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
                        return "Flee"
                end
        elseif _G.Orbwalker then
        	if GOS:GetMode() == "Clear" then
        		return "LaneClear"
        	else
        	        return GOS:GetMode()
        	end
        end
        return ""
end

local GetTarget = function(range)
        local orb
        if _G.SDK then
        	orb = _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL, myHero.pos)
        elseif _G.Orbwalker then
        	orb = GOS:GetTarget(range, "AD")
        end
        return orb
end

local ValidTarget =  function(unit, range)
	local range = type(range) == "number" and range or math.huge
	return unit and unit.team ~= myHero.team and unit.valid and unit.distance <= range and not unit.dead and unit.isTargetable and unit.visible
end

local GetEnemyHeroes = function()
        local result = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(result, Hero)
		end
	end
	return result
end

local GetLaneMinions = function(range)
        local result = {}
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and ValidTarget(minion, range) and minion.team == 200 then
			table.insert (result, minion)
		end
	end
	return result
end

local GetJungleMinions = function(range)
        local result = {}
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and ValidTarget(minion, range) and minion.team == 300 then
			table.insert (result, minion)
		end
	end
	return result
end

local GetPercentHP = function(unit)
        return 100 * unit.health / unit.maxHealth
end

local GetPercentMP = function(unit)
        return 100 * unit.mana / unit.maxMana
end

local HealthPrediction = function(unit, time)
        local orb
        if _G.SDK then
        	orb = _G.SDK.HealthPrediction:GetPrediction(unit, time)
        elseif _G.Orbwalker then
        	orb = GOS:HP_Pred(unit, time)
        end
        return orb
end

local GetItemslot = function(unit, id)
        for i = ITEM_1, ITEM_7 do
		if unit:GetItemData(i).itemID == id and unit:GetSpellData(i).currentCd == 0 then 
			return i
		end
	end
	return nil
end

local KB = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6 }
local BC = GetItemslot(myHero, 3144)
local BOTRK = GetItemslot(myHero, 3153)
local YG = GetItemslot(myHero, 3142)
local T = GetItemslot(myHero, 3077)
local RH = GetItemslot(myHero, 3074)
local TH = GetItemslot(myHero, 3748)
local RO = GetItemslot(myHero, 3143)
local HPB = GetItemslot(myHero, 3152)
local HG = GetItemslot(myHero, 3146)
local GLP = GetItemslot(myHero, 3030)

local ComboItems = function(target)
        BC   = GetItemslot(myHero, 3144)
        BOTRK = GetItemslot(myHero, 3153)
        YG = GetItemslot(myHero, 3142)
		T = GetItemslot(myHero, 3077)
		RH = GetItemslot(myHero, 3074)
		TH = GetItemslot(myHero, 3748)
		RO = GetItemslot(myHero, 3143)
		HPB = GetItemslot(myHero, 3152)
		HG = GetItemslot(myHero, 3146)
		GLP = GetItemslot(myHero, 3030)
		
        if Menu.Items.BOTRK.Combo:Value() and BOTRK and ValidTarget(target, 550) and GetPercentHP(myHero) <= Menu.Items.BOTRK.LS.MyHP:Value() and GetPercentHP(target) <= Menu.Items.BOTRK.LS.EnemyHP:Value() then
        	Control.CastSpell(KB[BOTRK], target)
        elseif Menu.Items.BC.Combo:Value() and BC and ValidTarget(target, 550) and GetPercentHP(myHero) <= Menu.Items.BC.LS.MyHP:Value() and GetPercentHP(target) <= Menu.Items.BC.LS.EnemyHP:Value() then
        	Control.CastSpell(KB[BC], target)
        elseif Menu.Items.YG.Combo:Value() and YG and ValidTarget(target, myHero.range + 400) then 
        	Control.CastSpell(KB[YG])
		elseif Menu.Items.T.Combo:Value() and T and ValidTarget(target, 200) then
        	Control.CastSpell(KB[T], target)
		elseif Menu.Items.RH.Combo:Value() and RH and ValidTarget(target, 200) then
        	Control.CastSpell(KB[RH], target)
		elseif Menu.Items.TH.Combo:Value() and TH and ValidTarget(target, 200) then
        	Control.CastSpell(KB[TH], target)
		elseif Menu.Items.RO.Combo:Value() and RO and ValidTarget(target, 500) and GetPercentHP(myHero) <= Menu.Items.RO.LS.MyHP:Value() and GetPercentHP(target) <= Menu.Items.RO.LS.EnemyHP:Value() then
        	Control.CastSpell(KB[RO])
		elseif Menu.Items.HG.Combo:Value() and HG and ValidTarget(target, 700) and GetPercentHP(myHero) <= Menu.Items.HG.LS.MyHP:Value() and GetPercentHP(target) <= Menu.Items.HG.LS.EnemyHP:Value() then
        	Control.CastSpell(KB[HG], target)
		elseif Menu.Items.HPB.Combo:Value() and HPB and ValidTarget(target, 900) and GetPercentHP(myHero) <= Menu.Items.HPB.LS.MyHP:Value() and GetPercentHP(target) <= Menu.Items.HPB.LS.EnemyHP:Value() then
        	Control.CastSpell(KB[HPB], target)
		elseif Menu.Items.GLP.Combo:Value() and GLP and ValidTarget(target, 800) and GetPercentHP(myHero) <= Menu.Items.GLP.LS.MyHP:Value() and GetPercentHP(target) <= Menu.Items.GLP.LS.EnemyHP:Value() then
        	Control.CastSpell(KB[GLP], target)
        end
end

local Flee = function(target)
        YG = GetItemslot(myHero, 3142)
        if Menu.Items.YG.Flee:Value() and YG then 
        	Control.CastSpell(KB[YG])
        end
end

local Tick = function()
        local target = GetTarget(1500)
        if Mode() == "Combo" then  
                ComboItems(target)
        elseif Mode() == "Flee" then
				Flee(target)
		end
end

local Load = function()

        Menu = MenuElement({type = MENU, name = "Prime Activator",  id = "Prime"})

        Menu:MenuElement({type = MENU, name = "Activator",  id = "Items"})
        Menu.Items:MenuElement({type = MENU, name = "Bilgewater Cutlass",  id = "BC"})
		Menu.Items.BC:MenuElement({name = "Use In Combo",  id = "Combo", value = true})
		Menu.Items.BC:MenuElement({type = MENU, name = "Life Settings",  id = "LS"})
		Menu.Items.BC.LS:MenuElement({name = "Max HP(%)",  id = "MyHP", value = 100, min = 1, max = 100, step = 1})
        Menu.Items.BC.LS:MenuElement({name = "Enemy Max HP(%)",  id = "EnemyHP", value = 70, min = 1, max = 100, step = 1})
        Menu.Items:MenuElement({type = MENU, name = "Blade of the Ruined King",  id = "BOTRK"})
        Menu.Items.BOTRK:MenuElement({name = "Use In Combo",  id = "Combo", value = true})
		Menu.Items.BOTRK:MenuElement({type = MENU, name = "Life Settings",  id = "LS"})
        Menu.Items.BOTRK.LS:MenuElement({name = "Max HP(%)",  id = "MyHP", value = 100, min = 1, max = 100, step = 1})
        Menu.Items.BOTRK.LS:MenuElement({name = "Enemy Max HP(%)",  id = "EnemyHP", value = 50, min = 1, max = 100, step = 1})
        Menu.Items:MenuElement({type = MENU, name = "Youmuu's Ghostblade",  id = "YG"})
        Menu.Items.YG:MenuElement({name = "Use In Combo",  id = "Combo", value = true})
		Menu.Items.YG:MenuElement({name = "Use In Flee",  id = "Flee", value = true})
		Menu.Items:MenuElement({type = MENU, name = "Tiamat",  id = "T"})
        Menu.Items.T:MenuElement({name = "Use In Combo",  id = "Combo", value = true})
		Menu.Items:MenuElement({type = MENU, name = "Ravenous Hydra",  id = "RH"})
        Menu.Items.RH:MenuElement({name = "Use In Combo",  id = "Combo", value = true})
		Menu.Items:MenuElement({type = MENU, name = "Titanic Hydra",  id = "TH"})
        Menu.Items.TH:MenuElement({name = "Use In Combo",  id = "Combo", value = true})
		Menu.Items:MenuElement({type = MENU, name = "Randuin's Omen", id = "RO"})
        Menu.Items.RO:MenuElement({name = "Use In Combo",  id = "Combo", value = true})
		Menu.Items.RO:MenuElement({type = MENU, name = "Life Settings",  id = "LS"})
		Menu.Items.RO.LS:MenuElement({name = "Max HP(%)",  id = "MyHP", value = 70, min = 1, max = 100, step = 1})
        Menu.Items.RO.LS:MenuElement({name = "Enemy Max HP(%)",  id = "EnemyHP", value = 70, min = 1, max = 100, step = 1})
		Menu.Items:MenuElement({type = MENU, name = "Hextec Gunblade", id = "HG"})
        Menu.Items.HG:MenuElement({name = "Use In Combo",  id = "Combo", value = true})
		Menu.Items.HG:MenuElement({type = MENU, name = "Life Settings",  id = "LS"})
		Menu.Items.HG.LS:MenuElement({name = "Max HP(%)",  id = "MyHP", value = 70, min = 1, max = 100, step = 1})
        Menu.Items.HG.LS:MenuElement({name = "Enemy Max HP(%)",  id = "EnemyHP", value = 70, min = 1, max = 100, step = 1})
		Menu.Items:MenuElement({type = MENU, name = "Hextec Protobelt-01", id = "HPB"})
        Menu.Items.HPB:MenuElement({name = "Use In Combo",  id = "Combo", value = true})
		Menu.Items.HPB:MenuElement({type = MENU, name = "Life Settings",  id = "LS"})
		Menu.Items.HPB.LS:MenuElement({name = "Max HP(%)",  id = "MyHP", value = 70, min = 1, max = 100, step = 1})
        Menu.Items.HPB.LS:MenuElement({name = "Enemy Max HP(%)",  id = "EnemyHP", value = 70, min = 1, max = 100, step = 1})
		Menu.Items:MenuElement({type = MENU, name = "Hextec GLP-800", id = "GLP"})
        Menu.Items.GLP:MenuElement({name = "Use In Combo",  id = "Combo", value = true})
		Menu.Items.GLP:MenuElement({type = MENU, name = "Life Settings",  id = "LS"})
		Menu.Items.GLP.LS:MenuElement({name = "Max HP(%)",  id = "MyHP", value = 70, min = 1, max = 100, step = 1})
        Menu.Items.GLP.LS:MenuElement({name = "Enemy Max HP(%)",  id = "EnemyHP", value = 70, min = 1, max = 100, step = 1})

        Callback.Add("Tick", function() Tick() end)        
end 

function OnLoad() Load() end
