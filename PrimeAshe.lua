class "Ashe"

function Ashe:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Ashe:LoadSpells()
	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end

function Ashe:LoadMenu()
	--Main Menu
	self.Menu = MenuElement({type = MENU, id = "Menu", name = "Ashe"})
	
	--Main Menu-- Ashe
	self.Menu:MenuElement({type = MENU, id = "Mode", name = "Prime Ashe"})
	--Main Menu-- Ashe -- Combo
	self.Menu.Mode:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Mode.Combo:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "R", name = "Use R KS combo", value = true, tooltip = "R > W > AA > AA"})
	--Main Menu-- Ashe -- KS
	self.Menu.Mode:MenuElement({type = MENU, id = "KS", name = "Killsteal"})
	self.Menu.Mode.KS:MenuElement({id = "R", name = "Use R", value = true})
	--Main Menu-- Ashe -- Harass
	self.Menu.Mode:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	self.Menu.Mode.Harass:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.Harass:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.Harass:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	self.Menu.Mode.Harass.MM:MenuElement({id = "Mana", name = "Min Mana to Harass(%)", value = 40, min = 0, max = 100, step = 1})
	--Main Menu-- Ashe -- LaneClear
	self.Menu.Mode:MenuElement({type = MENU, id = "LaneClear", name = "Lane Clear"})
	self.Menu.Mode.LaneClear:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.LaneClear:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.LaneClear:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	self.Menu.Mode.LaneClear.MM:MenuElement({id = "Mana", name = "Min Mana to Lane Clear(%)", value = 40, min = 0, max = 100, step = 1})
	--Main Menu-- Ashe -- JungleClear
	self.Menu.Mode:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
	self.Menu.Mode.JungleClear:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.JungleClear:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.JungleClear:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	self.Menu.Mode.JungleClear.MM:MenuElement({id = "Mana", name = "Min Mana to Jungle Clear(%)", value = 40, min = 0, max = 100, step = 1})
	--Main Menu-- Ashe -- Spell Range 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Spell Range"})
	self.Menu.Drawing:MenuElement({id = "W", name = "Draw W Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Width", name = "Width", value = 3, min = 1, max = 5, step = 1})
	self.Menu.Drawing:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 0, 0, 255)})
end

function Ashe:Tick()
	local Combo = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]) or (_G.GOS and _G.GOS:GetMode() == "Combo") or (_G.EOWLoaded and EOW:Mode() == "Combo")
	local Clear = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]) or (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR]) or (_G.GOS and _G.GOS:GetMode() == "Clear") or (_G.EOWLoaded and EOW:Mode() == "LaneClear")
	local Harass = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]) or (_G.GOS and _G.GOS:GetMode() == "Harass") or (_G.EOWLoaded and EOW:Mode() == "Harass")
	if Combo then
		self:Combo()
	elseif Clear then
		self:Clear()
		self:JClear()
	elseif Harass then
		self:Harass()		
	end	
		self:KS()
end

function Ashe:HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
	local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function Ashe:GetValidEnemy(range)
    for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 2000 then
            return true
        end
    end
    return false
end

function Ashe:GetValidMinion(range)
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 2000 then
            return true
        end
    end
    return false
end

function Ashe:CountEnemyMinions(range)
	local minionsCount = 0
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 2000 then
            minionsCount = minionsCount + 1
        end
    end
    return minionsCount
end

local function Ready(spell) 
  	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end

function Ashe:isReady (spell)
	return Game.CanUseSpell(spell) == 0 
end

function Ashe:IsValidTarget(unit,range)
    return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 1500
end

function Ashe:Combo()

	if self:GetValidEnemy(1500) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(1500, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(1500,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())	
	    
	    if self:IsValidTarget(target,1200) and self.Menu.Mode.Combo.W:Value() and target:GetCollision(W.width,W.speed,W.delay) == 0 and self:isReady(_W) and myHero.attackData.state == STATE_WINDDOWN then
			Control.CastSpell(HK_W,target:GetPrediction(W.speed, W.delay))
	    end

		if self:IsValidTarget(target,550) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and myHero.attackData.state == STATE_WINDDOWN then
			Control.CastSpell(HK_Q)
	    end 
		
		if self:IsValidTarget(target,1500) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) then
			local levelW = myHero:GetSpellData(_W).level
			local level = myHero:GetSpellData(_R).level
			local Rdmg = ({200, 400, 600})[level] + myHero.ap + ({20, 35, 50, 65, 80})[levelW] + myHero.totalDamage * 2 
			if Rdmg >= self:HpPred(target,1) + target.hpRegen * 2 then
				Control.CastSpell(HK_R,target:GetPrediction(R.speed, R.delay))
			end
	end
end

function Ashe:KS()
    if self:GetValidEnemy(1700) == false then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(1700, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(1700,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
	
	local level = myHero:GetSpellData(_R).level
	if level == nil or level == 0 then return end
	
	for i = 1, Game.HeroCount() do
		local target = Game.Hero(i)
		if self:IsValidTarget(target,R.range) and target.team ~= myHero.team and self:isReady(_R) and self.Menu.Mode.KS.R:Value() then
			local Rdmg = ({200, 400, 600})[level] + myHero.ap
			if Rdmg >= self:HpPred(target,1) + target.hpRegen * 2 then
				Control.CastSpell(HK_R,target:GetPrediction(R.speed, R.delay))
			end
		end
	end
end

function Ashe:Harass()

	if self:GetValidEnemy(1200) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(1200, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(1200,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
		
	    if self:IsValidTarget(target,600) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.Harass.MM.Mana:Value() / 100) and self.Menu.Mode.Harass.Q:Value() and self:isReady(_Q) and not myHero.isChanneling  then
			Control.CastSpell(HK_Q)
		end
		if self:IsValidTarget(target,1200) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.Harass.MM.Mana:Value() / 100) and self.Menu.Mode.Harass.W:Value() and self:isReady(_W) and not myHero.isChanneling  then
			Control.CastSpell(HK_W,target:GetPrediction(W.speed, W.delay))
		end
end

function Ashe:Clear()

	if self:GetValidMinion(600) == false then return end
	
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team == 200 then
			if self:IsValidTarget(minion,600) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.LaneClear.MM.Mana:Value() / 100) and self.Menu.Mode.LaneClear.Q:Value() and self:isReady(_Q) then
					Control.CastSpell(HK_Q)
				break
			end
			if self:IsValidTarget(minion,600) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.LaneClear.MM.Mana:Value() / 100) and self.Menu.Mode.LaneClear.W:Value() and self:isReady(_W) then
					Control.CastSpell(HK_W,minion.pos)
				break
			end
		end
	end
end

function Ashe:JClear()

	if self:GetValidMinion(600) == false then return end
	
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team == 300 then
			if self:IsValidTarget(minion,600) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.JungleClear.MM.Mana:Value() / 100) and self.Menu.Mode.JungleClear.Q:Value() and self:isReady(_Q) then
					Control.CastSpell(HK_Q)
				break
			end
			if self:IsValidTarget(minion,600) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.JungleClear.MM.Mana:Value() / 100) and self.Menu.Mode.JungleClear.W:Value() and self:isReady(_W) then
					Control.CastSpell(HK_W,minion.pos)
				break
			end
		end
	end
end

function Ashe:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end


function Ashe:Draw()
	if myHero.dead then return end
		if self.Menu.Drawing.W:Value() then Draw.Circle(myHero.pos, 1200, self.Menu.Drawing.Width:Value(), self.Menu.Drawing.Color:Value())
		end
end


function OnLoad()
	if myHero.charName ~= "Ashe" then return end
	Ashe()
end
