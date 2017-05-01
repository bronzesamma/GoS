class "Lucian"

function Lucian:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Lucian:LoadSpells()
	Q = { range = 600 }
	W = { range = 125 }
	E = { range = 200 }
	R = { range = 700 }
end

function Lucian:LoadMenu()
	local MenuIcons = "http://static.lolskill.net/img/champions/64/lucian.png"
	local SpellIcons = { Q = "http://static.lolskill.net/img/abilities/64/Lucian_Q.png",
						 W = "http://static.lolskill.net/img/abilities/64/Lucian_W.png",
						 E = "http://static.lolskill.net/img/abilities/64/Lucian_E.png",
						 R = "http://static.lolskill.net/img/abilities/64/Lucian_R.png", }
	--Main Menu
	self.Menu = MenuElement({type = MENU, id = "Menu", name = "Lucian", leftIcon = MenuIcons})
	
	--Main Menu-- Lucian
	self.Menu:MenuElement({type = MENU, id = "Mode", name = "Prime Lucian"})
	--Main Menu-- Lucian -- Combo
	self.Menu.Mode:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Mode.Combo:MenuElement({id = "Q", name = "Use Q", value = true, leftIcon = SpellIcons.Q})
	self.Menu.Mode.Combo:MenuElement({id = "W", name = "Use W", value = true, leftIcon = SpellIcons.W})
	self.Menu.Mode.Combo:MenuElement({id = "E", name = "Use E", value = true, leftIcon = SpellIcons.E})
	self.Menu.Mode.Combo:MenuElement({name = "E Dash Range", id = "Range", value = 125, min = 100, max = 425, step = 5})
	self.Menu.Mode.Combo:MenuElement({id = "R", name = "Use R", value = true, leftIcon = SpellIcons.R})
	self.Menu.Mode.Combo:MenuElement({id = "ROK", name = "R % Overkill", value = 100, min = 100, max = 300, step = 5})
	--Main Menu-- Lucian -- Harass
	self.Menu.Mode:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	self.Menu.Mode.Harass:MenuElement({id = "Q", name = "Use Q", value = true, leftIcon = SpellIcons.Q})
	self.Menu.Mode.Harass:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	self.Menu.Mode.Harass.MM:MenuElement({id = "QMana", name = "Min Mana to Q in Harass(%)", value = 40, min = 0, max = 100, step = 1})
	--Main Menu-- Lucian -- LaneClear
	self.Menu.Mode:MenuElement({type = MENU, id = "LaneClear", name = "Lane Clear"})
	self.Menu.Mode.LaneClear:MenuElement({id = "Q", name = "Use Q", value = true, leftIcon = SpellIcons.Q})
	self.Menu.Mode.LaneClear:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	self.Menu.Mode.LaneClear.MM:MenuElement({id = "QMana", name = "Min Mana to Q in Lane Clear(%)", value = 40, min = 0, max = 100, step = 1})
	--Main Menu-- Lucian -- Spell Range 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Spell Range"})
	self.Menu.Drawing:MenuElement({id = "W", name = "Draw W Range", value = true})
	self.Menu.Drawing:MenuElement({id = "R", name = "Draw R Range", value = true})
	self.Menu.Drawing:MenuElement({id = "Width", name = "Width", value = 3, min = 1, max = 5, step = 1})
	self.Menu.Drawing:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 0, 0, 255)})
end

function Lucian:Tick()
	local Combo = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]) or (_G.GOS and _G.GOS:GetMode() == "Combo") or (_G.EOWLoaded and EOW:Mode() == "Combo")
	local Clear = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]) or (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR]) or (_G.GOS and _G.GOS:GetMode() == "Clear") or (_G.EOWLoaded and EOW:Mode() == "LaneClear")
	local Harass = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]) or (_G.GOS and _G.GOS:GetMode() == "Harass") or (_G.EOWLoaded and EOW:Mode() == "Harass")
	if Combo then
		self:Combo()
	elseif Clear then
		self:Clear()
	elseif Harass then
		self:Harass()		
	end	
end

local VectorPointProjectionOnLineSegment = function(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
        local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
        local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
        local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
        local isOnSegment = rS == rL
        local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), y = ay + rS * (by - ay)}
	return pointSegment, pointLine, isOnSegment
end

