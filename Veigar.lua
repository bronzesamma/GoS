if myHero.charName ~= "Veigar" then return end

local function Ready (spell)
	return Game.CanUseSpell(spell) == 0 
end

local function ValidTarget(unit,range)
    return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) > 1
end

local function GetBuffIndexByName(unit,name)
	for i=1,unit.buffCount do
		local buff=unit:GetBuff(i)
		if buff.name==name then
			return i
		end
	end
end


local function GetBuffData(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff
    end
  end
  return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

local function GetEnemy(range)
  	for i = 1,Game.HeroCount() do
    	local enemy = Game.Hero(i)
    	if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) > 1 then
    		return true
    	end
    end
  	return false
end

local function GetAlly(range)
  	for i = 1,Game.HeroCount() do
    	local ally = Game.Hero(i)
    	if  ally.team == myHero.team and ally.valid and ally.pos:DistanceTo(myHero.pos) > 1 then
    		return true
    	end
    end
  	return false
end

local function GetMinion(range)
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 3000 then
			return true
        end
    end
    return false
end

local function EnemiesAround(pos, range)
    local Count = 0
    for i = 1, Game.HeroCount() do
        local e = Game.Hero(i)
        if e and e.team ~= myHero.team and not e.dead and e.pos:DistanceTo(pos, e.pos) > 1 then
            Count = Count + 1
        end
    end
    return Count
end

local function MinionsAround(pos, range, team)
    local Count = 0
    for i = 1, Game.MinionCount() do
        local m = Game.Minion(i)
        if m and m.team == 200 and not m.dead and m.pos:DistanceTo(pos, m.pos) > 1 then
            Count = Count + 1
        end
    end
    return Count
end

local function HasCC(unit)
	for i = 0, unit.buffCount do
		local buff = myHero:GetBuff(i);
		if buff.count > 0 then
			if ((buff.type == 5) or (buff.type == 8) or (buff.type == 9) or (buff.type == 10) or (buff.type == 11) or (buff.type == 21) or (buff.type == 22) or (buff.type == 24) or (buff.type == 28) or (buff.type == 29) or (buff.type == 31)) then
				return true
			end
		end
	end
	return false
end

local function IsStunned(unit)
	for i = 0, unit.buffCount do
		local buff = myHero:GetBuff(i);
		if buff.count > 0 then
			if buff.type == 5 then
				return true
			end
		end
	end
	return false
end

local function HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function GetValidAlly(range)
  	for i = 1,Game.HeroCount() do
    	local ally = Game.Hero(i)
    	if  ally.team == myHero.team and ally.valid and ally.pos:DistanceTo(myHero.pos) > 1 then
    		return true
    	end
    end
  	return false
end


local function HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end

local function AllyHeroes()
	local _AllyHeroes
	if _AllyHeroes then return _AllyHeroes end
	_AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.isAlly then
			table.insert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

local function GetPercentHP(unit)
  if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
  return 100*unit.health/unit.maxHealth
end

local function GetPercentMP(unit)
  if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
  return 100*unit.mana/unit.maxMana
end

class "Veigar"

function Veigar:__init()
  	self:LoadSpells()
  	self:LoadMenu()
	self.Enemies = {}
	self.Allies = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isAlly then
			table.insert(self.Allies,hero)
		else
			table.insert(self.Enemies,hero)
		end	
	end	
  	Callback.Add("Tick", function() self:Tick() end)
  	Callback.Add("Draw", function() self:Draw() end)
end

