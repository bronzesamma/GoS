class "Lucian"

function Lucian:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Lucian:LoadSpells()
	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end
	
function Lucian:LoadMenu()
	--Main Menu
	self.Menu = MenuElement({type = MENU, id = "Menu", name = "Lucian"})
	--Main Menu-- Lucian
	self.Menu:MenuElement({type = MENU, id = "Mode", name = "Prime Lucian"})
	--Main Menu-- Lucian -- Combo
	self.Menu.Mode:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Mode.Combo:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "E", name = "Use E", value = true})
	self.Menu.Mode.Combo:MenuElement({name = "E Dash Range", id = "Range", value = 125, min = 100, max = 425, step = 5})
	self.Menu.Mode.Combo:MenuElement({id = "R", name = "Use R", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "ROK", name = "R % Overkill", value = 100, min = 100, max = 300, step = 5})
	--Main Menu-- Lucian -- Harass
	self.Menu.Mode:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	self.Menu.Mode.Harass:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.Harass:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.Harass:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	self.Menu.Mode.Harass.MM:MenuElement({id = "Mana", name = "Min Mana to Harass(%)", value = 40, min = 0, max = 100, step = 1})
	--Main Menu-- Lucian -- LaneClear
	self.Menu.Mode:MenuElement({type = MENU, id = "LaneClear", name = "Lane Clear"})
	self.Menu.Mode.LaneClear:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.LaneClear:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.LaneClear:MenuElement({id = "E", name = "Use E", value = true})
	self.Menu.Mode.LaneClear:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	self.Menu.Mode.LaneClear.MM:MenuElement({id = "Mana", name = "Min Mana to Lane Clear(%)", value = 40, min = 0, max = 100, step = 1})
	--Main Menu-- Lucian -- JungleClear
	self.Menu.Mode:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
	self.Menu.Mode.JungleClear:MenuElement({id = "Q", name = "Use Q", value = true})
	self.Menu.Mode.JungleClear:MenuElement({id = "W", name = "Use W", value = true})
	self.Menu.Mode.JungleClear:MenuElement({id = "E", name = "Use E", value = true})
	self.Menu.Mode.JungleClear:MenuElement({type = MENU, id = "MM", name = "Mana Manager"})
	self.Menu.Mode.JungleClear.MM:MenuElement({id = "Mana", name = "Min Mana to Lane Clear(%)", value = 40, min = 0, max = 100, step = 1})
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
		self:JClear()
	elseif Harass then
		self:Harass()		
	end
		self:AbleAA()
		self:DisableAA()
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
        	Control.CastSpell(HK_E, pos * -1)
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
    return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 1500
end

function Lucian:DisableAA()
		if self:isCasting(_R)
			then _G.SDK.Orbwalker:SetAttack(false)
		end
end

function Lucian:AbleAA()
		if not self:isCasting(_R)
			then _G.SDK.Orbwalker:SetAttack(true)
		end
end

function Lucian:Combo()

	if self:GetValidEnemy(2500) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(1200, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(1200,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
		
	    if self:IsValidTarget(target,500) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and myHero.attackData.state == STATE_WINDDOWN  and not self:isCasting(_R) then
			Control.CastSpell(HK_Q,target)
	    end 	
	    
	    if self:IsValidTarget(target,900) and self.Menu.Mode.Combo.W:Value() and self:isReady(_W) and target:GetCollision(W.width,W.speed,W.delay) and myHero.attackData.state == STATE_WINDDOWN  and not self:isCasting(_R) then
			Control.CastSpell(HK_W,target:GetPrediction(W.speed, W.delay))
	    end

		if self:IsValidTarget(target,E.range*2) and self.Menu.Mode.Combo.E:Value() and self:isReady(_E) and myHero.attackData.state == STATE_WINDDOWN  then
			CastE(target, self.Menu.Mode.Combo.Range:Value())
	    end

		if self:IsValidTarget(target,R.range) and self.Menu.Mode.Combo.R:Value() and target:GetCollision(R.width,R.speed,R.delay) and self:isReady(_R) and not self:isCasting(_R) then
			local level = myHero:GetSpellData(_R).level
			local Rdmg = (({20, 35, 50})[level] + 0.1 * myHero.ap + 0.20 * myHero.totalDamage) * (({20, 25, 30})[level])
			if Rdmg >= self:HpPred(target,1) * (self.Menu.Mode.Combo.ROK:Value() / 100) + target.hpRegen * 2 then
					Control.CastSpell(HK_R,target:GetPrediction(R.speed, R.delay))
				end
			end
end


function Lucian:Harass()

	if self:GetValidEnemy(900) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(900, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(900,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
		
	    if self:IsValidTarget(target,500) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.Harass.MM.Mana:Value() / 100) and self.Menu.Mode.Harass.Q:Value() and self:isReady(_Q) and not myHero.isChanneling  then
			Control.CastSpell(HK_Q,target)
		end
		if self:IsValidTarget(target,900) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.Harass.MM.Mana:Value() / 100) and self.Menu.Mode.Harass.W:Value() and self:isReady(_W) and not myHero.isChanneling  then
			Control.CastSpell(HK_Q,target:GetPrediction(W.speed, W.delay))
		end
end

function Lucian:Clear()

	if self:GetValidMinion(600) == false then return end
	
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team == 200 then
			if self:IsValidTarget(minion,500) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.LaneClear.MM.Mana:Value() / 100) and self.Menu.Mode.LaneClear.Q:Value() and self:isReady(_Q) then
					Control.CastSpell(HK_Q,minion.pos)
				break
			end
			if self:IsValidTarget(minion,600) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.LaneClear.MM.Mana:Value() / 100) and self.Menu.Mode.LaneClear.W:Value() and self:isReady(_W) then
					Control.CastSpell(HK_W,minion.pos)
				break
			end
			if self:IsValidTarget(minion,600) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.LaneClear.MM.Mana:Value() / 100) and self.Menu.Mode.LaneClear.E:Value() and self:isReady(_E) then
					Control.CastSpell(HK_E)
				break
			end
		end
	end
end

function Lucian:JClear()

	if self:GetValidMinion(600) == false then return end
	
		for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team == 300 then
			if self:IsValidTarget(minion,500) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.JungleClear.MM.Mana:Value() / 100) and self.Menu.Mode.JungleClear.Q:Value() and self:isReady(_Q) then
					Control.CastSpell(HK_Q,minion.pos)
				break
			end
			if self:IsValidTarget(minion,600) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.JungleClear.MM.Mana:Value() / 100) and self.Menu.Mode.JungleClear.W:Value() and self:isReady(_W) then
					Control.CastSpell(HK_W,minion.pos)
				break
			end
			if self:IsValidTarget(minion,600) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.JungleClear.MM.Mana:Value() / 100) and self.Menu.Mode.JungleClear.E:Value() and self:isReady(_E) then
					Control.CastSpell(HK_E)
				break
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
