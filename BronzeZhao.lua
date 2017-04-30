class "XinZhao"

function XinZhao:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function XinZhao:LoadSpells()
	Q = { range = 125 }
	W = { range = 125 }
	E = { range = 650 }
	R = { range = 500 }
end

function XinZhao:LoadMenu()
	local MenuIcons = "http://static.lolskill.net/img/champions/64/xinzhao.png"
	local SpellIcons = { Q = "http://static.lolskill.net/img/abilities/64/XinZhao_ThreeTalon.png",
						 W = "http://static.lolskill.net/img/abilities/64/XinZhao_BattleCry.png",
						 E = "http://static.lolskill.net/img/abilities/64/XinZhao_Charge.png",
						 R = "http://static.lolskill.net/img/abilities/64/XinZhao_CrescentSweep.png",
						 I = "http://static.lolskill.net/img/spells/32/14.png",
						 S = "http://static.lolskill.net/img/spells/32/11.png",
						 EX = "http://static.lolskill.net/img/spells/32/3.png", }
	--Main Menu
	self.Menu = MenuElement({type = MENU, id = "Menu", name = "XinZhao", leftIcon = MenuIcons})
	
	--Main Menu-- BronzeZhao
	self.Menu:MenuElement({type = MENU, id = "Mode", name = "BronzeSeries: Xin Zhao"})
	--Main Menu-- BronzeZhao -- Combo
	self.Menu.Mode:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Mode.Combo:MenuElement({id = "Q", name = "Use Q", value = true, leftIcon = SpellIcons.Q})
	self.Menu.Mode.Combo:MenuElement({id = "W", name = "Use W", value = true, leftIcon = SpellIcons.W})
	self.Menu.Mode.Combo:MenuElement({id = "E", name = "Use E", value = true, leftIcon = SpellIcons.E})
	self.Menu.Mode.Combo:MenuElement({id = "R", name = "Use R", value = true, leftIcon = SpellIcons.R})
	self.Menu.Mode.Combo:MenuElement({id = "RHP", name = "R when target HP%", value = 30, min = 0, max = 100, step = 1})
	self.Menu.Mode.Combo:MenuElement({type = MENU, id = "Spell", name = "Summoner Spells"})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "I", name = "Use Ignite", value = true, leftIcon = SpellIcons.I})		
	self.Menu.Mode.Combo.Spell:MenuElement({id = "IMode", name = "Ignite Mode", drop = {"Killable", "Custom"}})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "IHP", name = "Ignite when target HP%", value = 50, min = 0, max = 100, step = 1})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "S", name = "Use Smite", value = true, leftIcon= SpellIcons.S})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "SMode", name = "Smite Mode", drop = {"Killable", "Custom"}, tooltip = "Will cast on Killable mode just if you have blue Smite"})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "SHP", name = "Smite when target HP%", value = 50, min = 0, max = 100, step = 1})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "EX", name = "Use Exhaust", value = true, leftIcon= SpellIcons.EX})
	self.Menu.Mode.Combo.Spell:MenuElement({id = "EXHP", name = "Exhaust when target HP%", value = 50, min = 0, max = 100, step = 1})
	--Main Menu-- BronzeZhao -- Harass
	self.Menu.Mode:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	self.Menu.Mode.Harass:MenuElement({id = "E", name = "Use E", value = true, leftIcon = SpellIcons.E})
	self.Menu.Mode.Harass:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	self.Menu.Mode.Harass.MM:MenuElement({id = "EMana", name = "Min Mana to E in Harass(%)", value = 40, min = 0, max = 100, step = 1})
	--Main Menu-- BronzeZhao -- LaneClear
	self.Menu.Mode:MenuElement({type = MENU, id = "LaneClear", name = "Lane Clear"})
	self.Menu.Mode.LaneClear:MenuElement({id = "W", name = "Use W", value = true, leftIcon = SpellIcons.W})
	self.Menu.Mode.LaneClear:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	self.Menu.Mode.LaneClear.MM:MenuElement({id = "WMana", name = "Min Mana to W in Lane Clear(%)", value = 40, min = 0, max = 100, step = 1})
	self.Menu.Mode.LaneClear:MenuElement({id = "WMinion", name = "Use W when X minions", value = 3,min = 1, max = 4, step = 1})
	--Main Menu-- BronzeZhao -- JungleClear
	self.Menu.Mode:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
	self.Menu.Mode.JungleClear:MenuElement({id = "Q", name = "Use Q", value = true, leftIcon = SpellIcons.Q})
	self.Menu.Mode.JungleClear:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	self.Menu.Mode.JungleClear.MM:MenuElement({id = "QMana", name = "Min Mana to Q in Jungle Clear(%)", value = 40, min = 0, max = 100, step = 1})
	self.Menu.Mode.JungleClear:MenuElement({id = "W", name = "Use W", value = true, leftIcon = SpellIcons.W})
	self.Menu.Mode.JungleClear.MM:MenuElement({id = "WMana", name = "Min Mana to W in Jungle Clear(%)", value = 40, min = 0, max = 100, step = 1})
	self.Menu.Mode.JungleClear:MenuElement({id = "E", name = "Use E", value = true, leftIcon = SpellIcons.E})
	self.Menu.Mode.JungleClear.MM:MenuElement({id = "EMana", name = "Min Mana to E in Jungle Clear(%)", value = 40, min = 0, max = 100, step = 1})
	--Main Menu-- BronzeZhao -- Spell Range 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Spell Range"})
	self.Menu.Drawing:MenuElement({id = "E", name = "Draw E Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
	self.Menu.Drawing:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
end

function XinZhao:Tick()
	local Combo = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]) or (_G.GOS and _G.GOS:GetMode() == "Combo") or (_G.EOWLoaded and EOW:Mode() == "Combo")
	local Clear = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]) or (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR]) or (_G.GOS and _G.GOS:GetMode() == "Clear") or (_G.EOWLoaded and EOW:Mode() == "LaneClear")
	local LastHit = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT]) or (_G.GOS and _G.GOS:GetMode() == "Lasthit") or (_G.EOWLoaded and EOW:Mode() == "LastHit")
	local Harass = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]) or (_G.GOS and _G.GOS:GetMode() == "Harass") or (_G.EOWLoaded and EOW:Mode() == "Harass")
	if Combo then
		self:Combo()
	elseif Clear then
		self:Clear()
	elseif Harass then
		self:Harass()		
	end	
