
if myHero.charName ~= "Syndra" then return end

local function GetManaPercentage(unit)
	return unit.mana/unit.maxMana
end
local function GetHPPercentage(unit)
	return unit.health/unit.maxHealth
end

local function Ready (spell)
	return Game.CanUseSpell(spell) == 0 
end

local function ValidTarget(obj,range)
	range = range and range or math.huge
	return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and not obj.isImmortal and obj.distance <= range
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

local function GetDistanceSqr(p1, p2)
    assert(p1, "GetDistance: invalid argument: cannot calculate distance to "..type(p1))
    p2 = p2 or myHero.pos
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

local function GetDistance(p1, p2)
    return math.sqrt(GetDistanceSqr(p1, p2))
end

local function ValidTarget(unit,range,from)
	from = from or myHero.pos
	range = range or math.huge
	return unit and unit.valid and not unit.dead and unit.visible and unit.isTargetable and GetDistanceSqr(unit.pos,from) <= range*range
end

local function VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
end

function GetBestCircularFarmPosition(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in pairs(objects) do
        local hit = CountObjectsNearPos(object.pos, range, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = object.pos
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in pairs(objects) do
        if GetDistanceSqr(pos, object.pos) <= radius * radius then
            n = n + 1
        end
    end
    return n
end

local function HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end

local Balls = {}
local Orbs = {}
local Sphere = false

local Icon = { 	C = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/6/65/SyndraSquare.png",
				Q = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/6/62/Dark_Sphere.png",
				W = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/d/d2/Force_of_Will.png",
				E = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/9/9c/Scatter_the_Weak.png",
				R = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/1/1d/Unleashed_Power.png" }

local Syndra = MenuElement({type = MENU, id = "Syndra", name = "Ripper Syndra", leftIcon = "http://ddragon.leagueoflegends.com/cdn/7.1.1/img/champion/Syndra.png"})
Syndra:MenuElement({type = MENU, id = "Combo", name = "Combo"})
Syndra.Combo:MenuElement({id = "UseQ", name = "[Q] Dark Sphere", value = true, leftIcon = Icon.Q})
Syndra.Combo:MenuElement({id = "UseW", name = "[W] Force of Will", value = true, leftIcon = Icon.W})
Syndra.Combo:MenuElement({id = "UseE", name = "[E] Scatter the Weak", value = true, leftIcon = Icon.E})
Syndra.Combo:MenuElement({id = "UseR", name = "[R] Unleashed Power", value = true, leftIcon = Icon.R})

Syndra:MenuElement({type = MENU, id = "Harass", name = "Harass"})
Syndra.Harass:MenuElement({id = "UseQ", name = "[Q] Dark Sphere", value = true, leftIcon = Icon.Q})
Syndra.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass(%)", value = 65, min = 0, max = 100})

Syndra:MenuElement({type = MENU, id = "Clear", name = "Lane/Jungle Clear"})
Syndra.Clear:MenuElement({id = "Usage", name = "Spells Usage", key = string.byte("A"),toggle = true})
Syndra.Clear:MenuElement({id = "UseQ", name = "[Q] Dark Sphere", value = true, leftIcon = Icon.Q})
Syndra.Clear:MenuElement({id = "UseW", name = "[W] Force of Will", value = true, leftIcon = Icon.W})
Syndra.Clear:MenuElement({id = "QHit", name = "[Q] if x minions", value = 3, min = 1, max = 7})
Syndra.Clear:MenuElement({id = "Mana", name = "Min Mana to Clear(%)", value = 50, min = 0, max = 100})

Syndra:MenuElement({type = MENU, id = "Lasthit", name = "Lasthit"})
Syndra.Lasthit:MenuElement({id = "UseQ", name = "[Q] Dark Sphere", value = true, leftIcon = Icon.Q})
Syndra.Lasthit:MenuElement({id = "Mana", name = "Min Mana to Lasthit (%)", value = 65, min = 0, max = 100})

Syndra:MenuElement({type = MENU, id = "Drawing", name = "Drawings"})
Syndra.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = true, leftIcon = Icon.Q})
Syndra.Drawing:MenuElement({id = "ColorQ", name = "Color", color = Draw.Color(255, 0, 0, 255)})
Syndra.Drawing:MenuElement({id = "DrawW", name = "Draw [W] Range", value = true, leftIcon = Icon.W})
Syndra.Drawing:MenuElement({id = "ColorW", name = "Color", color = Draw.Color(255, 0, 0, 255)})
Syndra.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = true, leftIcon = Icon.E})
Syndra.Drawing:MenuElement({id = "ColorE", name = "Color", color = Draw.Color(255, 0, 0, 255)})
Syndra.Drawing:MenuElement({id = "DrawR", name = "Draw [R] Range", value = true, leftIcon = Icon.R})
Syndra.Drawing:MenuElement({id = "ColorR", name = "Color", color = Draw.Color(255, 0, 0, 255)})
Syndra.Drawing:MenuElement({id = "DrawStatus", name = "Draw Clear Spell Status", value = true})