function Veigar:LoadSpells()
  	Q = { delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width } W = { delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width } E = { delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width } R = { delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end

function Veigar:LoadMenu()
  	local Icons = { C = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/8/8f/VeigarSquare.png", Q = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/f/fd/Baleful_Strike.png", W = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/1/17/Dark_Matter.png", E = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/8/81/Event_Horizon.png", R = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/e/e7/Primordial_Burst.png" }
	-- TRA
  	self.Menu = MenuElement({type = MENU, id = "Menu", name = "The Ripper Series"})
	-- Annie
	self.Menu:MenuElement({type = MENU, id = "Ripper", name = "Veigar The Ripper", leftIcon = Icons.C })
	-- Combo
  	self.Menu.Ripper:MenuElement({type = MENU, id = "Combo", name = "Combo"})
  	self.Menu.Ripper.Combo:MenuElement({id = "Q", name = "[Q] Baleful Strike", value = true, leftIcon = Icons.Q})
	self.Menu.Ripper.Combo:MenuElement({id = "W", name = "[W] Dark Matter", value = true, leftIcon = Icons.W})
  	self.Menu.Ripper.Combo:MenuElement({id = "E", name = "[E] Event Horizon", value = true, leftIcon = Icons.E})
	self.Menu.Ripper.Combo:MenuElement({id = "R", name = "[R] Primordial Burst", value = true, leftIcon = Icons.R})
	self.Menu.Ripper.Combo:MenuElement({id = "WS", name = "[W] wait for Stun", value = true})
	self.Menu.Ripper.Combo:MenuElement({id = "EM", name = "[E] mode", drop = {"Edge", "Zone"}})
	-- Last
  	self.Menu.Ripper:MenuElement({type = MENU, id = "LastHit", name = "Last Hit"})
  	self.Menu.Ripper.LastHit:MenuElement({id = "Q", name = "[Q] Baleful Strike", value = true, leftIcon = Icons.Q})
    self.Menu.Ripper.LastHit:MenuElement({id = "Mana", name = "Min mana to LastHit (%)", value = 40, min = 0, max = 100})
	-- Lane
  	self.Menu.Ripper:MenuElement({type = MENU, id = "LaneClear", name = "Lane Clear"})
  	self.Menu.Ripper.LaneClear:MenuElement({id = "Q", name = "[Q] Baleful Strike", value = true, leftIcon = Icons.Q})
	self.Menu.Ripper.LaneClear:MenuElement({id = "W", name = "[W] Dark Matter", value = true, leftIcon = Icons.W})
    self.Menu.Ripper.LaneClear:MenuElement({id = "HW", name = "Min minions hit by [W]", value = 4, min = 1, max = 7})
    self.Menu.Ripper.LaneClear:MenuElement({id = "Mana", name = "Min mana to Clear (%)", value = 40, min = 0, max = 100})
	-- Jungle
  	self.Menu.Ripper:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
  	self.Menu.Ripper.JungleClear:MenuElement({id = "Q", name = "[Q] Baleful Strike", value = true, leftIcon = Icons.Q})
	self.Menu.Ripper.JungleClear:MenuElement({id = "W", name = "[W] Dark Matter", value = true, leftIcon = Icons.W})
    self.Menu.Ripper.JungleClear:MenuElement({id = "Mana", name = "Min mana to Clear (%)", value = 40, min = 0, max = 100})
	-- Harass
  	self.Menu.Ripper:MenuElement({type = MENU, id = "Harass", name = "Harass"})
  	self.Menu.Ripper.Harass:MenuElement({id = "Q", name = "[Q] Baleful Strike", value = true, leftIcon = Icons.Q})
  	self.Menu.Ripper.Harass:MenuElement({id = "W", name = "[W] Dark Matter", value = true, leftIcon = Icons.W})
	self.Menu.Ripper.Harass:MenuElement({id = "E", name = "[E] Event Horizon", value = true, leftIcon = Icons.E})
	self.Menu.Ripper.Harass:MenuElement({id = "WS", name = "[W] wait for Stun", value = true})
	self.Menu.Ripper.Harass:MenuElement({id = "EM", name = "[E] mode", drop = {"Edge", "Zone"}})
    self.Menu.Ripper.Harass:MenuElement({id = "Mana", name = "Min mana to Harass (%)", value = 40, min = 0, max = 100})
	-- Flee
  	self.Menu.Ripper:MenuElement({type = MENU, id = "Flee", name = "Flee"})
  	self.Menu.Ripper.Flee:MenuElement({id ="E", name = "[E] Event Horizon", value = true, leftIcon = Icons.E})
	-- KS
  	self.Menu.Ripper:MenuElement({type = MENU, id = "KS", name = "Killsteal"})
  	self.Menu.Ripper.KS:MenuElement({id = "Q", name = "[Q] Baleful Strike", value = true, leftIcon = Icons.Q})
  	self.Menu.Ripper.KS:MenuElement({id = "W", name = "[W] Dark Matter", value = true, leftIcon = Icons.W})
	self.Menu.Ripper.KS:MenuElement({id = "R", name = "[R] Primordial Burst", value = true, leftIcon = Icons.R})	
	-- Misc
  	self.Menu.Ripper:MenuElement({type = MENU, id = "Misc", name = "Misc"})
	self.Menu.Ripper.Misc:MenuElement({id = "AI", name = "Auto [Q] Last Hit", value = true})
	-- Draws
  	self.Menu.Ripper:MenuElement({type = MENU, id = "Drawings", name = "Drawings"})
  	self.Menu.Ripper.Drawings:MenuElement({id = "Q", name = "Draw [Q] range", value = true, leftIcon = Icons.Q})
  	self.Menu.Ripper.Drawings:MenuElement({id = "W", name = "Draw [W] range", value = true, leftIcon = Icons.W})
	self.Menu.Ripper.Drawings:MenuElement({id = "E", name = "Draw [E] range", value = true, leftIcon = Icons.E})
  	self.Menu.Ripper.Drawings:MenuElement({id = "R", name = "Draw [R] range", value = true, leftIcon = Icons.R})
  	self.Menu.Ripper.Drawings:MenuElement({id = "Width", name = "Width", value = 2, min = 1, max = 5, step = 1})
	self.Menu.Ripper.Drawings:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 0, 0, 255)})
