require("barebones")
-- require("talents/talents")


function IsFrontAlly(hero,ally)
	local tbl = hero.waypoints
	if tbl then --AI
		local v1 = ally:GetAbsOrigin()-hero:GetAbsOrigin()
		local v2 = tbl[hero.headWayPoint]-hero:GetAbsOrigin()
		local cos = v1:Dot(v2)/(v1:Length()*v2:Length())
	    local angle = math.deg(math.acos(cos))
	    if cos>0.9999 then
	        angle=0.001
	    end
	    if angle<90 then
	    	return true
	    else
	    	return false
	    end
	else --Player
		local v1 = ally:GetAbsOrigin()-hero:GetAbsOrigin()
		local v2 = nil
		local vf1 = GetFountain(hero):GetAbsOrigin()-hero:GetAbsOrigin()
		local vf2 = GetEnemyFountain(hero):GetAbsOrigin()-hero:GetAbsOrigin()
		if vf1:Length2D() > vf2:Length2D() then
			v2 = vf2
		else
			v2 = vf1
		end
		local cos = v1:Dot(v2)/(v1:Length()*v2:Length())
	    local angle = math.deg(math.acos(cos))
	    if cos>0.9999 then
	        angle=0.001
	    end
	    if angle<90 then
	    	return true
	    else
	    	return false
	    end
	end
end
function IsInEnemyArea(u)
	local v0 = u:GetAbsOrigin()
	local v1 = GetFountain(u):GetAbsOrigin()
	local v2 = GetEnemyFountain(u):GetAbsOrigin()
	if (v1-v0):Length2D() < (v2-v0):Length2D() then
		return false
	else
		return true
	end
end
function AIHasStrongerHeroForce(allygroup, enemygroup)
	if #allygroup>=#enemygroup and #enemygroup>0 then
		return true
	end
	return false
end

function AICollectWayPoints(hero,way)
	hero.waypoints = WAY_POINTS[way]
	hero.way = way
end

function AIGetPositionWay(pOrg,team)
	local way = nil
	local tbl = nil
	local min1 = 99999
	local min2 = 99999
	local dist = nil
	if pOrg.y>pOrg.x then
		tbl = WAY_POINTS[1]
		for k,v in pairs(tbl) do
			dist=(v-pOrg):Length2D()
			if dist<min1 then
				min1=dist
			end
		end
		tbl = WAY_POINTS[2]
		for k,v in pairs(tbl) do
			dist=(v-pOrg):Length2D()
			if dist<min2 then
				min2=dist
			end
		end
		if min1<min2 then
			if team==DOTA_TEAM_GOODGUYS then
				return 1
			else
				return 4
			end
		else
			if team==DOTA_TEAM_GOODGUYS then
				return 2
			else
				return 5
			end
		end
	else
		tbl = WAY_POINTS[3]
		for k,v in pairs(tbl) do
			dist=(v-pOrg):Length2D()
			if dist<min1 then
				min1=dist
			end
		end
		tbl = WAY_POINTS[2]
		for k,v in pairs(tbl) do
			dist=(v-pOrg):Length2D()
			if dist<min2 then
				min2=dist
			end
		end
		if min1<min2 then
			if team==DOTA_TEAM_GOODGUYS then
				return 3
			else
				return 6
			end
		else
			if team==DOTA_TEAM_GOODGUYS then
				return 2
			else
				return 5
			end
		end
	end
end

function AIGetHeroWay(hero)
	if hero and hero:IsAlive() then
		if hero.way then --AI
			return hero.way
		else --玩家
			return AIGetPositionWay(hero:GetAbsOrigin(),hero:GetTeamNumber())
		end
	else
		return 0
	end
end
function AIFindClearWay(hero)
	local way = nil
	local w = nil
	local cal = {}
	for i=1,6 do
		cal[i]=0
	end
	for i=0,9 do
		local player = PlayerResource:GetPlayer(i)
		if player then
			local h = player:GetAssignedHero()
			if h and PlayerResource:GetTeam(i)==hero:GetTeamNumber() and h~=hero then
				if h:IsAlive() then
					w = AIGetHeroWay(h)
					if w>0 then
						cal[w]=cal[w]+1
					end
				end
			end
		end
	end
	if hero:GetTeamNumber()==DOTA_TEAM_GOODGUYS then
		if cal[1]>=cal[2] then
			if cal[2]>cal[3] then
				return 3
			else
				return 2
			end
		else
			if cal[1]>cal[3] then
				return 3
			else
				return 1
			end
		end
	else
		if cal[4]>=cal[5] then
			if cal[5]>cal[6] then
				return 6
			else
				return 5
			end
		else
			if cal[4]>cal[6] then
				return 6
			else
				return 4
			end
		end
	end
	return way
end
function AIFindAllyWay(hero)
	local way = nil
	local w = nil
	local cal = {}
	for i=1,6 do
		cal[i]=0
	end
	for i=0,9 do
		local player = PlayerResource:GetPlayer(i)
		if player then
			local h = player:GetAssignedHero()
			if h and PlayerResource:GetTeam(i)==hero:GetTeamNumber() and h~=hero then
				if h:IsAlive() then
					w = AIGetHeroWay(h)
					if w>0 then
						cal[w]=cal[w]+1
					end
				end
			end
		end
	end
	if hero:GetTeamNumber()==DOTA_TEAM_GOODGUYS then
		if cal[1]>cal[2] then
			if cal[1]>cal[3] then
				return 1
			else
				return 3
			end
		else
			if cal[2]>cal[3] then
				return 2
			else
				return 3
			end
		end
	else
		if cal[4]>cal[5] then
			if cal[4]>cal[6] then
				return 4
			else
				return 6
			end
		else
			if cal[5]>cal[6] then
				return 5
			else
				return 6
			end
		end
	end
	return way
end

function AIDecideWay(hero)
	local player = hero:GetPlayerOwner()
	local slot = player.teamSlot
	local way = nil
	local now = GameTime()
	print("AIDecideWay")
	if now<60 then
		if slot==2 or slot==3 then
			way=1
		elseif slot==1 then
			way=2
		elseif slot==4 or slot==5 then
			way=3
		elseif slot==7 or slot==8 then
			way=4
		elseif slot==6 then
			way=5
		elseif slot==9 or slot==10 then
			way=6
		end
	elseif now<600 then
		way = AIFindClearWay(hero)
	else
		way = AIFindAllyWay(hero)
	end
	if way==nil then
		if hero:GetTeamNumber()==DOTA_TEAM_GOODGUYS then
			way = 2
		else
			way = 5
		end
	end
	AICollectWayPoints(hero,way)
	hero.headWayPoint = 1
end

function AIChangeWay(hero,way)
	print(hero:GetUnitName().."change way to "..way)
	local tbl = WAY_POINTS[way]
	local name = nil
	local team = hero:GetTeamNumber()
	local dist = nil
	local max = 0
	local min = 99999
	local uPick = nil
	local fountain = GetFountain(hero)
	local pOrg = fountain:GetAbsOrigin()
	local pTgt = nil
	local c = 1
	local preWay = hero.way
	if team==DOTA_TEAM_GOODGUYS then
		name = "npc_dota_creep_goodguys_melee"
	else
		name = "npc_dota_creep_badguys_melee"
	end
	local units = Entities:FindAllByName("npc_dota_creature") 
	if #units>0 then
		for _,unit in pairs(units) do
			if unit and IsValidUnit(unit) then
				if unit:GetUnitName()==name and unit:IsAlive() and unit.way then
					if unit.way==way then
						dist = (unit:GetAbsOrigin()-pOrg):Length2D()
						if dist>max then
							max = dist
							uPick = unit
						end
					end
				end
			end
		end
	end
	AICollectWayPoints(hero,way)
	if uPick then
		pTgt = uPick:GetAbsOrigin()
		for k,v in pairs(tbl) do
			dist=(v-pTgt):Length2D()
			if dist<min then
				min=dist
				c = k
			end
		end
		hero.headWayPoint = math.max(c,1)
	else
		hero.headWayPoint = 1
	end
	--[[
	if way~=preWay then
		if way==1 or way==4 then
			GameRules:SendCustomMessage(PlayerResource:GetPlayerName(hero:GetPlayerID()).."is ready to move along top lane.", team, 0) 
		elseif way==2 or way==5 then
			GameRules:SendCustomMessage(PlayerResource:GetPlayerName(hero:GetPlayerID()).."is ready to move along middle lane.", team, 0) 
		elseif way==3 or way==6 then
			GameRules:SendCustomMessage(PlayerResource:GetPlayerName(hero:GetPlayerID()).."is ready to move along bottom lane.", team, 0) 
		end
	end
	]]
	--print("headWayPoint "..hero.headWayPoint)
end



function AICanDuel(hero,gt,enemyheroes,enemytowers)
	local pOrg = hero:GetAbsOrigin()
	local range = hero:GetAttackRange()+300
	local lf = 0
	local min = 99999
	local up = nil
	if #enemyheroes>0 then
		for k,enemy in pairs(enemyheroes) do
			if enemy then
				lf = enemy:GetHealth()
				if lf<min then
					min = lf
					up = enemy
				end
			end
		end
	end
	if up then
		if up:GetHealth()<hero:GetHealth() and (up:GetAbsOrigin()-hero:GetAbsOrigin()):Length2D()<range and #enemytowers==0 then
			return true
		end
	end
	return false
end
function AIAttackedByTowerRetreat(hero,tower)
	if tower:GetAttackTarget() then
		local a = hero:GetPhysicalArmorValue()
		local mayDamage = tower:GetAverageTrueAttackDamage(nil)*(1-6*a/(100+6*a))
		if tower:GetAttackTarget()==hero and hero:GetHealth()<mayDamage*12 and GameTime()<600 then
			return true
		end
	end
	return false
end

function AIFarm(hero,target,life,mayDamage,gt,allyheroes,enemyheroes,allies,enemies)
	if life<mayDamage then
		AIOrderAttackMove_Attack(hero,gt,target,allyheroes,enemyheroes,allies,enemies)

	else
	print("target =",target:GetUnitName())

		local k = 3
		if not hero:IsRangedAttacker() then
			local pOrg = hero:GetAbsOrigin()
			local pTgt = target:GetAbsOrigin()
			local dist = (pTgt-pOrg):Length2D() * 0.8
			local f = (pTgt-pOrg):Normalized()
			hero:MoveToPosition(pOrg+f*dist)
		end
		Timers:CreateTimer(0.1,function()
			if target==nil or not target:IsAlive() then
				--return nil
				print("AIFarm nil")
			else
				AIOrderAttackMove_Attack(hero,gt,target,allyheroes,enemyheroes,allies,enemies)
				--return nil
			end
		end)
	end

end

function AIkuroyuki(hero,unit)
  local pOrg = hero:GetAbsOrigin()
  local pTgt = unit:GetAbsOrigin()
  local dist = (pTgt-pOrg):Length2D()
  local id = hero:GetPlayerID()
  local mana = hero:GetMana()
  local ab1 = hero:FindAbilityByName("redmodel")
  local ab1lv = ab1:GetLevel()
  local redrange = ab1:GetLevelSpecialValueFor("red_range",ab1lv - 1) + 150
  local ab2 = hero:FindAbilityByName("bluemodel")
  local ab2lv = ab2:GetLevel()
  local ab3 = hero:FindAbilityByName("greenmodel")
  local ab3lv = ab3:GetLevel()
  local ab4 = hero:FindAbilityByName("starburststream")
  local ab4lv = ab4:GetLevel()
  local ab4range = ab4:GetCastRange() 
  local ab5 = hero:FindAbilityByName("stareclipse")
  local ab5lv = ab5:GetLevel()
  local ab5range = ab5:GetCastRange() 
  local herolf = hero:GetHealthPercent()
  if herolf > 30 then
     if ab1lv > 0 and 200 < dist then
	    if dist < redrange or ab5range < dist then
		   hero:CastAbilityNoTarget(ab1, id)
		   if ab4:IsCooldownReady() and ab4lv>0 and mana > ab4:GetManaCost(-1) then 
		      hero:CastAbilityOnPosition(pTgt, ab4, id)
		   end
           elseif ab2lv > 0 then
	    hero:CastAbilityNoTarget(ab2, id)
	    if ab5:IsCooldownReady() and ab5lv>0 and mana > ab5:GetManaCost(-1) then
		   hero:CastAbilityOnTarget(unit, ab5, id) 
		   end
		end
	  elseif ab2lv > 0 then
	    hero:CastAbilityNoTarget(ab2, id)
	    if ab5:IsCooldownReady() and ab5lv>0 and mana > ab5:GetManaCost(-1) then
		   hero:CastAbilityOnTarget(unit, ab5, id) 
		   end
	  end
	elseif ab3lv > 0 then
	hero:CastAbilityNoTarget(ab3, id)
  end

end