local Q = { delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width } 
local W = { delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width } 
local E = { delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width } 
local R = { range = 675, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }

function Combo()
	if GetEnemy(1100) == false then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(1100, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(1100,"AD"))
	if Ready(_R) and Syndra.Combo.UseR:Value() and ValidTarget(target,R.range) then
		local level = myHero:GetSpellData(_R).level
		local Rdmg = CalcMagicalDamage(myHero, target, (({270, 405, 540})[level] + 0.6 * myHero.ap) + (({90, 135, 180})[level] + 0.2 * myHero.ap) * (#Balls + 3))
		if Rdmg >= HpPred(target,1) + target.hpRegen * 2 then
			Control.CastSpell(HK_R,target)
		end
	end
	if Ready(_R) and Syndra.Combo.UseR:Value() and ValidTarget(target,R.range) then
		local level = myHero:GetSpellData(_R).level
		local Rdmg = CalcMagicalDamage(myHero, target, (({270, 405, 540})[level] + 0.6 * myHero.ap))
		if Rdmg >= HpPred(target,1) + target.hpRegen * 2 then
			Control.CastSpell(HK_R,target)
		end
	end
	if Ready(_Q) and Syndra.Combo.UseQ:Value() and ValidTarget(target,800) then
		Control.CastSpell(HK_Q,target:GetPrediction(Q.speed,Q.delay))
	end
	if Ready(_E) and Syndra.Combo.UseE:Value() then
		for i = 1, Game.HeroCount()  do
			local hero = Game.Hero(i)
			if hero.isEnemy and ValidTarget(hero, 1100) then
				for id, ball in pairs(Balls) do
					if GetDistanceSqr(ball.pos,myHero.pos) < 700*700 then
						local enemyPos = hero:GetPrediction(E.Speed,E.Delay)
						local endPos = ball.pos  + (ball.pos - myHero.pos):Normalized()*1100
						local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(ball.pos,endPos,enemyPos)
						if isOnSegment and GetDistanceSqr(pointSegment,enemyPos) < 190*190 then
							Control.CastSpell(HK_E,ball.pos)
						end
					end
				end
			end		
		end
	end
	if Ready(_W) and ValidTarget(target,925) then
		if myHero:GetSpellData(_W).toggleState == 2 then
			Control.CastSpell(HK_W,target:GetPrediction(W.speed,W.delay))
		elseif myHero:GetSpellData(_W).toggleState == 1 then
			if Grab() then
				Control.CastSpell(HK_W,Grab())
			end
		end
	end
	if Ready(_Q) and Ready(_E) and Syndra.Combo.UseQ:Value() and Syndra.Combo.UseE:Value() then
		if ValidTarget(target,1100) then
			local pos = target:GetPrediction(2000,0.943)
			pos = myHero.pos + (pos - myHero.pos):Normalized()*(800 - 65)
			Control.SetCursorPos(pos) 
			Control.KeyDown(HK_Q)
			DelayAction(function() Control.KeyDown(HK_E) Control.KeyUp(HK_Q) Control.KeyUp(HK_E) end, 0.75)
		end
	end
end

function Grab()
	for i, ball in pairs(Balls) do
		if GetDistanceSqr(ball.pos) < 925*925 then
			return ball.pos
		end
	end
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.isEnemy and ValidTarget(minion,925)  then
			return minion.pos
		end
	end	
end

function Harass()
	if GetEnemy(800) == false then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(800, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(800,"AD"))
	if Ready(_Q) and Syndra.Harass.UseQ:Value() and ValidTarget(target,800) and (myHero.mana/myHero.maxMana > Syndra.Harass.Mana:Value() / 100) then
		Control.CastSpell(HK_Q,target:GetPrediction(Q.speed,Q.delay))
	end
end

function Lasthit()
	local level = myHero:GetSpellData(_Q).level
  	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team == 200 then
			local Qdamage = (({50, 95, 140, 185, 230})[level] + 0.75 * myHero.ap)
			if ValidTarget(minion,625) and myHero.pos:DistanceTo(minion.pos) < 625 and Syndra.Lasthit.UseQ:Value() and (myHero.mana/myHero.maxMana >= Syndra.Lasthit.Mana:Value() / 100 ) and minion.isEnemy then
				if Qdamage >= HpPred(minion, 0.5) and Ready(_Q) then
					Control.CastSpell(HK_Q,minion.pos)
				end
			end
      	end
	end
end

function MinionsAround(pos, range, team)
    local Count = 0
    for i = 1, Game.MinionCount() do
        local m = Game.Minion(i)
        if m and m.team == 200 and not m.dead and m.pos:DistanceTo(pos, m.pos) <= 160 then
            Count = Count + 1
        end
    end
    return Count
end

function CountEnemyMinions(range)
	local minionsCount = 0
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 925 then
            minionsCount = minionsCount + 1
        end
    end
    return minionsCount
end

function Clear()
	if Syndra.Clear.Usage:Value() == false then return end
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
		if  minion.team == 200 then
			if ValidTarget(minion,800) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 800 and Syndra.Clear.UseQ:Value() and (myHero.mana/myHero.maxMana >= Syndra.Clear.Mana:Value() / 100 ) and minion.isEnemy then
				if MinionsAround(minion.pos, 100, 200) >= Syndra.Clear.QHit:Value() then
					Control.CastSpell(HK_Q,minion.pos)
				end
			end
			if ValidTarget(minion,925) and Ready(_W) and myHero:GetSpellData(_W).toggleState == 2 and myHero.pos:DistanceTo(minion.pos) < 925 and Syndra.Clear.UseW:Value() and (myHero.mana/myHero.maxMana >= Syndra.Clear.Mana:Value() / 100 ) and minion.isEnemy then
				if MinionsAround(minion.pos, 160, 200) >= 2 then
					Control.CastSpell(HK_W,minion.pos)
				end
			end
			if ValidTarget(minion,925) and Ready(_W) and myHero:GetSpellData(_W).toggleState == 1 and myHero.pos:DistanceTo(minion.pos) < 925 and Syndra.Clear.UseW:Value() and (myHero.mana/myHero.maxMana >= Syndra.Clear.Mana:Value() / 100 ) and minion.isEnemy then
				if CountEnemyMinions(925) >= 3 then
					Control.CastSpell (HK_W,Grab())
				end
			end
		end
		if  minion.team == 300 then
			if ValidTarget(minion,800) and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < 800 and Syndra.Clear.UseQ:Value() and (myHero.mana/myHero.maxMana >= Syndra.Clear.Mana:Value() / 100 ) and minion.isEnemy then
				Control.CastSpell(HK_Q,minion.pos)
			end
			if ValidTarget(minion,925) and Ready(_W) and myHero:GetSpellData(_W).toggleState == 1 and myHero.pos:DistanceTo(minion.pos) < 925 and Syndra.Clear.UseW:Value() and (myHero.mana/myHero.maxMana >= Syndra.Clear.Mana:Value() / 100 ) and minion.isEnemy then
				Control.CastSpell(HK_W,Grab())
			end
			if ValidTarget(minion,925) and Ready(_W) and myHero:GetSpellData(_W).toggleState == 2 and myHero.pos:DistanceTo(minion.pos) < 925 and Syndra.Clear.UseW:Value() and (myHero.mana/myHero.maxMana >= Syndra.Clear.Mana:Value() / 100 ) and minion.isEnemy then
				Control.CastSpell(HK_W,minion.pos)
			end
		end
	end
end

function Orbs()
		for i = 0, Game.ObjectCount() do
			local obj = Game.Object(i)
			if obj and not obj.dead and obj.name:find("Seed") then
				Balls[obj.networkID] = obj
			end
		end	
end

function Transcendent()
	if not Q.Update and myHero:GetSpellData(_Q).level == 5 then
		Q.Update = true
	end	
	if not R.Update and myHero:GetSpellData(_R).level == 3 then
		R.Update = true
		R.Range = 750
	end
end

Callback.Add('Tick',function()
	if myHero:GetSpellData(_Q).currentCd == 0 then
		Sphere = false
	elseif myHero:GetSpellData(_Q).currentCd >  0 and not Sphere then
		Sphere = true
		DelayAction(function() Orbs() end,0.1)
	end
	if (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]) or (_G.GOS and _G.GOS:GetMode() == "Combo") then
		Combo()
	elseif 	(_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]) or (_G.GOS and _G.GOS:GetMode() == "Harass") then
		Harass()
	elseif (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]) or (_G.GOS and _G.GOS:GetMode() == "Clear") then
		Clear()
	elseif (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT]) or (_G.GOS and _G.GOS:GetMode() == "Lasthit") then
		Lasthit()
	end
	Transcendent()