end

function Veigar:Tick()
  	local Combo = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]) or (_G.GOS and _G.GOS:GetMode() == "Combo") or (_G.EOWLoaded and EOW:Mode() == "Combo")
  	local LastHit = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT]) or (_G.GOS and _G.GOS:GetMode() == "Lasthit") or (_G.EOWLoaded and EOW:Mode() == "LastHit")
  	local Clear = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]) or (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR]) or (_G.GOS and _G.GOS:GetMode() == "Clear") or (_G.EOWLoaded and EOW:Mode() == "LaneClear")
  	local Harass = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]) or (_G.GOS and _G.GOS:GetMode() == "Harass") or (_G.EOWLoaded and EOW:Mode() == "Harass")
  	local Flee = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE]) or (_G.GOS and _G.GOS:GetMode() == "Flee") or (_G.EOWLoaded and EOW:Mode() == "Flee")
  	if Combo then
    	self:Combo()
	elseif Clear then
		self:LaneClear()
		self:JungleClear()
    elseif LastHit then
    	self:LastHit()
	elseif Harass then
		self:Harass()
	elseif Flee then
		self:Flee()
	end
		self:Misc()
		self:KS()
end

function Veigar:MinionsAround(pos, range, team)
    local Count = 0
    for i = 1, Game.MinionCount() do
        local m = Game.Minion(i)
        if m and m.team == 200 and not m.dead and m.pos:DistanceTo(pos, m.pos) <= 112.5 then
            Count = Count + 1
        end
    end
    return Count
end

