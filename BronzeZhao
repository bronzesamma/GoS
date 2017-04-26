class "XinZhao"

function XinZhao:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function XinZhao:LoadSpells()
	Q = myHero:GetSpellData(_Q)
	W = myHero:GetSpellData(_W)
	E = { range = 650 }
end

function XinZhao:LoadMenu()
	local MenuIcons = "http://static.lolskill.net/img/champions/64/xinzhao.png"
	local SpellIcons = { Q = "http://static.lolskill.net/img/abilities/64/XinZhao_ThreeTalon.png",
						 W = "http://static.lolskill.net/img/abilities/64/XinZhao_BattleCry.png",
						 E = "http://static.lolskill.net/img/abilities/64/XinZhao_Charge.png" }

	--Main Menu
	self.Menu = MenuElement({type = MENU, id = "Menu", name = "XinZhao", leftIcon = MenuIcons})
	
	--Main Menu-- Mode Setting
	self.Menu:MenuElement({type = MENU, id = "Mode", name = "Mode Settings"})
	--Main Menu-- Mode Setting-- Combo
	self.Menu.Mode:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Mode.Combo:MenuElement({id = "Q", name = "Use Q", value = true, leftIcon = SpellIcons.Q})
	self.Menu.Mode.Combo:MenuElement({id = "W", name = "Use W", value = true, leftIcon = SpellIcons.W})
	self.Menu.Mode.Combo:MenuElement({id = "E", name = "Use E", value = true, leftIcon = SpellIcons.E})
	--Main Menu-- Drawing 
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
	self.Menu.Drawing:MenuElement({id = "E", name = "Draw E Range", value = true})

end

function XinZhao:Tick()
	local Combo = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]) or (_G.GOS and _G.GOS:GetMode() == "Combo") or (_G.EOWLoaded and EOW:Mode() == "Combo")
	local Clear = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]) or (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR]) or (_G.GOS and _G.GOS:GetMode() == "Clear") or (_G.EOWLoaded and EOW:Mode() == "LaneClear")
	local LastHit = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT]) or (_G.GOS and _G.GOS:GetMode() == "Lasthit") or (_G.EOWLoaded and EOW:Mode() == "LastHit")
	if Combo then
		self:Combo()
	end
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
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < range then
            return true
        end
    end
    return false
end

function XinZhao:CountEnemyMinions(range)
	local minionsCount = 0
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < range then
            minionsCount = minionsCount + 1
        end
    end
    return minionsCount
end

function XinZhao:isReady (spell)
	return Game.CanUseSpell(spell) == 0 
end

function XinZhao:IsValidTarget(unit,range)
    return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= E.range
end

function XinZhao:Combo()

	if self:GetValidEnemy(800) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(800, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(800,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
		
	    if self:IsValidTarget(target,175) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and myHero.attackData.state == 3  then
		Control.CastSpell(HK_Q)
	end 
			
	    if self:IsValidTarget(target,175) and self.Menu.Mode.Combo.W:Value() and self:isReady(_W) and not myHero.isChanneling  then
		Control.CastSpell(HK_W)
	end

		  if self:IsValidTarget(target,E.range) and self.Menu.Mode.Combo.E:Value() and self:isReady(_E) and not myHero.isChanneling  then
		Control.CastSpell(HK_E,target)
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
	if self.Menu.Drawing.E:Value() then Draw.Circle(myHero.pos,E.range,1,Draw.Color(255, 0, 0, 220)) end			
end

function OnLoad()
	if myHero.charName ~= "XinZhao" then return end
	XinZhao()
end