end)

Callback.Add("Draw", function()
	if myHero.dead then return end
	if Syndra.Drawing.DrawQ:Value() and Ready(_Q) then Draw.Circle(myHero.pos, 800, 3, Syndra.Drawing.ColorQ:Value()) end
	if Syndra.Drawing.DrawW:Value() and Ready(_W) then Draw.Circle(myHero.pos, 925, 3, Syndra.Drawing.ColorW:Value()) end
	if Syndra.Drawing.DrawE:Value() and Ready(_E) then Draw.Circle(myHero.pos, 700, 3, Syndra.Drawing.ColorE:Value()) end
	if Syndra.Drawing.DrawR:Value() and Ready(_R) then Draw.Circle(myHero.pos, R.range, 3, Syndra.Drawing.ColorR:Value()) end
	if Syndra.Drawing.DrawStatus:Value() then
	       		local textPos = myHero.pos:To2D()
				if Syndra.Clear.Usage:Value() == true then
					Draw.Text("Spell Clear: On", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000)) 
				elseif Syndra.Clear.Usage:Value() == false then
					Draw.Text("Spell Clear: Off", 20, textPos.x - 80, textPos.y + 40, Draw.Color(255, 000, 255, 000)) 
				end
			end 
end)

Callback.Add("Load",function() end)