end

local ItemHotKey = {
    [ITEM_1] = HK_ITEM_1,
    [ITEM_2] = HK_ITEM_2,
    [ITEM_3] = HK_ITEM_3,
    [ITEM_4] = HK_ITEM_4,
    [ITEM_5] = HK_ITEM_5,
    [ITEM_6] = HK_ITEM_6,
}

local function GetItemSlot(unit, id)
  for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(i).itemID == id then
      return i
    end
  end
  return 0 
end

function XinZhao:HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
	local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function XinZhao:GetValidEnemy(range)
    for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < E.range then
            return true
        end
    end
    return false
end

function XinZhao:GetValidMinion(range)
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < E.range then
            return true
        end
    end
    return false
end

function XinZhao:CountEnemyMinions(range)
	local minionsCount = 0
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < E.range then
            minionsCount = minionsCount + 1
        end
    end
    return minionsCount
end

local function Ready(spell) 
  	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end

function XinZhao:isReady (spell)
	return Game.CanUseSpell(spell) == 0 
end


function XinZhao:IsValidTarget(unit,range)
    return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= Q.range
end

function XinZhao:Combo()

	if self:GetValidEnemy(800) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(800, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(800,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
		
		if self:IsValidTarget(target,650) and self.Menu.Mode.Combo.E:Value() and self:isReady(_E) and not myHero.isChanneling  then
		Control.CastSpell(HK_E,target)
	    	if self:IsValidTarget(target,200) and self.Menu.Mode.Combo.W:Value() and self:isReady(_W) and not myHero.isChanneling  then
		Control.CastSpell(HK_W)
	    	end
	    	if self:IsValidTarget(target,200) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and myHero.attackData.state == STATE_WINDUP  then
		Control.CastSpell(HK_Q)
	    	end 
	    	if self:IsValidTarget(target,500) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and self.Menu.Mode.Combo.RHP:Value()/100 and not myHero.isChanneling  then
		Control.CastSpell(HK_R)
	    	end
	    end		
		if self:IsValidTarget(target,200) and self.Menu.Mode.Combo.W:Value() and self:isReady(_W) and not myHero.isChanneling  then
		Control.CastSpell(HK_W)
	    	if self:IsValidTarget(target,200) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and myHero.attackData.state == STATE_WINDUP  then
		Control.CastSpell(HK_Q)
	    	end
	    	if self:IsValidTarget(target,500) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and self.Menu.Mode.Combo.RHP:Value()/100 and not myHero.isChanneling  then
		Control.CastSpell(HK_R)
	    	end
	    end	
	    if self:IsValidTarget(target,200) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and myHero.attackData.state == STATE_WINDUP  then
		Control.CastSpell(HK_Q)
	    	if self:IsValidTarget(target,500) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and self.Menu.Mode.Combo.RHP:Value()/100 and not myHero.isChanneling  then
		Control.CastSpell(HK_R)
	    	end
	    end   
		if self:IsValidTarget(target,500) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and self.Menu.Mode.Combo.RHP:Value()/100 and not myHero.isChanneling  then
		Control.CastSpell(HK_R)
	    end
	if self.Menu.Mode.Combo.Spell.I:Value() then 
   		if self.Menu.Mode.Combo.Spell.IMode:Value() == 2 and myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and self:isReady(SUMMONER_1) then
       		if self:IsValidTarget(target, 600, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.IHP:Value()/100 then
            	Control.CastSpell(HK_SUMMONER_1, target)
       		end
		elseif  self.Menu.Mode.Combo.Spell.IMode:Value() == 2 and myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and self:isReady(SUMMONER_2) then
        	if self:IsValidTarget(target, 600, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.IHP:Value()/100 then
           		 Control.CastSpell(HK_SUMMONER_2, target)
       		end
		elseif  self.Menu.Mode.Combo.Spell.IMode:Value() == 1 and myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and self:isReady(SUMMONER_1) then
       	 	if self:IsValidTarget(target, 600, true, myHero) and 50+20*myHero.levelData.lvl > target.health*1.1 then
           		Control.CastSpell(HK_SUMMONER_1, target)
       	 	end
		elseif self.Menu.Mode.Combo.Spell.IMode:Value() == 1  and myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and self:isReady(SUMMONER_2) then
       		 if self:IsValidTarget(target, 600, true, myHero) and 50+20*myHero.levelData.lvl > target.health*1.1 then
           		Control.CastSpell(HK_SUMMONER_2, target)
        	end
    	end 
    end
    if self.Menu.Mode.Combo.Spell.S:Value() then 
   		if self.Menu.Mode.Combo.Spell.SMode:Value() == 2 and myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel"  and self:isReady(SUMMONER_1) then
       		if self:IsValidTarget(target, 500, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.SHP:Value()/100 then
            	Control.CastSpell(HK_SUMMONER_1, target)
       		end
		elseif  self.Menu.Mode.Combo.Spell.SMode:Value() == 2 and myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmiteDuel" and self:isReady(SUMMONER_2) then
        	if self:IsValidTarget(target, 500, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.SHP:Value()/100 then
           		 Control.CastSpell(HK_SUMMONER_2, target)
       		end	
    end
    if self.Menu.Mode.Combo.Spell.S:Value() then 
   		if self.Menu.Mode.Combo.Spell.SMode:Value() == 2 and myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker"  and self:isReady(SUMMONER_1) then
       		if self:IsValidTarget(target, 500, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.SHP:Value()/100 then
            	Control.CastSpell(HK_SUMMONER_1, target)
       		end
		elseif  self.Menu.Mode.Combo.Spell.SMode:Value() == 2 and myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" and self:isReady(SUMMONER_2) then
        	if self:IsValidTarget(target, 500, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.SHP:Value()/100 then
           		 Control.CastSpell(HK_SUMMONER_2, target)
       		end
       	elseif  self.Menu.Mode.Combo.Spell.SMode:Value() == 1 and myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker" and self:isReady(SUMMONER_1) then
       	 	if self:IsValidTarget(target, 500, true, myHero) and 20+8*myHero.levelData.lvl > target.health*1 then
           		Control.CastSpell(HK_SUMMONER_1, target)
       	 	end
		elseif self.Menu.Mode.Combo.Spell.SMode:Value() == 1  and myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" and self:isReady(SUMMONER_2) then
       		 if self:IsValidTarget(target, 500, true, myHero) and 20+8*myHero.levelData.lvl > target.health*1 then
           		Control.CastSpell(HK_SUMMONER_2, target)
        	end
    	end 
    end
    if self.Menu.Mode.Combo.Spell.EX:Value() then 
   		if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust"  and self:isReady(SUMMONER_1) then
       		if self:IsValidTarget(target, 500, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.EXHP:Value()/100 then
            	Control.CastSpell(HK_SUMMONER_1, target)
       		end
		elseif  myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" and self:isReady(SUMMONER_2) then
        	if self:IsValidTarget(target, 500, true, myHero) and target.health/target.maxHealth <= self.Menu.Mode.Combo.Spell.EXHP:Value()/100 then
           		 Control.CastSpell(HK_SUMMONER_2, target)
       		end
       	end		
    end      		
end
end

function XinZhao:Harass()

	if self:GetValidEnemy(800) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(800, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(800,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
		
	    if self:IsValidTarget(target,650) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.Harass.MM.EMana:Value() / 100) and self.Menu.Mode.Harass.E:Value() and self:isReady(_E) and not myHero.isChanneling  then
		Control.CastSpell(HK_E,target)
	end
end

function XinZhao:Clear()

	if self:GetValidMinion(600) == false then return end
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team == 200 then
			if self:IsValidTarget(minion,W.range) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.LaneClear.MM.WMana:Value() / 100) and self.Menu.Mode.LaneClear.W:Value() and self:isReady(_W) then
				if self:CountEnemyMinions(W.range) >= self.Menu.Mode.LaneClear.WMinion:Value() then
					Control.CastSpell(HK_W)
				break
			end 
		end
		elseif minion.team == 300 then
			if self:IsValidTarget(minion,Q.range) and self.Menu.Mode.JungleClear.Q:Value() and self:isReady(_Q) then
				Control.CastSpell(HK_Q)
				break
			end 
			if  self:IsValidTarget(minion,W.range) and self.Menu.Mode.JungleClear.W:Value() and self:isReady(_W) then
				Control.CastSpell(HK_W)
				break
			end	
			if  self:IsValidTarget(minion,E.range) and self.Menu.Mode.JungleClear.E:Value() and self:isReady(_E) then
				Control.CastSpell(HK_E,target)
				break
			end	
		end		
	end
end

function XinZhao:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end


function XinZhao:Draw()
	--Draw Range
	if myHero.dead then return end
		if self.Menu.Drawing.E:Value() then Draw.Circle(myHero.pos, 650, self.Menu.Drawing.Width:Value(), self.Menu.Drawing.Color:Value())	
		end	
end

function OnLoad()
	if myHero.charName ~= "XinZhao" then return end
	XinZhao()
end