function Veigar:Stunned(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and buff.type == 5 and buff.count > 0 and Game.Timer() < buff.expireTime then
			return buff
		end
	end
	return false
end

function Veigar:Combo()
	if GetEnemy(950) == false then return end
  	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
  	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(950, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(950,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
	if ValidTarget(target,950) and myHero.pos:DistanceTo(target.pos) < 950 and self.Menu.Ripper.Combo.Q:Value() and Ready(_Q) then
        Control.CastSpell(HK_Q,target:GetPrediction(Q.speed,Q.delay))
    end
	if ValidTarget(target,700) and myHero.pos:DistanceTo(target.pos) < 700 and self.Menu.Ripper.Combo.E:Value() and Ready(_E) then
        if self.Menu.Ripper.Combo.EM:Value() == 1 then
			Control.CastSpell(HK_E, Vector(target:GetPrediction(E.speed,E.delay))-Vector(Vector(target:GetPrediction(E.speed,E.delay))-Vector(myHero.pos)):Normalized()*350)
		elseif self.Menu.Ripper.Combo.EM:Value() == 2 then
			Control.CastSpell(HK_E,target:GetPrediction(E.speed,E.delay))
		end
    end
    if ValidTarget(target,900) and myHero.pos:DistanceTo(target.pos) < 900 and self.Menu.Ripper.Combo.W:Value() and Ready(_W) then
        if self.Menu.Ripper.Combo.WS:Value() and not self:Stunned(target) then return end
			Control.CastSpell(HK_W,target:GetPrediction(W.speed,W.delay))
    end
	if ValidTarget(target,650) and myHero.pos:DistanceTo(target.pos) < 650 and self.Menu.Ripper.Combo.R:Value() and Ready(_R) then
		local level = myHero:GetSpellData(_R).level
    	local dmg = GetPercentHP(target) > 33.3 and ({175, 250, 325})[level] + 0.75 * myHero.ap or ({350, 500, 650})[level] + 1.5 * myHero.ap
		local Rdamage = dmg +((0.015 * dmg) * (100 - ((target.health / target.maxHealth) * 100)))
		if 	Rdamage >= HpPred(target,1) * 1.2 + target.hpRegen * 2 then
			Control.CastSpell(HK_R,target)
		end
	end
end

function Veigar:LastHit()
	if self.Menu.Ripper.LastHit.Q:Value() == false then return end
  	local level = myHero:GetSpellData(_Q).level
  	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team == 200 then
			local Qdamage = (({70, 110, 150, 190, 230})[level] + 0.6 * myHero.ap)
			if ValidTarget(minion,950) and myHero.pos:DistanceTo(minion.pos) < 950 and Ready(_Q) and (myHero.mana/myHero.maxMana >= self.Menu.Ripper.LastHit.Mana:Value() / 100 ) and minion.isEnemy then
				if Qdamage >= HpPred(minion, 0.5) then
					Control.CastSpell(HK_Q,minion.pos)
				end
			end
      	end
	end
end

function Veigar:LaneClear()
  	local level = myHero:GetSpellData(_Q).level
  	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
		if  minion.team == 200 then
			local Qdamage = (({70, 110, 150, 190, 230})[level] + 0.6 * myHero.ap)
			if ValidTarget(minion,950) and myHero.pos:DistanceTo(minion.pos) < 950 and Ready(_Q) and self.Menu.Ripper.LaneClear.Q:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Ripper.LaneClear.Mana:Value() / 100 ) and minion.isEnemy then
				if Qdamage >= HpPred(minion, 0.5) then
					Control.CastSpell(HK_Q,minion.pos)
				end
			end
			if ValidTarget(minion,900) and Ready(_W) and myHero.pos:DistanceTo(minion.pos) < 500 and self.Menu.Ripper.LaneClear.W:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Ripper.LaneClear.Mana:Value() / 100 ) and minion.isEnemy then
				if self:MinionsAround(minion.pos, 112.5, 200) >= self.Menu.Ripper.LaneClear.HW:Value() then
					Control.CastSpell(HK_W,minion.pos)
				end
			end
		end
	end
end

function Veigar:JungleClear()
  	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    	if  minion.team == 300 then
			if ValidTarget(minion,950) and myHero.pos:DistanceTo(minion.pos) < 950 and self.Menu.Ripper.JungleClear.Q:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Ripper.JungleClear.Mana:Value() / 100 ) and Ready(_Q) then
				Control.CastSpell(HK_Q,minion.pos)
				break
			end
			if ValidTarget(minion,900) and myHero.pos:DistanceTo(minion.pos) < 900 and self.Menu.Ripper.JungleClear.W:Value() and (myHero.mana/myHero.maxMana >= self.Menu.Ripper.JungleClear.Mana:Value() / 100 ) and Ready(_W) then
				Control.CastSpell(HK_W,minion.pos)
				break
			end
		end
    end
end