local CircleCircleIntersection = function(c1, c2, r1, r2) 
        local D = GetDistance(c1, c2)
        if D > r1 + r2 or D <= math.abs(r1 - r2) then return nil end 
        local A = (r1 * r2 - r2 * r1 + D * D) / (2 * D) 
        local H = math.sqrt(r1 * r1 - A * A)
        local Direction = (c2 - c1):Normalized() 
        local PA = c1 + A * Direction 
        local S1 = PA + H * Direction:Perpendicular() 
        local S2 = PA - H * Direction:Perpendicular() 
        return S1, S2 
end

local ClosestToMouse = function(p1, p2) 
        if GetDistance(mousePos, p1) > GetDistance(mousePos, p2) then return p2 else return p1 end
end

local CastE = function(target, mode, range) 
        	local pos = Vector(myHero.pos):Extended(mousePos, range)
        	Control.CastSpell(HK_E, pos)
end 

function  Lucian:isCasting(spell)
	if Game.CanUseSpell(spell) == 8 or myHero:GetSpellData(_R).name == "LucianRCancel" then
		return  true
	end
	return false
end

function Lucian:HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
	local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function Lucian:GetValidEnemy(range)
    for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < Q.range then
            return true
        end
    end
    return false
end

function Lucian:GetValidMinion(range)
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < Q.range then
            return true
        end
    end
    return false
end

function Lucian:CountEnemyMinions(range)
	local minionsCount = 0
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < Q.range then
            minionsCount = minionsCount + 1
        end
    end
    return minionsCount
end

local function Ready(spell) 
  	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end

function Lucian:isReady (spell)
	return Game.CanUseSpell(spell) == 0 
end

function Lucian:IsValidTarget(unit,range)
    return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= Q.range
end

function Lucian:Combo()

	if self:GetValidEnemy(2500) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(1200, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(1200,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
		
	    if self:IsValidTarget(target,500) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and myHero.attackData.state == STATE_WINDDOWN  and not self:isCasting(_R) then
			Control.CastSpell(HK_Q,target)
	    end 	
	    
	    if self:IsValidTarget(target,900) and self.Menu.Mode.Combo.W:Value() and self:isReady(_W) and myHero.attackData.state == STATE_WINDDOWN  and not self:isCasting(_R) then
			Control.CastSpell(HK_W,target)
	    end

		if self:IsValidTarget(target,E.range*2) and self.Menu.Mode.Combo.E:Value() and self:isReady(_E) and myHero.attackData.state == STATE_WINDDOWN  then
			CastE(target, self.Menu.Mode.Combo.Range:Value())
	    end

		if self:IsValidTarget(target,R.range) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and not self:isCasting(_R) then
			local level = myHero:GetSpellData(_R).level
			local Rdmg = (({20, 35, 50})[level] + 0.1 * myHero.ap + 0.20 * myHero.totalDamage) * (({20, 25, 30})[level])
			if Rdmg >= self:HpPred(target,1) * (self.Menu.Mode.Combo.ROK:Value() / 100) + target.hpRegen * 2 then
				Control.CastSpell(HK_R,target)
			end
		end
end


function Lucian:Harass()

	if self:GetValidEnemy(500) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(500, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(500,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
		
	    if self:IsValidTarget(target,500) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.Harass.MM.QMana:Value() / 100) and self.Menu.Mode.Harass.Q:Value() and self:isReady(_Q) and not myHero.isChanneling  then
		Control.CastSpell(HK_Q,target)
	end
end

function Lucian:Clear()

	if self:GetValidMinion(900) == false then return end
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team == 200 then
			if self:IsValidTarget(minion,500) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.LaneClear.MM.QMana:Value() / 100) and self.Menu.Mode.LaneClear.Q:Value() and self:isReady(_Q) then
				if self:CountEnemyMinions(Q.range) >= 2 then
					Control.CastSpell(HK_Q,target)
				break
				end
			end
		end	
	end
end

function Lucian:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end


function Lucian:Draw()
	--Draw Range
	if myHero.dead then return end
		if self.Menu.Drawing.W:Value() then Draw.Circle(myHero.pos, 900, self.Menu.Drawing.Width:Value(), self.Menu.Drawing.Color:Value())
		end
		if self.Menu.Drawing.R:Value() then Draw.Circle(myHero.pos, 1200, self.Menu.Drawing.Width:Value(), self.Menu.Drawing.Color:Value())	
		end	
end


function OnLoad()
	if myHero.charName ~= "Lucian" then return end
	Lucian()
end