function AIshana(hero,unit)
  local pOrg = hero:GetAbsOrigin()
  local pTgt = unit:GetAbsOrigin()
  local dist = (pTgt-pOrg):Length2D()
  local id = hero:GetPlayerID()
  local mana = hero:GetMana()
  local ab1 = hero:FindAbilityByName("shanatruered")
  local ab1lv = ab1:GetLevel()
  local ab2 = hero:FindAbilityByName("alasterhand")
  local ab2lv = ab2:GetLevel()
  local ab2range = ab2:GetCastRange() 
  local ab3 = hero:FindAbilityByName("flamewing")
  local ab3lv = ab3:GetLevel()
  local ab3range = ab3:GetCastRange() 
  local ab4 = hero:FindAbilityByName("judgment")
  local ab4lv = ab4:GetLevel()
  local ab5 = hero:FindAbilityByName("Conviction")
  local ab5lv = ab5:GetLevel()
  local ab5range = ab5:GetCastRange() 
  local ab6 = hero:FindAbilityByName("brakesky")
  local ab6lv = ab5:GetLevel()
  local ab6range = ab6:GetLevelSpecialValueFor("rage",ab1lv - 1)
  local herolf = hero:GetHealthPercent()
  if ab3lv > 2 then 
     if mana > 250 or hero:HasTalent("shana_talent_1") then
	  if not hero:HasModifier("modifier_flamewing") then
     hero:CastAbilityNoTarget(ab3, id)
	 end
	else
	ab3:ToggleAbility()
	end
end
  if ab2:IsCooldownReady() and ab2lv>0 and mana > ab2:GetManaCost(-1) and dist < ab2range then 
     hero:CastAbilityOnTarget(unit, ab2, id) 
	 elseif ab5:IsCooldownReady() and ab5lv>3 and mana > ab5:GetManaCost(-1) and dist < ab5range  then 
	 hero:CastAbilityOnPosition(pTgt, ab5, id)
	 elseif ab6:IsCooldownReady() and ab6lv>0 and mana > ab6:GetManaCost(-1) and dist < ab6range  then 
	 hero:CastAbilityNoTarget(ab6, id)
  end
  if ab3:IsCooldownReady() and ab3lv>3 and mana > ab3:GetManaCost(-1) and dist < ab3range then 
      hero:CastAbilityOnPosition(pTgt, ab3, id)
	  end

end

function AIlelouch(hero,unit)
  local pOrg = hero:GetAbsOrigin()
  local pTgt = unit:GetAbsOrigin()
  local dist = (pTgt-pOrg):Length2D()
  local id = hero:GetPlayerID()
  local mana = hero:GetMana()
  local ab1 = hero:FindAbilityByName("killselfgeass")
  local ab1lv = ab1:GetLevel()
  local ab1range = ab1:GetCastRange() 
  local ab2 = hero:FindAbilityByName("emperor_commend")
  local ab2lv = ab2:GetLevel()
  local ab2range = ab2:GetCastRange() 
  local ab3 = hero:FindAbilityByName("geass")
  local ab3lv = ab3:GetLevel()
  local ab3range = ab3:GetCastRange() 
  local herolf = hero:GetHealthPercent()
  local funits = FindUnitsInRadius(hero:GetTeam(),hero:GetAbsOrigin(),nil, ab2range, DOTA_UNIT_TARGET_TEAM_FRIENDLY , DOTA_UNIT_TARGET_HERO, 0, 0, false)
  local bunits = FindUnitsInRadius(hero:GetTeam(),hero:GetAbsOrigin(),nil, ab3range, DOTA_UNIT_TARGET_TEAM_ENEMY , DOTA_UNIT_TARGET_BASIC, 0, 0, false)

  if ab1:IsCooldownReady() and ab1lv>0 and mana > ab1:GetManaCost(-1) and dist < ab1range then 
     hero:CastAbilityOnTarget(unit, ab1, id) 
  end
  for _,funit in pairs(funits) do
    if funit:GetHealthPercent() < 20 then
	 if ab2:IsCooldownReady() and ab2lv>0 and mana > ab2:GetManaCost(-1) then 
     hero:CastAbilityOnTarget(funit, ab2, id) 
   end
  end
 end
 for _,bunit in pairs(bunits) do
	 if ab3:IsCooldownReady() and ab3lv>0 and mana > ab3:GetManaCost(-1) then 
     hero:CastAbilityOnTarget(bunit, ab3, id) 
	 bunit:MoveToTargetToAttack(unit)
   end

 end
end

function AImadoka(hero,unit)
  local pOrg = hero:GetAbsOrigin()
  local pTgt = unit:GetAbsOrigin()
  local dist = (pTgt-pOrg):Length2D()
  local id = hero:GetPlayerID()
  local mana = hero:GetMana()
  local ab1 = hero:FindAbilityByName("madokaruler")
  local ab1lv = ab1:GetLevel()
  local ab1range = ab1:GetCastRange() 
  local ab2 = hero:FindAbilityByName("madokasave")
  local ab2lv = ab2:GetLevel()
  local ab2range = ab2:GetCastRange() 
  local herolf = hero:GetHealthPercent()
  local funits = FindUnitsInRadius(hero:GetTeam(),hero:GetAbsOrigin(),nil, ab2range, DOTA_UNIT_TARGET_TEAM_FRIENDLY , DOTA_UNIT_TARGET_HERO, 0, 0, false)
 
  if ab1:IsCooldownReady() and ab1lv>0 and mana > ab1:GetManaCost(-1) and dist < ab1range then 
     hero:CastAbilityOnPosition(pTgt, ab1, id) 
  end
  for _,funit in pairs(funits) do
    if funit:GetHealthPercent() < 20 then
	 if ab2:IsCooldownReady() and ab2lv>0 and mana > ab2:GetManaCost(-1) then 
     hero:CastAbilityOnTarget(funit, ab2, id) 
   end
  end
 end

end
function AIkanade(hero,unit)
  local pOrg = hero:GetAbsOrigin()
  local pTgt = unit:GetAbsOrigin()
  local dist = (pTgt-pOrg):Length2D()
  local id = hero:GetPlayerID()
  local mana = hero:GetMana()
  local ab2 = hero:FindAbilityByName("Dispersion")
  local ab2lv = ab2:GetLevel()
  local ab3 = hero:FindAbilityByName("dealy")
  local ab3lv = ab3:GetLevel()
  local ab3range = ab3:GetCastRange() 
  local herolf = hero:GetHealthPercent()
  if ab3:IsCooldownReady() and ab3lv>0 and mana > ab3:GetManaCost(-1) and dist < ab3range then 
     hero:CastAbilityOnTarget(unit, ab3, id) 
  end
  if ab2:IsCooldownReady() and ab2lv>0 and mana > ab2:GetManaCost(-1) and herolf < 40 then 
      hero:CastAbilityNoTarget(ab2, id)
	  end

end

function AImisaka(hero,unit)
  local pOrg = hero:GetAbsOrigin()
  local pTgt = unit:GetAbsOrigin()
  local dist = (pTgt-pOrg):Length2D()
  local id = hero:GetPlayerID()
  local mana = hero:GetMana()
  local ab1 = hero:FindAbilityByName("lightlance")
  local ab1lv = ab1:GetLevel()
  local ab2 = hero:FindAbilityByName("truethunder")
  local ab2lv = ab2:GetLevel()
  local ab2da = ab2:GetAbilityDamage() * 0.7
  local ab3 = hero:FindAbilityByName("railgun")
  local ab3lv = ab3:GetLevel()
  local ab3range = ab3:GetCastRange() 
  local herolf = hero:GetHealthPercent()
  if not hero:HasModifier("modifier_powershot_charge_datadriven") and not hero:HasModifier("modifier_powershot_charge_datadriven") then
  if ab1:IsCooldownReady() and ab1lv>0 and mana > ab1:GetManaCost(-1) then  
     hero:CastAbilityOnTarget(unit, ab1, id) 
	elseif ab3:IsCooldownReady() and ab3lv>0 and mana > ab3:GetManaCost(-1) and dist < ab3range then  
	hero:CastAbilityOnPosition(pTgt, ab3, id) 
	end
if ab2:IsCooldownReady() and ab2lv>0 and mana > ab2:GetManaCost(-1) and unit:GetHealth() < ab2da then 
     hero:CastAbilityNoTarget(ab2, id)
  end

end
  
end

function AIsaber(hero,unit)
  local pOrg = hero:GetAbsOrigin()
  local pTgt = unit:GetAbsOrigin()
  local dist = (pTgt-pOrg):Length2D()
  local id = hero:GetPlayerID()
  local mana = hero:GetMana()
  local ab1 = hero:FindAbilityByName("magic_out")
  local ab1lv = ab1:GetLevel()
  local ab2 = hero:FindAbilityByName("fengwang")
  local ab2lv = ab2:GetLevel()
  local herolf = hero:GetHealthPercent()
   if ab1lv > 0 and dist < 180 then 
     if mana > 250 then
     hero:CastAbilityNoTarget(ab1, id)
	else
	ab1:ToggleAbility()
	end
end

if ab2lv>0 then 
   if hero:GetAttackSpeed() > 0.8 then 
     hero:CastAbilityNoTarget(ab2, id)
	 else
	 ab2:ToggleAbility()
	 end
  end
end

function AIedward(hero,unit,gt)
  local pOrg = hero:GetAbsOrigin()
  local pTgt = unit:GetAbsOrigin()
  local dist = (pTgt-pOrg):Length2D()
  local id = hero:GetPlayerID()
  local mana = hero:GetMana()
  local ab1 = hero:FindAbilityByName("alchemist_str")
  local ab1lv = ab1:GetLevel()
  local ab2 = hero:FindAbilityByName("alchemist_int")
  local ab2lv = ab2:GetLevel()
  local ab3 = hero:FindAbilityByName("alchemist_agi")
  local ab3lv = ab3:GetLevel()
  local ab4 = hero:FindAbilityByName("alchemist")
  local ab4lv = ab4:GetLevel()
  local herolf = hero:GetHealthPercent()
  if hero.oldgt == nil then
     hero.oldgt = gt
  end
  local gting = gt - hero.oldgt
   if ab1lv > 0 then 
   if mana > 100 then
     if mana > 350 then
     hero:CastAbilityNoTarget(ab2, id)
	elseif herolf > 30 then
	hero:CastAbilityNoTarget(ab1, id)
	else
	hero:CastAbilityNoTarget(ab3, id)
	end
	else
	ab1:ToggleAbility()
	ab2:ToggleAbility()
	ab3:ToggleAbility()
  end
end
if gting > 4 then
if ab4:IsCooldownReady() and ab4lv>0 and mana > ab4:GetManaCost(-1) and dist < 600 then 
      hero:CastAbilityOnPosition(pTgt, ab4, id)
	  hero.oldgt = nil
	  end
   end
end

function AIkirito(hero,unit)
  local pOrg = hero:GetAbsOrigin()
  local pTgt = unit:GetAbsOrigin()
  local dist = (pTgt-pOrg):Length2D()
  local id = hero:GetPlayerID()
  local mana = hero:GetMana()
  local ab1 = hero:FindAbilityByName("vorpal_strike")
  local ab1lv = ab1:GetLevel()
  local ab1range = ab1:GetCastRange() 
  local ab2 = hero:FindAbilityByName("four_fangzhan")
  local ab2lv = ab2:GetLevel()
  local ab2range = ab2:GetCastRange() 
  local herolf = hero:GetHealthPercent()
if ab2:IsCooldownReady() and ab2lv>0 and mana > ab2:GetManaCost(-1) and dist < ab2range then 
   hero:CastAbilityOnTarget(unit, ab2, id) 
elseif ab1:IsCooldownReady() and ab1lv>0 and mana > ab1:GetManaCost(-1) and dist < ab1range then 
      hero:CastAbilityOnPosition(pTgt, ab1, id)
	  end
end

function AIaria(hero,unit)
  local pOrg = hero:GetAbsOrigin()
  local pTgt = unit:GetAbsOrigin()
  local dist = (pTgt-pOrg):Length2D()
  local id = hero:GetPlayerID()
  local mana = hero:GetMana()
  local ab1 = hero:FindAbilityByName("double_gunandknife")
  local ab1lv = ab1:GetLevel()
  local ab2 = hero:FindAbilityByName("daibu")
  local ab2lv = ab2:GetLevel()
  local ab2range = ab2:GetCastRange() 
  local ab3 = hero:FindAbilityByName("doubleknifestrike")
  local ab3lv = ab2:GetLevel()
  local herolf = hero:GetHealthPercent()
  if ab3:IsCooldownReady() and ab3lv > 0 then
     ab1:ToggleAbility()
  elseif dist > 180 and ab1lv>0 then
  hero:CastAbilityNoTarget(ab1, id)
  elseif dist < 180 then 
      ab1:ToggleAbility()
  end
  if ab2:IsCooldownReady() and ab2lv>0 and mana > ab2:GetManaCost(-1) and dist < ab2range then 
   hero:CastAbilityOnTarget(unit, ab2, id) 
	  end
end