function Veigar:Harass()
	if GetEnemy(950) == false then return end
  	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
  	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(950, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(950,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
    if ValidTarget(target,950) and myHero.pos:DistanceTo(target.pos) < 950 and target:GetCollision(Q.width,Q.speed,Q.delay) == 0 and (myHero.mana/myHero.maxMana > self.Menu.Ripper.Harass.Mana:Value() / 100) and self.Menu.Ripper.Harass.Q:Value() and Ready(_Q) then
        Control.CastSpell(HK_Q,target:GetPrediction(Q.speed,Q.delay))
    end
	if ValidTarget(target,700) and myHero.pos:DistanceTo(target.pos) < 700 and self.Menu.Ripper.Harass.E:Value() and Ready(_E) and (myHero.mana/myHero.maxMana > self.Menu.Ripper.Harass.Mana:Value() / 100) then
        if self.Menu.Ripper.Combo.EM:Value() == 1 then
			Control.CastSpell(HK_E, Vector(target:GetPrediction(E.speed,E.delay))-Vector(Vector(target:GetPrediction(E.speed,E.delay))-Vector(myHero.pos)):Normalized()*350)
		elseif self.Menu.Ripper.Combo.EM:Value() == 2 then
			Control.CastSpell(HK_E,target:GetPrediction(E.speed,E.delay))
		end
    end
    if ValidTarget(target,900) and myHero.pos:DistanceTo(target.pos) < 900 and (myHero.mana/myHero.maxMana > self.Menu.Ripper.Harass.Mana:Value() / 100) and self.Menu.Ripper.Harass.W:Value() and Ready(_W) then
		if self.Menu.Ripper.Harass.WS:Value() and not self:Stunned(target) then return end
			Control.CastSpell(HK_W,target:GetPrediction(W.speed,W.delay))
    end
end

function Veigar:Flee()
	if GetEnemy(700) == false then return end
  	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
  	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(700, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(700,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
    if ValidTarget(target,700) and myHero.pos:DistanceTo(target.pos) < 700 and self.Menu.Ripper.Flee.E:Value() and Ready(_E) then
        Control.CastSpell(HK_E,myHero.pos)
    end
end
  
function Veigar:KS()
	if GetEnemy(950) == false then return end
  	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
  	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(950, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(950,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
  	if ValidTarget(target,950) and myHero.pos:DistanceTo(target.pos) < 950 and self.Menu.Ripper.KS.Q:Value() and Ready(_Q) then
    	local level = myHero:GetSpellData(_Q).level
    	local Qdamage = CalcMagicalDamage(myHero, target, (({70, 110, 150, 190, 230})[level] + 0.6 * myHero.ap))
		if Qdamage >= HpPred(target,1) + target.hpRegen * 2 and target:GetCollision(Q.width,Q.speed,Q.delay) == 0 then
			Control.CastSpell(HK_Q,target:GetPrediction(Q.speed,Q.delay))
		end
	end
	if ValidTarget(target,900) and myHero.pos:DistanceTo(target.pos) < 900 and self.Menu.Ripper.KS.W:Value() and Ready(_W) then
    	local level = myHero:GetSpellData(_W).level
    	local Wdamage = CalcMagicalDamage(myHero, target, (({100, 150, 200, 250, 300})[level] + myHero.ap))
		if 	Wdamage >= HpPred(target,1) + target.hpRegen * 2 then
			Control.CastSpell(HK_W,target:GetPrediction(W.speed,W.delay))
		end
    end
	if ValidTarget(target,650) and myHero.pos:DistanceTo(target.pos) < 650 and self.Menu.Ripper.KS.R:Value() and Ready(_R) then
    	local level = myHero:GetSpellData(_R).level
    	local dmg = GetPercentHP(target) > 33.3 and ({175, 250, 325})[level] + 0.75 * myHero.ap or ({350, 500, 650})[level] + 1.5 * myHero.ap
		local Rdamage = dmg +((0.015 * dmg) * (100 - ((target.health / target.maxHealth) * 100)))
		if 	Rdamage >= HpPred(target,1) * 1.2 + target.hpRegen * 2 then
			Control.CastSpell(HK_R,target)
		end
    end
end

function Veigar:Misc()
  	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
  	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(625, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(625,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
	local level = myHero:GetSpellData(_Q).level
  	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team == 200 then
			local Qdamage = (({70, 110, 150, 190, 230})[level] + 0.6 * myHero.ap)
			if ValidTarget(minion,950) and myHero.pos:DistanceTo(minion.pos) < 950 and (myHero.mana/myHero.maxMana >= self.Menu.Ripper.LastHit.Mana:Value() / 100 ) and minion.isEnemy then
				if Qdamage >= HpPred(minion, 0.5) and Ready(_Q) and self.Menu.Ripper.Misc.AI:Value() then
					Control.CastSpell(HK_Q,minion.pos)
				end
			end
      	end
	end
end

function Veigar:Draw()
	if myHero.dead then return end
	if self.Menu.Ripper.Drawings.Q:Value() then Draw.Circle(myHero.pos, 950, self.Menu.Ripper.Drawings.Width:Value(), self.Menu.Ripper.Drawings.Color:Value()) end
	if self.Menu.Ripper.Drawings.W:Value() then Draw.Circle(myHero.pos, 900, self.Menu.Ripper.Drawings.Width:Value(), self.Menu.Ripper.Drawings.Color:Value()) end
	if self.Menu.Ripper.Drawings.E:Value() then Draw.Circle(myHero.pos, 700, self.Menu.Ripper.Drawings.Width:Value(), self.Menu.Ripper.Drawings.Color:Value()) end
	if self.Menu.Ripper.Drawings.R:Value() then Draw.Circle(myHero.pos, 650, self.Menu.Ripper.Drawings.Width:Value(), self.Menu.Ripper.Drawings.Color:Value()) end
end

if _G[myHero.charName]() then print("Hi, thanks for using " ..myHero.charName.. " The Ripper By: @Romanov and @juauzynhu") end
