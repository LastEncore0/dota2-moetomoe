--[[
	jotaro 承太郎
]]
--精确
function Precision_block(keys)
	-- init --
	local caster = keys.caster
	local ability = keys.ability

	local damage = keys.damage
	print("block damage",damage)

	caster:SetHealth(caster:GetHealth() + damage)
	
	-- stack handling --
end

function Blink(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local ability = keys.ability
	local time = ability:GetLevelSpecialValueFor("time", (ability:GetLevel() - 1))
	
	local healreg = caster:GetHealthRegen()
	local manareg = caster:GetManaRegen()
	if caster:HasTalent("jojo_talent_2") then
		time = time + 1
	end
	local movespeed = caster:GetBaseMoveSpeed()
	local range = movespeed * time
	print("range",range)
	caster:SetHealth(caster:GetHealth() + healreg * time * 10)
	caster:SetMana(caster:GetMana() + manareg * time * 10)
	for i=0, 23 do
		if caster:GetAbilityByIndex(i) ~= null then
			local FindAbility = caster:GetAbilityByIndex(i)
			if not FindAbility:IsCooldownReady() then
				local cd = FindAbility:GetCooldownTimeRemaining()
				cd=cd-time
				FindAbility:EndCooldown() 
				if cd>0 then
					FindAbility:StartCooldown(cd) 
				end
			end
		end
	end
	for i=0, 9 do
		if caster:GetItemInSlot(i) ~= null then
			local item = caster:GetItemInSlot(i)
			if not item:IsCooldownReady() then
				local cd = item:GetCooldownTimeRemaining()
				cd=cd-time
				item:EndCooldown() 
				if cd>0 then
					item:StartCooldown(cd) 
				end
			end
		end
	end
	-- Set the mana on this unit.(caster:GetHealth() + healreg * time * 10)
	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)
    local world_attack = caster:FindAbilityByName("world_attack")
	local cooldown = world_attack:GetCooldown(world_attack:GetLevel() - 1)
	world_attack:StartCooldown(cooldown) 
	ability:StartCooldown(cooldown) 
	local blinkIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
	Timers:CreateTimer( 1, function()
		ParticleManager:DestroyParticle( blinkIndex, false )
		return nil
		end
	)
end

function timeattack( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local time = ability:GetLevelSpecialValueFor("time", (ability:GetLevel() - 1))
	local healreg = caster:GetHealthRegen()
	local manareg = caster:GetManaRegen()
	if caster:HasTalent("jojo_talent_2") then
		time = time + 1
	end
 if target:HasAbility("time_stop") then
	caster:PerformAttack(target, true, true, true, true, true, false, false)
 else
    for i=0, time do
	caster:PerformAttack(target, true, true, true, true, true, false, false)
	end
 end

	caster:SetHealth(caster:GetHealth() + healreg * time * 10)
	caster:SetMana(caster:GetMana() + manareg * time * 10)
	for i=0, 23 do
		if caster:GetAbilityByIndex(i) ~= null then
			local FindAbility = caster:GetAbilityByIndex(i)
			if not FindAbility:IsCooldownReady() then
				local cd = FindAbility:GetCooldownTimeRemaining()
				cd=cd-time
				FindAbility:EndCooldown() 
				if cd>0 then
					FindAbility:StartCooldown(cd) 
				end
			end
		end
	end
	for i=0, 9 do
		if caster:GetItemInSlot(i) ~= null then
			local item = caster:GetItemInSlot(i)
			if not item:IsCooldownReady() then
				local cd = item:GetCooldownTimeRemaining()
				cd=cd-time
				item:EndCooldown() 
				if cd>0 then
					item:StartCooldown(cd) 
				end
			end
		end
	end
	local world_blink = caster:FindAbilityByName("world_blink")
	local cooldown = world_blink:GetCooldown(world_blink:GetLevel() - 1)
	world_blink:StartCooldown(cooldown) 
	ability:StartCooldown(cooldown) 
end

function str_damage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local str = caster:GetStrength()
	local math = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )
	local BaseDamage = ability:GetAbilityDamage()
	local strdamage = str * math 
	local damageType = ability:GetAbilityDamageType()
	--local direction = caster:GetForwardVector()
	--local fissure_range = ability:GetLevelSpecialValueFor("fissure_range", (ability:GetLevel() -1))
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", (ability:GetLevel() -1))
	--local width = ability:GetLevelSpecialValueFor("width", (ability:GetLevel() -1))
	--local startPos = keys.target_points[1]
	--local endPos = keys.target_points[1] + direction * fissure_range
	--local units = FindUnitsInLine(caster:GetTeam(), startPos, endPos, nil, width, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0)
   print("ora",BaseDamage)
	--for i,unit in ipairs(units) do
	--	print("unit",unit:GetUnitName())
	target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
     if caster:HasTalent("jojo_talent_1") then
	   local damageTable = {
		victim = target,
		attacker = caster,
		damage = BaseDamage + strdamage,
		damage_type = damageType
	   }
	 ApplyDamage( damageTable )
	   else
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = BaseDamage,
			damage_type = damageType
		 }
		 ApplyDamage( damageTable )
	 end
  --end
end