---------------------------------------------------------------------------------------------------
-----------------------------------------------Main------------------------------------------------
---------------------------------------------------------------------------------------------------
function AIStart(hero)
	local gt = 0
	print("ai start")
	hero.ai_stg = AI_STG_PUSH
	hero.ai_state = AI_STATE_ATTACK
	hero.lastOrderTime = gt
	hero.lastOrder = AI_ORDER_MOVE_ATTACK
	hero.hpStreak={}
	hero.tc = 0
	hero.tc_equip = 0
	hero.noOrderTime = gt-1
	hero.tc_nextcost = AIGetTCCost(hero.item_tree[1])
	local nEnemy = 1 --仅小兵
	local nAlly = 1 --仅小兵
	local nEnemyHero = 1
	local nAllyHero = 1 --包括自己
	local nEnemyTower = 1
	local nAllyTower = 1
	local up = nil
	local enemies = {}
	local allies = {}
	local enemyheroes = {}
	local allyheroes = {}
	local enemytowers = {}
	local allytowers = {}
	local goodjudian = Entities:FindByName(nil,"judian1")
	local badjudian = Entities:FindByName(nil,"judian2")
	local good = Entities:FindByName(nil,"fountaingood")
    local bad  = Entities:FindByName(nil,"fountainbad")
	print("good",good:GetAbsOrigin())
	--print("fountain =",fountain)
	hero.olddist = 9999
	local pOrg = hero:GetAbsOrigin()
	if hero:GetLevel()==1 then --AI学技能
		AILearnAbility(hero,1)
	end
	if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
	   hero.judian = goodjudian:GetAbsOrigin()
	   hero.judianen = goodjudian
	   else
	   hero.judian = badjudian:GetAbsOrigin()
	   hero.judianen = badjudian
	   end

    local fountain = GetFountain(hero)
	local fOrg = hero.judian
	--print("fountain",fountain:GetUnitName())
      FindClearSpaceForUnit( hero, hero.judian, false )
	   Timers:CreateTimer(0.5,function()
       hero.homedist = (hero:GetAbsOrigin() - hero.judian):Length2D()
	   gt = gt + 0.3
       -- print("gt =",gt)
       -- print("hero =",hero:GetUnitName())
		if MTM_STOP_AI == nil then
		local units = FindUnitsInRadius(hero:GetTeam(),hero:GetAbsOrigin(),nil, 1600, DOTA_UNIT_TARGET_TEAM_ENEMY , DOTA_UNIT_TARGET_HERO, 0, 0, false)
        --print("ai unit")
		  -- DeepPrintTable(units)
		   
		   local herolf = hero:GetHealthPercent()
		    if herolf < 35 then
		  -- print("unit154")
			  if AIUseTPBackTown(hero) then
					isback = true
				end
			  --print("unit156")
  
		elseif hero.homedist >= 10000 then
           hero:MoveToPosition(hero.judian)
	   else  
	   --print("unit159")
	   --PrintTable(units)
		for _,unit in pairs(units) do
		--print("hero =",unit:GetUnitName())
				hero.dist = (unit:GetAbsOrigin()-hero:GetAbsOrigin()):Length2D()
                 if unit ~= nil then
                    if not unit:IsInvisible() and unit:IsAlive() then
					--print("dist", hero.dist)
					--print("olddist", hero.olddist + 1000)
					 if	hero.dist < hero.olddist + 1000  then
					--print("unit4")
					    hero.olddist = hero.dist
						 hero:MoveToTargetToAttack(unit)
						 local name = hero:GetUnitName()
						 if name=="npc_dota_hero_axe" then
                         AIkuroyuki(hero,unit)
						 end
						 if name=="npc_dota_hero_ember_spirit" then
                         AIshana(hero,unit)
						 end
						 if name=="npc_dota_hero_winter_wyvern" then
                         AIlelouch(hero,unit)
						 end
						 if name=="npc_dota_hero_clinkz" then
                         AImadoka(hero,unit)
						 end
                         if name=="npc_dota_hero_spectre" then
                         AIkanade(hero,unit)
						 end
						 if name=="npc_dota_hero_storm_spirit" then
                         AImisaka(hero,unit)
						 end
						 if name=="npc_dota_hero_juggernaut" then
                         AIsaber(hero,unit)
						 end
						
						 if name=="npc_dota_hero_earthshaker" then
                         AIedward(hero,unit,gt)
						 end
						 if name=="npc_dota_hero_magnataur" then
                         AIkirito(hero,unit)
						 end
						 if name=="npc_dota_hero_templar_assassin" then
                         AIaria(hero,unit)
						 end
						 --[[
						 if name=="npc_dota_hero_tusk" then
                         AIshinobu(hero,unit)
						 end
						 if name=="npc_dota_hero_zuus" then
                         AIkuroyuki(hero,unit)
						 end
						 ]]
						 else
					 --print("unit43")
						 hero:MoveToPosition(hero.judian)
						 if hero.judianen:GetTeamNumber() ~= hero:GetTeamNumber() then
						    hero:MoveToTargetToAttack(hero.judian)
						 end
					 end
					 else
					 --print("unit43")
						 hero:MoveToPosition(hero.judian)
						 if hero.judianen:GetTeamNumber() ~= hero:GetTeamNumber() then
						    hero:MoveToTargetToAttack(hero.judian)
						 end
				    end
					else
					 --print("unit43")
						 hero:MoveToPosition(hero.judian)
						 if hero.judianen:GetTeamNumber() ~= hero:GetTeamNumber() then
						    hero:MoveToTargetToAttack(hero.judian)
						 end
				    end
				end			
	end
end
    --print("unit443")
    
	       if hero:HasModifier("modifier_fountain_aura_buff") then --在泉水里，重新考虑线路
		   print("think judian")
	   FindClearSpaceForUnit( hero, hero.judian, false )
	   end
         -- print("gt",gt)

	       if gt> 80 and hero.level1 == nil then
				hero.level1 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,2)
			end
			if gt> 180 and hero.level2 == nil then
				hero.level2 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,3)
			end
			if gt> 240 and hero.level3 == nil then
				hero.level3 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,4)
			end
			if gt> 300 and hero.level4 == nil then
				hero.level4 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,5)
			end
			if gt> 420 and hero.level5 == nil then
				hero.level5 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,6)
			end
			if gt> 500 and hero.level6 == nil then
				hero.level6 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,7)
			end
			if gt> 550 and hero.level7 == nil then
				hero.level7 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,8)
			end
			if gt> 700 and hero.level8 == nil then
				hero.level8 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,9)
			end
			if gt> 800 and hero.level9 == nil then
				hero.level9 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,10)
			end
			if gt> 900 and hero.level10 == nil then
				hero.level10 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,11)
			end
			if gt> 1000 and hero.level11 == nil then
				hero.level11 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,12)
			end
			if gt> 1100 and hero.level12 == nil then
				hero.level12 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,13)
			end
			if gt> 1200 and hero.level13 == nil then
				hero.level13 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,14)
			end
			if gt> 1250 and hero.level14 == nil then
				hero.level14 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,15)
			end
			if gt> 1300 and hero.level15 == nil then
				hero.level15 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,16)
			end
			if gt> 1400 and hero.level16 == nil then
				hero.level16 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,17)
			end
			if gt> 1500 and hero.level17 == nil then
				hero.level17 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,18)
			end
			if gt> 1520 and hero.level18 == nil then
				hero.level18 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,19)
			end
			if gt> 1600 and hero.level19 == nil then
				hero.level19 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,20)
			end
			if gt> 1680 and hero.level20 == nil then
				hero.level20 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,21)
			end
			if gt> 1740 and hero.level21 == nil then
				hero.level21 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,22)
			end
			if gt> 1800 and hero.level22 == nil then
				hero.level22 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,23)
			end
			if gt> 1900 and hero.level23 == nil then
				hero.level23 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,24)
			end
			if gt> 2000 and hero.level24 == nil then
				hero.level24 = true
				hero:HeroLevelUp(false)
				AILearnAbility(hero,25)
			end


			if gt> 100 and hero.equip1 == nil then
				hero.equip1 = true
				hero:AddItemByName(hero.item_tree[1])
			end
			if gt> 400 and hero.equip2 == nil then
				hero.equip2 = true
				hero:AddItemByName(hero.item_tree[2])
			end
			if gt> 800 and hero.equip3 == nil then
				hero.equip3 = true
				hero:AddItemByName(hero.item_tree[3])
			end
			if gt> 960 and hero.equip4 == nil then
				hero.equip4 = true
				hero:AddItemByName(hero.item_tree[4])
			end
			if gt> 1200 and hero.equip5 == nil then
				hero.equip5 = true
				hero:AddItemByName(hero.item_tree[5])
			end
			if gt> 1500 and hero.equip6 == nil then
				hero.equip6 = true
				hero:AddItemByName(hero.item_tree[6])
			end  
      return 0.5
	end)

	--[[
	local tbl = hero.hpStreak
	for i = 1,3 do
		tbl[i]=100
	end
	
	local location=Vector(math.random(youxia_zuobiao.x-zuoshang_zuobiao.x)+zuoshang_zuobiao.x,math.random(youxia_zuobiao.y-zuoshang_zuobiao.y)+zuoshang_zuobiao.y,youxia_zuobiao.z)
	hero:MoveToPosition(location)
	Timers:CreateTimer(function()
		if GameRules:State_Get()>=DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			if hero:IsAlive() then
				local casting = hero:GetCurrentActiveAbility()
				if casting==nil and GameTime()>hero.noOrderTime then
					if hero.ai_stg==AI_STG_PUSH then
						AIPush(hero)
					elseif hero.ai_stg==AI_STG_GANK then
						AIGank(hero)
					elseif hero.ai_stg==AI_STG_LINE_GANK then
						AILineGank(hero)
					elseif hero.ai_stg==AI_STG_JUNGLE then
					elseif hero.ai_stg==AI_STG_FOLLOW then
						AIFollow(hero)
					end
				end
			end
			if hero:GetGold()>hero.tc_nextcost then
				AITCUp(hero)
			end
		end
		return AI_THINK_INTERVAL
	end)
	]]
end

