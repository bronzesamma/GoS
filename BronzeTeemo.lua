class "Teemo"

function Teemo:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Teemo:LoadSpells()
	Q = {range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width}
	W = {range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width}
	E = {range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width}
	R = {range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width}
end

function Teemo:LoadMenu()

	-------Menu------------------------------------------------------------------------------
	self.Menu = MenuElement({type = MENU, id = "Menu", name = "Teemo"})
	-------BronzeSeries----------------------------------------------------------------------
	self.Menu:MenuElement({type = MENU, id = "Mode", name = "BronzeSeries: Teemo"})
	-------Combo---------------------------------------------------------------------------------------
	self.Menu.Mode:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Mode.Combo:MenuElement({id = "Q", name = "Use [Q]", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "W", name = "Use [W]", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "R", name = "Use [R]", value = true})
	-------LaneClear------------------------------------------------------------------------------------
	self.Menu.Mode:MenuElement({type = MENU, id = "LaneClear", name = "Lane Clear"})
	self.Menu.Mode.LaneClear:MenuElement({id = "Q", name = "Use [Q]", value = true})
	self.Menu.Mode.LaneClear:MenuElement({id = "R", name = "Use [R]", value = true})
	self.Menu.Mode.LaneClear:MenuElement({id = "RKillMinion", name = "Use [R] when X minions", value = 3,min = 0, max = 7, step = 1})
	self.Menu.Mode.LaneClear:MenuElement({type = MENU, id = "mm", name = "Mana Manager"})
	self.Menu.Mode.LaneClear.mm:MenuElement({id = "Qmana", name = "Min. mana to [Q]", value = 40, min = 0, max = 100, step = 2})
	self.Menu.Mode.LaneClear.mm:MenuElement({id = "Rmana", name = "Min. mana to [R]", value = 40, min = 0, max = 100, step = 2})
	-------JungleClear--------------------------------------------------------------------------------------------------------
	self.Menu.Mode:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
	self.Menu.Mode.JungleClear:MenuElement({id = "Q", name = "Use [Q]", value = true})
	self.Menu.Mode.JungleClear:MenuElement({id = "R", name = "Use [R]", value = true})
	self.Menu.Mode.JungleClear:MenuElement({type = MENU, id = "mm", name = "Mana Manager"})
	self.Menu.Mode.JungleClear.mm:MenuElement({id = "Qmana", name = "Min. mana to [Q]", value = 40, min = 0, max = 100, step = 2})
	self.Menu.Mode.JungleClear.mm:MenuElement({id = "Rmana", name = "Min. mana to [R]", value = 40, min = 0, max = 100, step = 2})
	-------Drawing----------------------------------------------------------------------
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "BronzeSeries: Drawings"})
	self.Menu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = true})
	self.Menu.Drawing:MenuElement({id = "R", name = "Draw [R] Range", value = true})

end

function Teemo:Tick()
	local Combo = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]) or (_G.GOS and _G.GOS:GetMode() == "Combo") or (_G.EOWLoaded and EOW:Mode() == "Combo")
	local Clear = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]) or (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR]) or (_G.GOS and _G.GOS:GetMode() == "Clear") or (_G.EOWLoaded and EOW:Mode() == "LaneClear")
	if Combo then
		self:Combo()
	elseif Clear then
		self:Clear()
	end
end

function Teemo:HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
	local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function Teemo:GetValidEnemy(range)
    for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < range then
            return true
        end
    end
    return false
end

function Teemo:GetValidMinion(range)
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < range then
            return true
        end
    end
    return false
end

function Teemo:CountEnemyMinions(range)
	local minionsCount = 0
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < range then
            minionsCount = minionsCount + 1
        end
    end
    return minionsCount
end

function Teemo:isReady (spell)
	return Game.CanUseSpell(spell) == 0 
end

function Teemo:IsValidTarget(unit,range)
    return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= range
end

function Teemo:Combo()

	if self:GetValidEnemy(1000) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(1000, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(1000,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
		
	if self:IsValidTarget(target,Q.range) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and not myHero.isChanneling then
		Control.CastSpell(HK_Q,target)
	end 
			
	if self:IsValidTarget(target,700) and self.Menu.Mode.Combo.W:Value() and self:isReady(_W) and not myHero.isChanneling  then
		Control.CastSpell(HK_W)
	end
	
	if self:IsValidTarget(target,R.range) and self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and not myHero.isChanneling then
		Control.CastSpell(HK_R,target)
	end
end

function Teemo:Clear()

	if self:GetValidMinion(600) == false then return end

	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team == 200 then
		
			if self:IsValidTarget(minion,Q.range) and self.Menu.Mode.LaneClear.Q:Value() and self:isReady(_Q) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.LaneClear.mm.Qmana:Value() / 100) and not myHero.isChanneling then
				Control.CastSpell(HK_Q,target)
				break
			end

			if  self:IsValidTarget(minion,R.range) and self.Menu.Mode.LaneClear.R:Value() and self:isReady(_R) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.LaneClear.mm.Rmana:Value() / 100) and not myHero.isChanneling then
				if self:CountEnemyMinions(R.range) >= self.Menu.Mode.LaneClear.RKillMinion:Value() then
					Control.CastSpell(HK_R,target)
				break
			end
		elseif minion.team == 300 then
			if self:IsValidTarget(minion,Q.range) and self.Menu.Mode.JungleClear.Q:Value() and self:isReady(_Q) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.JungleClear.mm.Qmana:Value() / 100) and not myHero.isChanneling then
				Control.CastSpell(HK_Q,target)
				break
			end

			if  self:IsValidTarget(minion,R.range) and self.Menu.Mode.JungleClear.R:Value() and self:isReady(_R) and (myHero.mana/myHero.maxMana >= self.Menu.Mode.JungleClear.mm.Rmana:Value() / 100) and not myHero.isChanneling then
				Control.CastSpell(HK_R,target)
				break
			end

		end

	end
end	
end

function Teemo:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end

function Teemo:Draw()
	if myHero.dead then return end
	if self.Menu.Drawing.Q:Value() then Draw.Circle(myHero.pos,Q.range,3,Draw.Color(255, 0, 0, 220)) end			
	if self.Menu.Drawing.R:Value() then Draw.Circle(myHero.pos,R.range,3,Draw.Color(220,255,0,0)) end	
end

function OnLoad()
	if myHero.charName ~= "Teemo" then return end
	Teemo()
end