---------------------------------------------------------------------------------------------------
-----------------------------------------------Push------------------------------------------------
---------------------------------------------------------------------------------------------------
function AIPush(hero)
	local gt = GameTime()
	local life = hero:GetHealth()
	local lifeper = hero:GetHealthPercent()
	local mayDamage = hero:GetBaseDamageMin()*2
	local pOrg = hero:GetAbsOrigin()
	local nEnemy = 1 --仅小兵
	local nAlly = 1 --仅小兵
	local nEnemyHero = 1
	local nAllyHero = 1 --包括自己
	local nEnemyTower = 1
	local nAllyTower = 1
	local dist = 0
	local method = 0
	local enemies = {}
	local allies = {}
	local enemyheroes = {}
	local allyheroes = {}
	local enemytowers = {}
	local allytowers = {}
	local chase = false
	local value = 0
	local cTemp = 0
	local isback = false
	hero.hpStreak[3]=hero.hpStreak[2]
	hero.hpStreak[2]=hero.hpStreak[1]
	hero.hpStreak[1]=lifeper
	--------------收集数据---------------
	local units = FindUnitsInRadius(hero:GetTeam(),pOrg,nil,1200,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
    if #units > 0 then
		for _,unit in pairs(units) do
			if IsValidUnit(unit) and unit:IsAlive() then
				dist = (unit:GetAbsOrigin()-pOrg):Length2D()
				if unit:GetTeamNumber()~=hero:GetTeamNumber() then
					if unit:IsBuilding() then
						if IsBuildingTower(unit) and dist<900 then
							enemytowers[nEnemyTower]=unit
							nEnemyTower=nEnemyTower+1
						end
					elseif unit:IsRealHero() and not unit:IsInvisible() then
						enemyheroes[nEnemyHero]=unit
						nEnemyHero=nEnemyHero+1
						if unit:GetHealthPercent()<35 or unit:GetHealth()<mayDamage then
							chase = true
						end
					elseif unit:GetTeamNumber()==DOTA_TEAM_NEUTRALS then --野怪
						if dist<1000 then
							enemies[nEnemy]=unit
							nEnemy=nEnemy+1
						end
					end
				else
					if unit:IsBuilding() then
						if IsBuildingTower(unit) and dist<900 then
							allytowers[nAllyTower]=unit
							nAllyTower=nAllyTower+1
						end
					elseif unit:IsRealHero() then --友方英雄
							allyheroes[nAllyHero]=unit
							nAllyHero=nAllyHero+1
					else --前方或500范围内的友方小兵
						if dist<350 then
							allies[nAlly]=unit
							nAlly=nAlly+1
						elseif dist<1200 and IsFrontAlly(hero,unit) then
							allies[nAlly]=unit
							nAlly=nAlly+1
						end
					end
				end
			end
		end
	end
	--------------行动判断---------------
	local cEnemy = #enemies+#enemyheroes+#enemytowers
	local cAlly = #allies+#allyheroes+#allytowers
	if hero:HasModifier("modifier_fountain_aura_buff") and lifeper<95 then
		method = 2
	elseif (GetEnemyFountain(hero):GetAbsOrigin() - pOrg):Length2D() <1000 then
		method = 1
	elseif lifeper<35 then
		if AIHasStrongerHeroForce(allyheroes,enemyheroes) then
			if AICanDuel(hero,gt,enemyheroes,enemytowers) then
				method = 3
			else
				method = 1
			end
		else
			if #enemyheroes==0 and #enemytowers==0 then
				if AIUseTPBackTown(hero) then
					isback = true
				else
					method = 1
				end
			else
				method = 1
			end
		end
	else
		if hero.hpStreak[3]-hero.hpStreak[1]>8 then
			method = 1
		else
			if #enemytowers>0 then
				--周围有敌方的塔--------------------------------------------------------------------
				if #enemyheroes==0 then
					cTemp = CountAlliesNearPoint(enemytowers[1]:GetAbsOrigin(),enemytowers[1]:GetAttackRange(),hero,false,false)
					if AIAttackedByTowerRetreat(hero,enemytowers[1]) then
						method = 1
					elseif cTemp>1 or (lifeper>50 and enemytowers[1]:GetHealthPercent()<10) then
						method = 5
					else
						method = 1
					end
				else
					if chase then
						if AIHasStrongerHeroForce(allyheroes,enemyheroes) then
							value = lifeper
							cTemp = CountAlliesNearPoint(enemytowers[1]:GetAbsOrigin(),enemytowers[1]:GetAttackRange(),hero,false,false)
							value=value+cTemp*15
							if lifeper>45 and value>100 then
								method = 3
							elseif lifeper>40 and life>CalMayDamage(enemytowers[1],hero)*12 and #enemyheroes<2 then
								method = 3
							elseif lifeper>40 and lifeper+cTemp*20>100 then
								method = 5
							else
								method = 1
							end
						else
							method = 1
						end
					else
						if AIHasStrongerHeroForce(allyheroes,enemyheroes) then
							cTemp = CountAlliesNearPoint(enemytowers[1]:GetAbsOrigin(),enemytowers[1]:GetAttackRange(),hero,false,false)
							if lifeper>50 and lifeper*100+cTemp*20>100 then
								method = 5
							elseif lifeper>50 then
								method = 0
							else
								method = 1
							end
						else
							method = 1
						end
					end
				end
			elseif #enemyheroes>0 then
				--周围没有敌方的塔，但有敌方英雄----------------------------------------------------
				if AIHasStrongerHeroForce(allyheroes,enemyheroes) then
					if chase then
						if lifeper>40 then
							method = 3
						elseif #allies>1 or #enemies==0 then
							method = 4
						elseif #allyheroes==1 and #enemies>2 then
							method = 1
						else
							method = 0
						end
					else
						--友方英雄实力更强
						if (#allies>1 or #enemies==0) and gt>600 then
							method = 4
						elseif #allies>1 or #enemies==0 then
							method = 0
						elseif #allyheroes==1 and #enemies>2 then
							method = 1
						else
							method = 0
						end
					end
				else
					--敌方英雄实力更强
					if #allyheroes>1 and lifeper>75 then --周围有队友，自己生命值较高，可以选择不跑
						if #allies>2 and #enemies<2 and gt>600 then
							method = 4
						elseif #allies>1 or #enemies==0 then
							method = 0
						else
							method = 1
						end
					else --周围没有队友，或者自己生命值低，撤退
						method = 1
					end
				end
			else
				--周围没有敌方的塔和敌方英雄--------------------------------------------------------
				if #enemies>0 then
					method = 0

			    end
			end
		end
	end
	print("method = ",method)
	--------------行动指令---------------
	if (method==0 or method==1) and hero.tc>hero.tc_equip+1 then --回城换装备
		if AIUseTPBackTown(hero) then
			isback = true
		end
	end
	print("isback = ",isback)
	if isback==false then
		if method==0 then
		print("AIOrderAttackMove")
			--攻击移动，补刀打钱，攻击射程范围内的英雄，优先攻击小兵
			AIOrderAttackMove(hero,gt,allies,enemies,enemyheroes,allyheroes)
		elseif method==1 then
			--后退
			AIOrderRetreat(hero,gt,enemyheroes,allyheroes)
		elseif method==2 then
			--泉水里回复
			AIOrderHoldInFountain(hero)
		elseif method==3 then
			--追击敌方的一个残血英雄
			AIOrderChaseHero(hero,gt,enemyheroes,allyheroes,enemies,allies)
		elseif method==4 then
			--优先攻击英雄
			AIOrderAttackHero(hero,gt,enemies,enemyheroes,allyheroes,enemies,allies)
		elseif method==5 then
			--拆塔
			AIOrderAttackTower(hero,gt,enemies,enemytowers,allies,allyheroes,enemyheroes)
		end
	end
	--------------结束---------------
	units = nil
	enemies = nil
    allies = nil
    enemyheroes = nil
    allyheroes = nil
    enemytowers = nil
    allytowers = nil
end

function AIOrderAttackMove_Attack(hero,gt,up,allyheroes,enemyheroes,allies,enemies)
	if hero.ai_state~=AI_STATE_ATTACK or hero.lastOrder~=AI_ORDER_ATTACK or gt-hero.lastOrderTime>0.7 or hero.lastTarget~=up then
		hero.lastOrderTime = gt
		hero.lastOrder = AI_ORDER_ATTACK
		hero.ai_state = AI_STATE_ATTACK
		hero.lastTarget = up
		print(up:GetUnitName())
		print("AIOrderAttackMove_Attack")
		if up:IsHero() then
			--对英雄优先使用消耗技能
			print("AIOrderAttackMove_Attackhero")
			if not hero.skill_damage(hero,up,allyheroes,enemyheroes,allies,enemies,false) then
				if not hero:IsDisarmed() then
					hero:MoveToTargetToAttack(up)
				else
					AIOrderAttackMove_Move(hero,gt,up)
				end
			end
		else
			--对小兵，前期补刀，后期清兵技能
			if gt<600 then
				--if not hero:IsDisarmed() then
				print("AIOrderAttackMove_Attackguai")
					hero:MoveToTargetToAttack(up)
				--else
				--	AIOrderAttackMove_Move(hero,gt,up)
				--end
			else
				if not hero.skill_push(hero,up,allyheroes,enemyheroes) then
					if not hero.skill_summon(hero,up,allyheroes,enemyheroes) then
						--if not hero:IsDisarmed() then
							hero:MoveToTargetToAttack(up)
						--else
						--	AIOrderAttackMove_Move(hero,gt,up)
						--end
					end
				end
			end
		end
	end
end
function AIOrderAttackMove_UseSpell(hero,gt,up,allyheroes,enemyheroes,allies,enemies)
	--对攻击射程外，但在施法距离内的敌人使用技能消耗 返回是否使用了技能
	if hero.ai_state~=AI_STATE_ATTACK or hero.lastOrder~=AI_ORDER_ATTACK or gt-hero.lastOrderTime>0.7 or hero.lastTarget~=up then
		hero.lastOrderTime = gt
		hero.lastOrder = AI_ORDER_ATTACK
		hero.ai_state = AI_STATE_ATTACK
		hero.lastTarget = up
		return hero.skill_damage(hero,up,allyheroes,enemyheroes,allies,enemies,false)
	end
	return false
end
function AIOrderAttackMove_Move(hero,gt,targetwho)
	--if hero:GetPlayerID()==5 then
		--print("move somewhere")
	--end
	local pOrg = hero:GetAbsOrigin() 
	local range = math.min(600,hero:GetAttackRange()+200)
	local v1 = nil
	--[[
	if hero:GetTeamNumber()==DOTA_TEAM_GOODGUYS then
		if pOrg.x+pOrg.y>0 then
			v1 = (GetEnemyFountain(hero):GetAbsOrigin()-targetwho:GetAbsOrigin()):Normalized()
		else
			v1 = (targetwho:GetAbsOrigin()-GetFountain(hero):GetAbsOrigin()):Normalized()
		end
	else
		if pOrg.x+pOrg.y>0 then
			v1 = (targetwho:GetAbsOrigin()-GetFountain(hero):GetAbsOrigin()):Normalized()
		else
			v1 = (GetEnemyFountain(hero):GetAbsOrigin()-targetwho:GetAbsOrigin()):Normalized()
		end
	end
	v1 = RotatePosition(Vector(0,0,0), QAngle(0,RandomFloat(-60,60),0),v1)
	]]
	local pTgt = targetwho:GetAbsOrigin() --v1*RandomFloat(range*0.6,range)
	--if hero.ai_state~=AI_STATE_ATTACK or hero.lastOrder~=AI_ORDER_MOVE or gt-hero.lastOrderTime>0.7 then
		hero.lastOrderTime = gt
		hero.lastOrder = AI_ORDER_MOVE
		hero.ai_state = AI_STATE_ATTACK
		hero:MoveToPosition(pTgt)
	--end
end

function AIOrderAttackMove(hero,gt,allies,enemies,enemyheroes,allyheroes)
	--local tbl = hero.waypoints
	--local pTgt = tbl[hero.headWayPoint]
	local pOrg = hero:GetAbsOrigin()
	local range = math.max(225,hero:GetAttackRange())
	local lf = 0
	local min = 99999
	local up = nil
	local goodjudian = Entities:FindByName(nil,"judian1")
	local badjudian = Entities:FindByName(nil,"judian2")
	print("AIOrderAttackMove")

	if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
	   hero.tporg = goodjudian:GetAbsOrigin()
	   else
	   hero.tporg = badjudian:GetAbsOrigin()
	   end
    print("#enemies =",#enemies)
	if #enemies>0 then
		for k,enemy in pairs(enemies) do
			if enemy then
				lf = enemy:GetHealth()
				if lf<min then
					min = lf
					up = enemy
				end
			end
		end
	end
	print("min =",min)
	print("up =",up:GetUnitName())
	
	if up then
		if gt<600 then
			local mayDamage = GetMayDamage(hero,up)
			local upLife =up:GetHealth() 
			--if upLife<mayDamage*1.5 or (#allies-#enemies>2 and upLife<mayDamage*2) then
				--补刀
				
			--else
				if #enemyheroes>0 then
					if (enemyheroes[1]:GetAbsOrigin()-pOrg):Length2D()<range and (hero:GetHealthPercent()>70 or (enemies[1]:GetAbsOrigin()-pOrg):Length2D()>350) and enemyheroes[1]:IsAlive() then
						--攻击射程内的英雄
						AIOrderAttackMove_Attack(hero,gt,enemyheroes[1],allyheroes,enemyheroes,allies,enemies)
					elseif not AIOrderAttackMove_UseSpell(hero,gt,enemyheroes[1],allyheroes,enemyheroes,allies,enemies) then --如果无法使用消耗技能
						--随机移动
						--if up:GetHealth()<mayDamage*2 then
							AIOrderAttackMove_Move(hero,gt,up)
						--else
						--	AIOrderAttackMove_Move(hero,gt,enemies[1])
						--end
					end
				else
					--随机移动
					--if up:GetHealth()<mayDamage*2 then
				print("aifarm")
				AIFarm(hero,up,upLife,mayDamage,gt,allyheroes,enemyheroes,allies,enemies)
					--else
					--	AIOrderAttackMove_Move(hero,gt,enemies[1])
					--end
				end
			--end
		else
		print("ainofarm")
			if #enemyheroes>0 then
				if (enemyheroes[1]:GetAbsOrigin()-pOrg):Length2D()<range and (hero:GetHealthPercent()>70 or (enemies[1]:GetAbsOrigin()-pOrg):Length2D()>350) and enemyheroes[1]:IsAlive() then
					--攻击射程内的英雄
					print("attack hero")
					AIOrderAttackMove_Attack(hero,gt,enemyheroes[1],allyheroes,enemyheroes,allies,enemies)
				elseif not AIOrderAttackMove_UseSpell(hero,gt,enemyheroes[1],allyheroes,enemyheroes,allies,enemies) then --如果无法使用消耗技能
					--攻击小兵
					print("attack enemy")
					AIOrderAttackMove_Attack(hero,gt,up,allyheroes,enemyheroes,allies,enemies)
				end
			else
				--攻击小兵
				AIOrderAttackMove_Attack(hero,gt,up,allyheroes,enemyheroes,allies,enemies)
			end
		end
	else
		--攻击移动
		--if hero:GetPlayerID()==5 then
			--print("attack - move")
		--end
		--[[
		if hero.ai_state~=AI_STATE_ATTACK or hero.lastOrder~=AI_ORDER_MOVE_ATTACK or gt-hero.lastOrderTime>0.7 then
			hero.lastOrderTime = gt
			hero.lastOrder = AI_ORDER_MOVE_ATTACK
			hero.ai_state = AI_STATE_ATTACK
			if (pTgt-pOrg):Length2D()<300 then
				if tbl[hero.headWayPoint+1] then
					hero.headWayPoint=hero.headWayPoint+1
					pTgt = tbl[hero.headWayPoint]
				end
			end
			]]
			hero:MoveToPositionAggressive(pOrg+RandomVector(200))
			if hero:HasModifier("modifier_fountain_aura_buff") then --在泉水里，重新考虑线路
				--AIDecideWay(hero)
				if hero.tc>hero.tc_equip then
					AIGetItem(hero)
				end
				AISetItemCharges(hero)
				AIUseTPPosition(hero,hero.tporg)
			end
		end
	--end
end

function AIOrderRetreat(hero,gt,enemyheroes,allyheroes)
	--local tbl = hero.waypoints
	local pOrg = hero:GetAbsOrigin()
	local pTgt = GetFountain(hero):GetAbsOrigin()
	print("AIOrderRetreat")
	--[[
	if hero.ai_state~=AI_STATE_RETREAT or hero.lastOrder~=AI_ORDER_MOVE or gt-hero.lastOrderTime>0.7 then
		hero.lastOrderTime = gt
		hero.lastOrder = AI_ORDER_MOVE
		hero.ai_state = AI_STATE_RETREAT
		if (pTgt-pOrg):Length2D()<300 then
			if tbl[hero.headWayPoint-2] then
				hero.headWayPoint=hero.headWayPoint-1
				pTgt = tbl[hero.headWayPoint-1]
			end
		else
			local angle = GetVectorsCos(pTgt-pOrg,GetFountain(hero):GetAbsOrigin()-pOrg)
			if angle<0 then
				if tbl[hero.headWayPoint-2] then
					hero.headWayPoint=hero.headWayPoint-1
					pTgt = tbl[hero.headWayPoint-1]
				end
			end
		end
		]]
		if enemyheroes[1] and enemyheroes[1]:IsAlive() then
			local v1 = pTgt-pOrg
			local v2 = enemyheroes[1]:GetAbsOrigin()-pOrg
			local cos = v1:Dot(v2)/(v1:Length()*v2:Length())
			--if cos>0.5 then
				local v3=RotatePosition(Vector(0,0,0), QAngle(0,90,0), v2)
				--[[cos = v1:Dot(v3)/(v1:Length()*v3:Length())
				if cos>0 then
					v2=v3
				else
					v2=RotatePosition(Vector(0,0,0), QAngle(0,-90,0), v2)
				end]]
				v2=v2:Normalized()
				pTgt = pOrg+v2*600
			--end
			if not hero.skill_charge(hero,enemyheroes[1],enemyheroes,allyheroes) then 
				if not hero.skill_control(hero,enemyheroes[1],enemyheroes,allyheroes) then 
					hero:MoveToPosition(pTgt+RandomVector(100))
				end
			end
		else
			hero:MoveToPosition(pTgt+RandomVector(200))
		end
	--end
end

function AIOrderHoldInFountain(hero)
	local fountain = GetFountain(hero)
	local pTgt = fountain:GetAbsOrigin()
	local pOrg = hero:GetAbsOrigin()
	local location=Vector(math.random(youxia_zuobiao.x-zuoshang_zuobiao.x)+zuoshang_zuobiao.x,math.random(youxia_zuobiao.y-zuoshang_zuobiao.y)+zuoshang_zuobiao.y,youxia_zuobiao.z)
	hero:MoveToPosition(location)
	hero.headWayPoint = 1
	if hero.tc>hero.tc_equip then
		AIGetItem(hero)
	end
	AISetItemCharges(hero)
end

function AIOrderAttackHero(hero,gt,enemies,enemyheroes,allyheroes,enemies,allies)
	--local tbl = hero.waypoints
	--local pTgt = tbl[hero.headWayPoint]
	local pOrg = hero:GetAbsOrigin()
	local range = hero:GetAttackRange()+300
	local lf = 0
	local min = 99999
	local up = nil
	local onlyAttackCreatures = false
	if #enemyheroes>0 then
		for k,enemy in pairs(enemyheroes) do
			if enemy and enemy:IsAlive() then
				lf = enemy:GetHealth()
				if lf<min then
					min = lf
					up = enemy
				end
			end
		end
	end
	if up then
		--射程不足，优先使用技能? if not then attack
		if hero:IsSilenced() then --被沉默只能攻击
    		if (up:GetAbsOrigin()-pOrg):Length2D()<range then
				AIOrderAttackHero_Attack(hero,gt,up)
			else
				if enemyheroes[1] and enemyheroes[1]~=up and enemyheroes[1]:IsAlive() then
					AIOrderAttackHero_Attack(hero,gt,enemyheroes[1])
				else
					onlyAttackCreatures = true
				end
			end
    	elseif not hero.skill_control(hero,up,allyheroes,enemyheroes) then
			if not hero.skill_damage(hero,up,allyheroes,enemyheroes,allies,enemies,true) then
				if not hero.skill_avatar(hero,up,allyheroes,enemyheroes) then
					if not hero.skill_summon(hero,up,allyheroes,enemyheroes) then
						if not hero.skill_weaken(hero,up,allyheroes,enemyheroes) then
							if not hero.skill_support(hero,up,allyheroes,enemyheroes) then
								if (up:GetAbsOrigin()-pOrg):Length2D()<range then
									AIOrderAttackHero_Attack(hero,gt,up)
								else
									if enemyheroes[1] and enemyheroes[1]~=up and enemyheroes[1]:IsAlive() then
										AIOrderAttackHero_Attack(hero,gt,enemyheroes[1])
									else
										onlyAttackCreatures = true
									end
								end
							end
						end
					end
				end
			end
		end  
	else
		onlyAttackCreatures = true
	end
	up = nil
	if onlyAttackCreatures then
		if #enemies>0 then
			for k,enemy in pairs(enemies) do
				if enemy then
					lf = enemy:GetHealth()
					if lf<min then
						min = lf
						up = enemy
					end
				end
			end
		end
		if up then
			if gt<900 then
				local mayDamage = GetMayDamage(hero,up)
				local upLife =up:GetHealth() 
				if upLife<mayDamage*1.5 or (#allies-#enemies>2 and upLife<mayDamage*2) then
					--补刀
					AIFarm(hero,up,upLife,mayDamage,gt,allyheroes,enemyheroes,allies,enemies)
				else
					--随机移动
					AIOrderAttackMove_Move(hero,gt,enemies[1])
				end
			else
				--攻击小兵
				AIOrderAttackMove_Attack(hero,gt,up,allyheroes,enemyheroes,allies,enemies)
			end
		else
			AIOrderAttackMove_Move(hero,gt,hero)
		end
	end
end
function AIOrderAttackHero_Attack(hero,gt,up)
	--if hero:GetPlayerID()==5 then
		--print("attack")
	--end
	if hero.ai_state~=AI_STATE_ATTACK or hero.lastOrder~=AI_ORDER_ATTACK or gt-hero.lastOrderTime>0.7 or hero.lastTarget~=up then
		hero.lastOrderTime = gt
		hero.lastOrder = AI_ORDER_ATTACK
		hero.ai_state = AI_STATE_ATTACK
		hero.lastTarget = up
		if not hero:IsDisarmed() then
			hero:MoveToTargetToAttack(up)
		else
			AIOrderAttackMove_Move(hero,gt,up)
		end
		--仅普通攻击，技能在另一函数
	end
end

function AIOrderAttackTower(hero,gt,enemies,enemytowers,allies,allyheroes,enemyheroes)
	--local tbl = hero.waypoints
	--local pTgt = tbl[hero.headWayPoint]
	local pOrg = hero:GetAbsOrigin()
	local range = hero:GetAttackRange()+300
	local lf = 0
	local min = 99999
	local up = nil
	local onlyAttackCreatures = false
	local c = 0
	if #enemytowers>0 then
		for k,enemy in pairs(enemytowers) do
			if enemy then
				lf = enemy:GetHealth()
				if lf<min then
					min = lf
					up = enemy
				end
			end
		end
	end
	if up then
		c=CountAlliesNearPoint(up:GetAbsOrigin(),900,hero,false,false)
		if c>1 and #enemies<2 then
			--攻击塔
			AIOrderAttackTower_Attack(hero,gt,up)
		else
			onlyAttackCreatures=true
		end
	else
		onlyAttackCreatures=true
	end
	up = nil
	if onlyAttackCreatures then
		if #enemies>0 then
			for k,enemy in pairs(enemies) do
				if enemy then
					lf = enemy:GetHealth()
					if lf<min and AIOrderAttackTower_IsNearerThanTower(enemy,enemytowers,pOrg) then
						min = lf
						up = enemy
					end
				end
			end
		end
		if up then
			--攻击小兵
			AIOrderAttackMove_Attack(hero,gt,up,allyheroes,enemyheroes,allies,enemies)
		else
			AIOrderRetreat(hero,gt,enemyheroes,allyheroes)
		end
	end
end
function AIOrderAttackTower_Attack(hero,gt,up)
	--if hero:GetPlayerID()==5 then
		--print("attack")
	--end
	if hero.ai_state~=AI_STATE_ATTACK or hero.lastOrder~=AI_ORDER_ATTACK or gt-hero.lastOrderTime>0.7 or hero.lastTarget~=up then
		hero.lastOrderTime = gt
		hero.lastOrder = AI_ORDER_ATTACK
		hero.ai_state = AI_STATE_ATTACK
		hero.lastTarget = up
		if not hero:IsDisarmed() then
			hero:MoveToTargetToAttack(up)
		else
			AIOrderAttackMove_Move(hero,gt,up)
		end
		--仅普通攻击，技能在另一函数
	end
end
function AIOrderAttackTower_IsNearerThanTower(enemy,enemytowers,pOrg)
	if enemytowers[1] then
		local d1 = (enemy:GetAbsOrigin()-pOrg):Length2D()
		local d2 = (enemytowers[1]:GetAbsOrigin()-pOrg):Length2D()
		if d1<d2 then
			return true
		else
			return false
		end
	else
		return true
	end
end



function AIOrderChaseHero(hero,gt,enemyheroes,allyheroes,enemies,allies)
	--local tbl = hero.waypoints
	--local pTgt = tbl[hero.headWayPoint]
	local pOrg = hero:GetAbsOrigin()
	local range = hero:GetAttackRange()+300
	local lf = 0
	local min = 99999
	local up = nil
	if #enemyheroes>0 then
		for k,enemy in pairs(enemyheroes) do
			if enemy then
				lf = enemy:GetHealth()
				if lf<min then
					min = lf
					up = enemy
				end
			end
		end
	end
	if up then
		--使用突进技能
		if not hero.skill_charge(hero,up,allyheroes,enemyheroes) then
			if not hero.skill_control(hero,up,allyheroes,enemyheroes) then
				if not hero.skill_damage(hero,up,allyheroes,enemyheroes,allies,enemies,true) then --增加一个不计消耗的参数
					if not hero.skill_summon(hero,up,allyheroes,enemyheroes) then
						if not hero.skill_weaken(hero,up,allyheroes,enemyheroes) then
							AIOrderAttackHero_Attack(hero,gt,up)
						end
					end
				end
			end
		end
	end
end

function AIOrderHeal(target,bigheal)
	for i=0,9 do
		local player = PlayerResource:GetPlayer(i)
		if player then
			local h = player:GetAssignedHero()
			if h and PlayerResource:GetTeam(i)==target:GetTeamNumber() and IsAI(i) then --包括自己治疗
				if h:IsAlive() then
					--print(h:GetUnitName())
					if h.skill_heal(h,target,bigheal) then
						h.noOrderTime=GameTime()+0.5
						--print(h.noOrderTime)
					end
				end
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-----------------------------------------------Gank------------------------------------------------
---------------------------------------------------------------------------------------------------
function AIGank(hero)
	local target = hero.ai_gankTarget
	local start_position = hero.ai_gankOrg
	local gt = GameTime()
	local life = hero:GetHealth()
	local lifeper = hero:GetHealthPercent()
	local mayDamage = hero:GetBaseDamageMin()*2
	local pOrg = hero:GetAbsOrigin()
	local nEnemy = 1 --仅小兵
	local nAlly = 1 --仅小兵
	local nEnemyHero = 1
	local nAllyHero = 1 --包括自己
	local nEnemyTower = 1
	local nAllyTower = 1
	local cNearEnemy = 0
	local dist = 0
	local enemies = {}
	local allies = {}
	local enemyheroes = {}
	local allyheroes = {}
	local enemytowers = {}
	local allytowers = {}
	local giveup = false
	local method = -1
	--------------收集数据---------------
	local units = FindUnitsInRadius(hero:GetTeam(),pOrg,nil,1300,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
    if #units > 0 then
		for _,unit in pairs(units) do
			if IsValidUnit(unit) and unit:IsAlive() then
				dist = (unit:GetAbsOrigin()-pOrg):Length2D()
				if unit:GetTeamNumber()~=hero:GetTeamNumber() then
					if unit:IsBuilding() then
						if IsBuildingTower(unit) and dist<900 then
							enemytowers[nEnemyTower]=unit
							nEnemyTower=nEnemyTower+1
						end
					elseif unit:IsRealHero() and not unit:IsInvisible() then
						enemyheroes[nEnemyHero]=unit
						nEnemyHero=nEnemyHero+1
					elseif unit:GetTeamNumber()~=DOTA_TEAM_NEUTRALS then --敌方小兵 900范围
						if dist<1000 then
							enemies[nEnemy]=unit
							nEnemy=nEnemy+1
						end
						if target and (target:GetAbsOrigin()-unit:GetAbsOrigin()):Length2D()<400 then
							cNearEnemy = cNearEnemy + 1
						end
					end
				else
					if unit:IsBuilding() then
						if IsBuildingTower(unit) and dist<900 then
							allytowers[nAllyTower]=unit
							nAllyTower=nAllyTower+1
						end
					elseif unit:IsRealHero() then --友方英雄
							allyheroes[nAllyHero]=unit
							nAllyHero=nAllyHero+1
					else --前方或500范围内的友方小兵
						if dist<350 then
							allies[nAlly]=unit
							nAlly=nAlly+1
						elseif dist<1200 and IsFrontAlly(hero,unit) then
							allies[nAlly]=unit
							nAlly=nAlly+1
						end
					end
				end
			end
		end
	end
	local cEnemy = #enemies+#enemyheroes+#enemytowers
	local cAlly = #allies+#allyheroes+#allytowers
	--------------命令---------------
	if target==nil or not target:IsAlive() then
		giveup = true
	--目标跑得太远
	elseif start_position==nil or ((start_position-GetFountain(target):GetAbsOrigin()):Length2D() - (target:GetAbsOrigin()-GetFountain(target):GetAbsOrigin()):Length2D())>2000 or IsNearFountain(target,3000) then
		giveup = true
	elseif (target:GetAbsOrigin()-pOrg):Length2D()>2000 then
		--距离超过2000，聚集过去
		if lifeper<40 then
			if #enemyheroes>0 and AIHasStrongerHeroForce(allyheroes,enemyheroes) then
				if AICanDuel(hero,gt,enemyheroes,enemytowers) then
					method = 4
				else
					giveup = true
				end
			else
				giveup = true
			end
		else
			method = 1
		end
	else
		--距离不到2000
		if lifeper<40 then --生命值过低
			if #enemyheroes>0 and AIHasStrongerHeroForce(allyheroes,enemyheroes) then
				if AICanDuel(hero,gt,enemyheroes,enemytowers) then
					method = 4
				else
					giveup = true
				end
			else
				giveup = true
			end
		
		else
			if #enemyheroes==0 then --周围没敌人
				if #allyheroes<hero.ai_gankCount then --人没到齐，等待，最多3秒
					if hero.ai_gankWait>0 then
						hero.ai_gankWait = hero.ai_gankWait-AI_THINK_INTERVAL
						method = 3
					else
						--动手
						method = 2
					end
				else
					method = 2
				end
			else --周围有敌方英雄
				if (pOrg-target:GetAbsOrigin()):Length2D()>1500 then
					--还没接近目标，就遇到敌人，直接开打
					if AIHasStrongerHeroForce(allyheroes,enemyheroes) and #enemytowers==0 then
						method = 4
					else
						giveup = true
					end
				else
					if #enemytowers==0 and (hero:GetHealth()>800 or hero:GetHealthPercent()>75) then
						method = 2
					else
						giveup = true
					end
				end
			end
		end
	end
	if giveup then
		method = 0
	end
	if method==0 then
		hero.ai_stg=AI_STG_PUSH
	elseif method==1 then
		hero:MoveToNPC(target)
	elseif method==2 then --攻击gank目标或附近英雄
		if (target:GetAbsOrigin()-pOrg):Length2D()>400 and cNearEnemy<3 and #enemyheroes<3 then
			hero:MoveToNPC(target)
		else
			--攻击英雄
			AIOrderChaseHero(hero,gt,enemyheroes,allyheroes,enemies,allies)
		end
	elseif method==3 then --等待
		hero:MoveToPositionAggressive(hero:GetAbsOrigin())
	elseif method==4 then --攻击附近的英雄
		AIOrderChaseHero(hero,gt,enemyheroes,allyheroes,enemies,allies)
	end
	--------------结束---------------
	units = nil
	enemies = nil
    allies = nil
    enemyheroes = nil
    allyheroes = nil
    enemytowers = nil
    allytowers = nil
end


---------------------------------------------------------------------------------------------------
---------------------------------------------LineGank----------------------------------------------
---------------------------------------------------------------------------------------------------
function AILineGank(hero)
	local target = hero.ai_gankTarget
	local start_position = hero.ai_gankOrg
	local gt = GameTime()
	local life = hero:GetHealth()
	local lifeper = hero:GetHealthPercent()
	local mayDamage = hero:GetBaseDamageMin()*2
	local pOrg = hero:GetAbsOrigin()
	local nEnemy = 1 --仅小兵
	local nAlly = 1 --仅小兵
	local nEnemyHero = 1
	local nAllyHero = 1 --包括自己
	local nEnemyTower = 1
	local nAllyTower = 1
	local cNearEnemy = 0
	local dist = 0
	local enemies = {}
	local allies = {}
	local enemyheroes = {}
	local allyheroes = {}
	local enemytowers = {}
	local allytowers = {}
	local giveup = false
	--------------收集数据---------------
	local units = FindUnitsInRadius(hero:GetTeam(),pOrg,nil,1300,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
    if #units > 0 then
		for _,unit in pairs(units) do
			if IsValidUnit(unit) and unit:IsAlive() then
				dist = (unit:GetAbsOrigin()-pOrg):Length2D()
				if unit:GetTeamNumber()~=hero:GetTeamNumber() then
					if unit:IsBuilding() then
						if IsBuildingTower(unit) and dist<900 then
							enemytowers[nEnemyTower]=unit
							nEnemyTower=nEnemyTower+1
						end
					elseif unit:IsRealHero() and not unit:IsInvisible() then
						enemyheroes[nEnemyHero]=unit
						nEnemyHero=nEnemyHero+1
					elseif unit:GetTeamNumber()~=DOTA_TEAM_NEUTRALS then --敌方小兵 900范围
						if dist<1000 then
							enemies[nEnemy]=unit
							nEnemy=nEnemy+1
						end
						if target and (target:GetAbsOrigin()-unit:GetAbsOrigin()):Length2D()<400 then
							cNearEnemy = cNearEnemy + 1
						end
					end
				else
					if unit:IsBuilding() then
						if IsBuildingTower(unit) and dist<900 then
							allytowers[nAllyTower]=unit
							nAllyTower=nAllyTower+1
						end
					elseif unit:IsRealHero() then --友方英雄
							allyheroes[nAllyHero]=unit
							nAllyHero=nAllyHero+1
					else --前方或500范围内的友方小兵
						if dist<350 then
							allies[nAlly]=unit
							nAlly=nAlly+1
						elseif dist<1200 and IsFrontAlly(hero,unit) then
							allies[nAlly]=unit
							nAlly=nAlly+1
						end
					end
				end
			end
		end
	end
	local cEnemy = #enemies+#enemyheroes+#enemytowers
	local cAlly = #allies+#allyheroes+#allytowers
	if target==nil or not target:IsAlive() then
		giveup = true
	elseif start_position==nil or (start_position-pOrg):Length2D()>1300 then
		giveup = true
	elseif (GetEnemyFountain(hero):GetAbsOrigin() - pOrg):Length2D() <1200 then
		giveup = true
	elseif lifeper<40 then
		if AIHasStrongerHeroForce(allyheroes,enemyheroes) then
			if not AICanDuel(hero,gt,enemyheroes,enemytowers) then
				giveup = true
			end
		else
			giveup = true
		end
	elseif #enemyheroes>1 and target:GetHealthPercent()>35 then 
		giveup = true
	elseif #allyheroes<2 and (#enemyheroes>1 or lifeper<target:GetHealthPercent()) then
		giveup = true
	elseif #enemyheroes>2 and #allyheroes<=#enemyheroes then
		giveup = true
	elseif #enemytowers>0 then
		giveup = true
	elseif #enemies>2 and #allies<2 and target:GetHealthPercent()>30 then
		giveup = true
	end
	if giveup then
		hero.ai_stg=AI_STG_PUSH
	else
		if (target:GetAbsOrigin()-pOrg):Length2D()>400 and cNearEnemy<3 and #enemyheroes<3 then
			hero:MoveToNPC(target)
		else
			--攻击英雄
			AIOrderChaseHero(hero,gt,enemyheroes,allyheroes,enemies,allies)
		end
	end
	--------------结束---------------
	units = nil
	enemies = nil
    allies = nil
    enemyheroes = nil
    allyheroes = nil
    enemytowers = nil
    allytowers = nil
end

function AILineGank_Check(hero) --check for enemy
	if hero:IsInvisible() then
		return
	end
	local pOrg = hero:GetAbsOrigin()
	local nEnemy = 0 --仅小兵
	local nAlly = 0 --仅小兵
	local nEnemyHero = 0
	local nAllyHero = 0 --包括自己
	local nAllyHeroBigArea = 0 --包括自己
	local nEnemyTower = 0
	local nAllyTower = 0
	local enemyheroes = {}
	local dist = 0
	local units = FindUnitsInRadius(hero:GetTeam(),pOrg,nil,1200,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
    if #units > 0 then
		for _,unit in pairs(units) do
			if IsValidUnit(unit) and unit:IsAlive() then
				dist = (unit:GetAbsOrigin()-pOrg):Length2D()
				if unit:GetTeamNumber()~=hero:GetTeamNumber() then
					if unit:IsRealHero() and unit:GetHealthPercent()>50 and (unit:GetManaPercent()>15 or hero:GetHealthPercent()<70) then --不需检测敌人隐形and not unit:IsInvisible()
						nEnemyHero=nEnemyHero+1
						enemyheroes[nEnemyHero] = unit
					elseif unit:GetTeamNumber()~=DOTA_TEAM_NEUTRALS and not unit:IsBuilding() and dist<900 then --敌方小兵 900范围
						nEnemy=nEnemy+1
					end
				else
					if unit:IsBuilding() then
						if IsBuildingTower(unit) and dist<550 then
							nAllyTower=nAllyTower+1
						end
					elseif unit:IsRealHero() then --友方英雄
						if dist<900 then
							nAllyHero=nAllyHero+1
						end
						nAllyHeroBigArea = nAllyHeroBigArea + 1
					else --前方或500范围内的友方小兵
						if dist<350 then
							nAlly=nAlly+1
						elseif dist<900 and IsFrontAlly(hero,unit) then
							nAlly=nAlly+1
						end
					end
				end
			end
		end
	end
	if nAllyHero==1 and nAllyTower==0 and nEnemyHero>1 and (nEnemy>1 or nAlly<=nEnemy or nAlly<3 or nEnemyHero>2) then 
        --触发LinkGank
        for _,enemyhero in pairs(enemyheroes) do
        	if IsAI(enemyhero:GetPlayerID()) and enemyhero.ai_stg==AI_STG_PUSH then
        		if (enemyhero:GetAbsOrigin() - pOrg):Length2D() and enemyhero:GetHealthPercent()>45 then
        			enemyhero.ai_stg=AI_STG_LINE_GANK
        			enemyhero.ai_gankTarget = hero
        			enemyhero.ai_gankOrg = pOrg
				end
            end
        end
        enemyheroes = nil
        return
    end
    local gt = GameTime()
    local rndEnemyHero = GetAnEnemyHero(hero)
    if rndEnemyHero and gt>300 and gt<1200 and nAllyHeroBigArea==1 and IsInEnemyArea(hero) and rndEnemyHero:CanEntityBeSeenByMyTeam(hero) then
    	--触发Gank
    	local heroes = HeroList:GetAllHeroes()
    	local gankgroup = {}
    	local c = 0
		for _,enemyhero in pairs(heroes) do
			if enemyhero:IsAlive() and enemyhero:GetTeamNumber()~=hero:GetTeamNumber() and enemyhero:GetHealthPercent()>65 then
				if IsAI(enemyhero:GetPlayerID()) and enemyhero.ai_stg==AI_STG_PUSH then
					c=c+1
					gankgroup[c]=enemyhero
				end
			end
		end
		if c>=3 then
			for _,enemyhero in pairs(gankgroup) do
				enemyhero.ai_stg=AI_STG_GANK
    			enemyhero.ai_gankTarget = hero
    			enemyhero.ai_gankOrg = pOrg
    			enemyhero.ai_gankCount = c --应有gank人数，用在聚集等待中
    			enemyhero.ai_gankWait = 3 --等待时间，最多3秒
    			--changeway
    			local way = AIGetPositionWay(pOrg,enemyhero:GetTeamNumber())
				AIChangeWay(enemyhero,way)
			end
			--print("let's gank "..hero:GetUnitName())
		end
    	
    end
end

---------------------------------------------------------------------------------------------------
----------------------------------------------Follow-----------------------------------------------
---------------------------------------------------------------------------------------------------
function AIFollowStop(hero,target)
	hero.ai_followTarget = nil
	hero.ai_stg = AI_STG_PUSH
	local way = AIGetPositionWay(hero:GetAbsOrigin(),hero:GetTeamNumber())
	--changeway
	AIChangeWay(hero,way)
	Notifications:BottomToTeam(hero:GetTeamNumber(), {text=hero:GetUnitName(), duration=5, class="NotificationLine", style={color="green"}})
	Notifications:BottomToTeam(hero:GetTeamNumber(), {text="DOTA_Chat_Follow_End", class="NotificationLine", continue=true})
	if target then
		Notifications:BottomToTeam(hero:GetTeamNumber(), {text=target:GetUnitName(), class="NotificationLine", style={color="green"}, continue=true})
	end
end
function AIFollow(hero)
	local target = hero.ai_followTarget
	if target==nil or not target:IsAlive() then
		--取消跟随
		AIFollowStop(hero,target)
		return
	end
	--主要攻击目标
	local tgt_now = target:GetAttackTarget() --跟随的目标的正在攻击的敌人
	if tgt_now and IsValidEntity(tgt_now) and tgt_now:IsHero() then
		target.attack_target = tgt_now
	end
	local target_maintarget=target.attack_target

	local gt = GameTime()
	local life = hero:GetHealth()
	local lifeper = hero:GetHealthPercent()
	local mayDamage = hero:GetBaseDamageMin()*2
	local pOrg = hero:GetAbsOrigin()
	local nEnemy = 1 --仅小兵
	local nAlly = 1 --仅小兵
	local nEnemyHero = 1
	local nAllyHero = 1 --包括自己
	local nEnemyTower = 1
	local nAllyTower = 1
	local cNearEnemy = 0
	local dist = 0
	local enemies = {}
	local allies = {}
	local enemyheroes = {}
	local allyheroes = {}
	local enemytowers = {}
	local allytowers = {}
	local isback = false
	hero.hpStreak[3]=hero.hpStreak[2]
	hero.hpStreak[2]=hero.hpStreak[1]
	hero.hpStreak[1]=lifeper
	--------------收集数据---------------
	local units = FindUnitsInRadius(hero:GetTeam(),pOrg,nil,1300,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
    if #units > 0 then
		for _,unit in pairs(units) do
			if IsValidUnit(unit) and unit:IsAlive() then
				dist = (unit:GetAbsOrigin()-pOrg):Length2D()
				if unit:GetTeamNumber()~=hero:GetTeamNumber() then
					if unit:IsBuilding() then
						if IsBuildingTower(unit) and dist<900 then
							enemytowers[nEnemyTower]=unit
							nEnemyTower=nEnemyTower+1
						end
					elseif unit:IsRealHero() and not unit:IsInvisible() then
						enemyheroes[nEnemyHero]=unit
						nEnemyHero=nEnemyHero+1
					elseif unit:GetTeamNumber()~=DOTA_TEAM_NEUTRALS then --敌方小兵 900范围
						if dist<1000 then
							enemies[nEnemy]=unit
							nEnemy=nEnemy+1
						end
					end
				else
					if unit:IsBuilding() then
						if IsBuildingTower(unit) and dist<900 then
							allytowers[nAllyTower]=unit
							nAllyTower=nAllyTower+1
						end
					elseif unit:IsRealHero() then --友方英雄
							allyheroes[nAllyHero]=unit
							nAllyHero=nAllyHero+1
					else --前方或500范围内的友方小兵
						if dist<350 then
							allies[nAlly]=unit
							nAlly=nAlly+1
						elseif dist<1200 and IsFrontAlly(hero,unit) then
							allies[nAlly]=unit
							nAlly=nAlly+1
						end
					end
				end
			end
		end
	end
	local cEnemy = #enemies+#enemyheroes+#enemytowers
	local cAlly = #allies+#allyheroes+#allytowers
	if hero:HasModifier("modifier_fountain_aura_buff") and lifeper<95 then
		method = 2
	elseif (GetEnemyFountain(hero):GetAbsOrigin() - pOrg):Length2D() <1000 then
		method = 1
	elseif lifeper<35 then
		if AIHasStrongerHeroForce(allyheroes,enemyheroes) or target_maintarget then
			if AICanDuel(hero,gt,enemyheroes,enemytowers) then
				method = 3
			else
				method = 1
			end
		else
			if #enemyheroes==0 and #enemytowers==0 then
				if AIUseTPBackTown(hero) then
					isback = true
				else
					method = 1
				end
			else
				method = 1
			end
		end
	elseif hero.hpStreak[3]-hero.hpStreak[1]>8 then
		method = 1
	else
		if (pOrg-target:GetAbsOrigin()):Length2D()>800 then
			method = 6
		else
			if #enemytowers>0 then
				--周围有敌方的塔--------------------------------------------------------------------
				if #enemyheroes==0 then
					cTemp = CountAlliesNearPoint(enemytowers[1]:GetAbsOrigin(),enemytowers[1]:GetAttackRange(),hero,false,false)
					if AIAttackedByTowerRetreat(hero,enemytowers[1]) then
						method = 1
					elseif cTemp>1 or (lifeper>50 and enemytowers[1]:GetHealthPercent()<10) then
						method = 5
					else
						method = 1
					end
				else
					if chase then
						if AIHasStrongerHeroForce(allyheroes,enemyheroes) or target_maintarget then
							value = lifeper
							cTemp = CountAlliesNearPoint(enemytowers[1]:GetAbsOrigin(),enemytowers[1]:GetAttackRange(),hero,false,false)
							value=value+cTemp*15
							if lifeper>45 and value>100 then
								method = 3
							elseif lifeper>40 and life>CalMayDamage(enemytowers[1],hero)*12 and #enemyheroes<2 then
								method = 3
							elseif lifeper>40 and lifeper+cTemp*20>100 then
								method = 5
							else
								method = 1
							end
						else
							method = 1
						end
					else
						if AIHasStrongerHeroForce(allyheroes,enemyheroes) or target_maintarget then
							cTemp = CountAlliesNearPoint(enemytowers[1]:GetAbsOrigin(),enemytowers[1]:GetAttackRange(),hero,false,false)
							if lifeper>50 and lifeper*100+cTemp*20>100 then
								method = 5
							elseif lifeper>50 then
								method = 0
							else
								method = 1
							end
						else
							method = 1
						end
					end
				end
			elseif #enemyheroes>0 then
				--周围没有敌方的塔，但有敌方英雄----------------------------------------------------
				if AIHasStrongerHeroForce(allyheroes,enemyheroes) or target_maintarget then
					if chase then
						if lifeper>40 then
							method = 3
						elseif #allies>1 or #enemies==0 then
							method = 4
						elseif #allyheroes==1 and #enemies>2 then
							method = 1
						else
							method = 0
						end
					else
						--友方英雄实力更强
						if (#allies>1 or #enemies==0) and gt>600 then
							method = 4
						elseif #allies>1 or #enemies==0 then
							method = 0
						elseif #allyheroes==1 and #enemies>2 then
							method = 1
						else
							method = 0
						end
					end
				else
					--敌方英雄实力更强
					if #allyheroes>1 and lifeper>75 then --周围有队友，自己生命值较高，可以选择不跑
						if #allies>2 and #enemies<2 and gt>600 then
							method = 4
						elseif #allies>1 or #enemies==0 then
							method = 0
						else
							method = 1
						end
					else --周围没有队友，或者自己生命值低，撤退
						method = 1
					end
				end
			else
				--周围没有敌方的塔和敌方英雄--------------------------------------------------------
				if #allies>0 or #enemies==0 or IsNearFountain(hero,2000) then
					method = 0
				else
					method = 1
				end
			end
		end
	end
	--------------行动指令---------------
	if isback==false then
		if method==0 then
			--优先集火攻击的目标
			if target_maintarget and IsValidEntity(target_maintarget) and target_maintarget:IsAlive() and target_maintarget:IsHero() then
				if GameRules:GetGameTime()-target:GetLastAttackTime()<2.5 then
					AIOrderFollowAttack(hero,gt,enemyheroes,allyheroes,enemies,allies,target,target_maintarget)
				else
					AIOrderFollowMove(hero,gt,allies,enemies,enemyheroes,allyheroes,target)
				end
			else
				--攻击移动，补刀打钱，攻击射程范围内的英雄，优先攻击小兵
				AIOrderFollowMove(hero,gt,allies,enemies,enemyheroes,allyheroes,target)
			end
		elseif method==1 then
			--后退
			AIOrderRetreat(hero,gt,enemyheroes,allyheroes)
		elseif method==2 then
			--泉水里回复
			AIOrderHoldInFountain(hero)
		elseif method==3 then
			--追击敌方的一个残血英雄
			AIOrderChaseHero(hero,gt,enemyheroes,allyheroes,enemies,allies)
		elseif method==4 then
			--优先攻击英雄
			AIOrderAttackHero(hero,gt,enemies,enemyheroes,allyheroes,enemies,allies)
		elseif method==5 then
			--拆塔
			AIOrderAttackTower(hero,gt,enemies,enemytowers,allies,allyheroes,enemyheroes)
		elseif method==6 then
			--靠近跟随目标
			local f = (GetEnemyFountain(target):GetAbsOrigin()-pOrg):Normalized()
			hero:MoveToPosition(target:GetAbsOrigin()+RandomFloat(300,600)*f+RandomVector(200))
		end
	end
	--------------结束---------------
	units = nil
	enemies = nil
    allies = nil
    enemyheroes = nil
    allyheroes = nil
    enemytowers = nil
    allytowers = nil
end
function AIOrderFollowMove(hero,gt,allies,enemies,enemyheroes,allyheroes,target) --target是跟随的目标
	local pTgt = target:GetAbsOrigin()
	local pOrg = hero:GetAbsOrigin()
	local f = (GetEnemyFountain(target):GetAbsOrigin()-pTgt):Normalized()
	local range = math.max(225,hero:GetAttackRange())
	local lf = 0
	local min = 99999
	local up = nil
	if #enemies>0 then
		for k,enemy in pairs(enemies) do
			if enemy then
				lf = enemy:GetHealth()
				if lf<min then
					min = lf
					up = enemy
				end
			end
		end
	end
	if up then
		if gt<600 then
			local mayDamage = GetMayDamage(hero,up)
			local upLife =up:GetHealth() 
			if upLife<mayDamage*1.5 or (#allies-#enemies>2 and upLife<mayDamage*2) then
				--补刀
				AIFarm(hero,up,upLife,mayDamage,gt,allyheroes,enemyheroes,allies,enemies)
			else
				if #enemyheroes>0 then
					if (enemyheroes[1]:GetAbsOrigin()-pOrg):Length2D()<range and (hero:GetHealthPercent()>70 or (enemies[1]:GetAbsOrigin()-pOrg):Length2D()>350) and enemyheroes[1]:IsAlive() then
						--攻击射程内的英雄
						AIOrderAttackMove_Attack(hero,gt,enemyheroes[1],allyheroes,enemyheroes,allies,enemies)
					elseif not AIOrderAttackMove_UseSpell(hero,gt,enemyheroes[1],allyheroes,enemyheroes,allies,enemies) then --如果无法使用消耗技能
						--随机移动
						if up:GetHealth()<mayDamage*2 then
							AIOrderAttackMove_Move(hero,gt,up)
						else
							AIOrderAttackMove_Move(hero,gt,enemies[1])
						end
					end
				else
					--随机移动
					if up:GetHealth()<mayDamage*2 then
						AIOrderAttackMove_Move(hero,gt,up)
					else
						AIOrderAttackMove_Move(hero,gt,enemies[1])
					end
				end
			end
		else
			if #enemyheroes>0 then
				if (enemyheroes[1]:GetAbsOrigin()-pOrg):Length2D()<range and (hero:GetHealthPercent()>70 or (enemies[1]:GetAbsOrigin()-pOrg):Length2D()>350) and enemyheroes[1]:IsAlive() then
					--攻击射程内的英雄
					AIOrderAttackMove_Attack(hero,gt,enemyheroes[1],allyheroes,enemyheroes,allies,enemies)
				elseif not AIOrderAttackMove_UseSpell(hero,gt,enemyheroes[1],allyheroes,enemyheroes,allies,enemies) then --如果无法使用消耗技能
					--攻击小兵
					AIOrderAttackMove_Attack(hero,gt,up,allyheroes,enemyheroes,allies,enemies)
				end
			else
				--攻击小兵
				AIOrderAttackMove_Attack(hero,gt,up,allyheroes,enemyheroes,allies,enemies)
			end
		end
	else
		--攻击移动
		if hero.ai_state~=AI_STATE_ATTACK or hero.lastOrder~=AI_ORDER_MOVE_ATTACK or gt-hero.lastOrderTime>0.7 then
			hero.lastOrderTime = gt
			hero.lastOrder = AI_ORDER_MOVE_ATTACK
			hero.ai_state = AI_STATE_ATTACK
			if (pTgt-pOrg):Length2D()>800 then
				hero:MoveToPosition(pTgt+RandomFloat(300,600)*f+RandomVector(200))
			else
				hero:MoveToPositionAggressive(pTgt+RandomFloat(300,600)*f+RandomVector(200))
			end
		end
	end
end
function AIOrderFollowAttack(hero,gt,enemyheroes,allyheroes,enemies,allies,target,target_maintarget)
	local pTgt = target_maintarget:GetAbsOrigin()
	local pOrg = hero:GetAbsOrigin()
	local dist = (pTgt-pOrg):Length2D()
	local range = hero:GetAttackRange()+300
	local lf = 0
	local min = 99999
	local up = nil
	local attack_other = false --离目标太远，换其它目标
	if #enemyheroes>0 then
		for k,enemy in pairs(enemyheroes) do
			if enemy then
				lf = enemy:GetHealth()
				if lf<min then
					min = lf
					up = enemy
				end
			end
		end
	end
	if target_maintarget then
		--使用突进技能
		if not hero.skill_charge(hero,target_maintarget,allyheroes,enemyheroes) then
			if not hero.skill_control(hero,target_maintarget,allyheroes,enemyheroes) then
				if not hero.skill_damage(hero,target_maintarget,allyheroes,enemyheroes,allies,enemies,true) then --增加一个不计消耗的参数
					if not hero.skill_summon(hero,target_maintarget,allyheroes,enemyheroes) then
						if not hero.skill_weaken(hero,target_maintarget,allyheroes,enemyheroes) then
							if dist<800 then
								AIOrderAttackHero_Attack(hero,gt,target_maintarget)
							else
								attack_other = true
							end
						end
					end
				end
			end
		end
	end
	if attack_other then --若为false，就是已经攻击过target_maintarget
		if up then
			--使用突进技能
			if not hero.skill_charge(hero,up,allyheroes,enemyheroes) then
				if not hero.skill_control(hero,up,allyheroes,enemyheroes) then
					if not hero.skill_damage(hero,up,allyheroes,enemyheroes,allies,enemies,true) then --增加一个不计消耗的参数
						if not hero.skill_summon(hero,up,allyheroes,enemyheroes) then
							if not hero.skill_weaken(hero,up,allyheroes,enemyheroes) then
								AIOrderAttackHero_Attack(hero,gt,up)
							end
						end
					end
				end
			end
		else
			--离集火目标太远，附近也没有其他目标
			AIOrderFollowMove(hero,gt,allies,enemies,enemyheroes,allyheroes,target)
		end
	end
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
function AILearnAbility(hero,lv)
	local pid = hero:GetPlayerID()
	local index = hero:GetEntityIndex()
	local note = nil
	local row = nil
	--天赋
	if lv==10 then
		local ab = nil
		row = 1
		if PlayerResource:GetKills(pid) + PlayerResource:GetAssists(pid) >= PlayerResource:GetDeaths(pid) then
			ab = hero:FindAbilityByName(hero.skill_tree[101]) 
			note = "left"
		else
			ab = hero:FindAbilityByName(hero.skill_tree[102]) 
			note = "right"
		end
		--特殊
		if hero:GetUnitName()=="npc_dota_hero_bane" then
			ab = hero:FindAbilityByName(hero.skill_tree[101]) 
			note = "left"
		end
		if ab then
			hero:UpgradeAbility(ab)
			Talents.OnLearnTalent(pid, {PlayerID=pid,index=note,unit=index,row=row})
		end 
	elseif lv==15 then
		local ab = nil
		row = 2
		if PlayerResource:GetKills(pid) + PlayerResource:GetAssists(pid) >= PlayerResource:GetDeaths(pid) then
			ab = hero:FindAbilityByName(hero.skill_tree[103]) 
			note = "left"
		else
			ab = hero:FindAbilityByName(hero.skill_tree[104]) 
			note = "right"
		end
		if ab then
			hero:UpgradeAbility(ab)
			Talents.OnLearnTalent(pid, {PlayerID=pid,index=note,unit=index,row=row})
		end 
	elseif lv==20 then
		local ab = nil
		row = 3
		if PlayerResource:GetKills(pid) + PlayerResource:GetAssists(pid) >= PlayerResource:GetDeaths(pid) then
			ab = hero:FindAbilityByName(hero.skill_tree[105]) 
			note = "left"
		else
			ab = hero:FindAbilityByName(hero.skill_tree[106]) 
			note = "right"
		end
		if ab then
			hero:UpgradeAbility(ab)
			Talents.OnLearnTalent(pid, {PlayerID=pid,index=note,unit=index,row=row})
		end 
	elseif lv==25 then
		local ab = nil
		row = 4
		if PlayerResource:GetKills(pid) + PlayerResource:GetAssists(pid) >= PlayerResource:GetDeaths(pid) then
			ab = hero:FindAbilityByName(hero.skill_tree[107]) 
			note = "left"
		else
			ab = hero:FindAbilityByName(hero.skill_tree[108]) 
			note = "right"
		end
		if ab then
			hero:UpgradeAbility(ab)
			Talents.OnLearnTalent(pid, {PlayerID=pid,index=note,unit=index,row=row})
		end 
	else
		local name = hero.skill_tree[lv]
		local ab = hero:FindAbilityByName(name) 
		if ab then
			hero:UpgradeAbility(ab)
		end
	end
end

function AIGetTCCost(tbl)
	local cost = 0
	for i=1,6 do
		cost=cost+GetItemCost(tbl[i])
	end
	--cost=cost+tbl[7]
	return cost
end
function AITCUp(hero)
	local i = hero:GetPlayerID()
	local tbl = hero.item_tree
	local cost = hero.tc_nextcost
	PlayerResource:SpendGold(i,cost,DOTA_ModifyGold_PurchaseItem)
	hero.tc=hero.tc+1
	local tc = hero.tc
	if tbl[tc+1] then
		--PrintTable(tbl[tc+1])
		hero.tc_nextcost=AIGetTCCost(tbl[tc+1])-AIGetTCCost(tbl[tc])
	else
		hero.tc_nextcost=999999
	end
end
function AIGetItem(hero)
	local tc = hero.tc
	local tbl = hero.item_tree[tc]
	for i=1,6 do
		local it = hero:GetItemInSlot(i-1) 
		hero:RemoveItem(it) 
		hero:AddItemByName(tbl[i])
	end
	hero.tc_equip=tc
end
function AISetItemCharges(hero)
--[[
	if hero.tc_equip<2 then
		local it = FindItemOnUnit(hero,"item_fruit")
		if it then
			it:SetCurrentCharges(3)
		else
			it = hero:AddItemByName("item_fruit")
			it:SetCurrentCharges(3)
		end 
	end
	]]
	if GameTime()>20 then
		local it = FindItemOnUnit(hero,"item_tpscroll")
		if it then
			it:SetCurrentCharges(3)
		else
			if not hero:HasItemInInventory("item_travel_boots") then
				it = hero:AddItemByName("item_tpscroll")
				it:SetCurrentCharges(3)
			end
		end 
	end
	--[[查查补充菊花
	if hero:GetUnitName() =="npc_dota_hero_bane" then
		local ab = hero:FindAbilityByName("char_profound")
		if ab and ab:GetLevel()>0 then
			local max = ab:GetLevelSpecialValueFor("max",ab:GetLevel()-1)
			if not hero:HasModifier("modifier_char_profound_stack") then
		        ab:ApplyDataDrivenModifier(hero, hero, "modifier_char_profound_stack", nil)
		    end
		    hero:SetModifierStackCount("modifier_char_profound_stack", hero, max)
		end
	end
	]]
end

function AIGetTPItem(hero)
	local it = FindItemOnUnit(hero,"item_tpscroll")
	if it then
		return it
	end
	it = FindItemOnUnit(hero,"item_travel_boots")
	if it then
		return it
	end
	it = FindItemOnUnit(hero,"item_travel_boots_2")
	if it then
		return it
	end
	return nil
end
function AICanUseTP(hero)
	local it = AIGetTPItem(hero)
	if it then
		local manacost = it:GetManaCost(-1)
		if it:IsCooldownReady() and hero:GetMana()>manacost and not it:IsMuted() then
			return true
		end
	end
	return false
end
function AIUseTPBackTown(hero)
	local pTgt = GetFountain(hero):GetAbsOrigin()
	local it = AIGetTPItem(hero)
	local id = hero:GetPlayerID()
	if not AIIsCastingTPSpell(hero) then --是否正在使用回城相关的技能
		if not AIOrderUseTPSpell(hero,pTgt) then --是否可以使用回城技能，可以则不再用tp
			if it then
				local manacost = it:GetManaCost(-1)
				if (pTgt-hero:GetAbsOrigin()):Length2D() > 2000 then
					if it:IsCooldownReady() and hero:GetMana()>manacost and not it:IsMuted() then
						hero:CastAbilityOnPosition(pTgt, it, id)
						return true
					end
				end
			end
		else
			return true
		end
	end
	return false
end
function AIUseTPPosition(hero,pTgt)
	local it = AIGetTPItem(hero)
	local id = hero:GetPlayerID()
	if not AIIsCastingTPSpell(hero) then --是否正在使用回城相关的技能
		if not AIOrderUseTPSpell(hero,pTgt) then --是否可以使用回城技能，可以则不再用tp
			if it then
				local manacost = it:GetManaCost(-1)
				if (pTgt-hero:GetAbsOrigin()):Length2D() > 3000 and GameTime()>30 then --gametime>30 for AIOrderChangeWay
					if it:IsCooldownReady() and hero:GetMana()>manacost and not it:IsMuted() then
						hero:CastAbilityOnPosition(pTgt, it, id)
						return true
					end
				end
			end
		else
			return true
		end
	end
	return false
end
function AIIsCastingTPSpell(hero)
	--星尘零的流星雨
	if hero:HasModifier("modifier_stardust_meteor") then
		return true
	end
	return false
end
function AIOrderUseTPSpell(hero,pTgt)
	--星尘零的流星雨
	if hero:GetUnitName()=="npc_dota_hero_dragon_knight" then
		local ab = hero:FindAbilityByName("stardust_meteor")
    	local id = hero:GetPlayerID()
    	local mana = hero:GetMana()
    	local lv = ab:GetLevel()
    	if ab:IsCooldownReady() and lv>0 then
    		local manacost = ab:GetManaCost(-1)
    		if mana>manacost and not hero:IsMuted() then
        		hero:CastAbilityOnPosition(pTgt, ab, id)
        		hero.lastOrder = 3
        		return true
        	end
    	end
    end
	return false
end

function AIOrderTPSave(building,attacker)
	local team = building:GetTeamNumber()
	local pOrg = building:GetAbsOrigin()
	local nEnemyHero = 0
	local nAllyHero = 0
	local nEnemy = 0
	local count = 0
	if building:GetHealthPercent()<80 then
		local units = FindUnitsInRadius(building:GetTeam(),pOrg,nil,1200,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
	    if #units > 0 then
			for _,unit in pairs(units) do
				if IsValidUnit(unit) and unit:IsAlive() then
					if unit:GetTeamNumber()~=team then
						if unit:IsRealHero() then
							nEnemyHero=nEnemyHero+1
						else
							nEnemy=nEnemy+1
						end
					else
						if unit:IsRealHero() then
							nAllyHero=nAllyHero+1
						end
					end
				end
			end
		end
		if nEnemyHero==0 then
			if nEnemy>5 and nAllyHero==0 then
				for i=0,9 do
					local player = PlayerResource:GetPlayer(i)
					if player then
						if IsAI(i) then
							local hero = player:GetAssignedHero()
							if hero:GetTeamNumber()==team and (hero.ai_stg==AI_STG_PUSH or hero.ai_stg==AI_STG_JUNGLE) then
								--英雄是否可以来
								if (hero:GetAbsOrigin()-pOrg):Length2D()>3000 then
									if AIUseTPPosition(hero,pOrg) then
										--local way = AIGetPositionWay(pOrg,team)
										--AIChangeWay(hero,way)
										count = count + 1
									end
								else
									--local way = AIGetPositionWay(pOrg,team)
									--changeway
									--AIChangeWay(hero,way)
									count = count + 1
								end
							end
						end
					end
					if count>0 then
						break
					end
				end
			end
		elseif nEnemyHero>nAllyHero then
			for i=0,9 do
				local player = PlayerResource:GetPlayer(i)
				if player then
					if IsAI(i) then
						local hero = player:GetAssignedHero()
						if hero:GetTeamNumber()==team and (hero.ai_stg==AI_STG_PUSH or hero.ai_stg==AI_STG_JUNGLE) then
							--英雄是否可以来
							if (hero:GetAbsOrigin()-pOrg):Length2D()>3000 then
								if AIUseTPPosition(hero,pOrg) then
									local way = AIGetPositionWay(pOrg,team)
									AIChangeWay(hero,way)
									count = count + 1
								end
							else
								local way = AIGetPositionWay(pOrg,team)
								--changeway
								AIChangeWay(hero,way)
								count = count + 1
							end
						end
					end
				end
				if count>=nEnemyHero then
					break
				end
			end
		end
	end
end

function AISummonStart(unit,hero)
	Timers:CreateTimer(function()
		if not unit:IsAlive() or not IsValidEntity(unit) then
			return nil
		else
			local tgt = nil
			local pOrg = unit:GetAbsOrigin()
			if hero.lastTarget and IsValidEntity(hero.lastTarget) and hero.lastTarget:IsAlive() then
				if (hero.lastTarget:GetAbsOrigin()-pOrg):Length2D()<1000 then
					tgt = hero.lastTarget
				end
			end
			if tgt==nil then
				if hero:IsAlive() then
					local f = hero:GetForwardVector():Normalized()
					if (pOrg-hero:GetAbsOrigin()):Length2D()>900 then		
						unit:MoveToPosition(hero:GetAbsOrigin()+400*f)
					else
						unit:MoveToPositionAggressive(hero:GetAbsOrigin()+400*f)
					end
				else
					unit:MoveToPositionAggressive(GetEnemyFountain(hero):GetAbsOrigin())
				end
			else
				unit:MoveToTargetToAttack(tgt)
			end
			return 1
		end
	end)
end

function AIForceMove()
end