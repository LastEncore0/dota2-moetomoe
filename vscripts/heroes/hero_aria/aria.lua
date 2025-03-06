LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )
--[[
	亚里亚刀枪切换
]]
function ModelSwapStart( keys )
	local caster = keys.caster
	local model = keys.model
	local projectile_model = keys.projectile_model
	local doubleknifestrike = "doubleknifestrike"
	local meelgun = "meelgun"

	-- Saves the original model and attack capability
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end
	caster.caster_attack = caster:GetAttackCapability()
    caster.ariagun = true
	-- Sets the new model and projectile
	caster:SetOriginalModel(model)
	caster:SetRangedProjectileName(projectile_model)

	-- Sets the new attack type
	caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
	caster:SwapAbilities(meelgun, doubleknifestrike, true, false) 
end


function ModelSwapEnd( keys )
	local caster = keys.caster
	local doubleknifestrike = "doubleknifestrike"
	local meelgun = "meelgun"
    caster.ariagun = nil
	caster:SetModel(caster.caster_model)
	caster:SetOriginalModel(caster.caster_model)
	caster:SetAttackCapability(caster.caster_attack)
	caster:SwapAbilities(doubleknifestrike, meelgun, true, false) 
end



function HideWearables( event )
	local hero = event.caster
	local ability = event.ability

	hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(hero.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( event )
	local hero = event.caster

	for i,v in pairs(hero.hiddenWearables) do
		v:RemoveEffects(EF_NODRAW)
	end
end
function stopattacksound( event )
	StopSoundOn("Hero_Juggernaut.BladeFuryStart",keys.caster)
end

---近战枪斗术

function meelgun( event )
 local caster = event.caster
 local target = event.target
 local ability = event.ability
 local target_location = target:GetAbsOrigin()
 local caster_location = caster:GetAbsOrigin()
 local distance = (target_location - caster_location):Length2D() 
 if distance == 0 then
 local distance = 1
 end
 local latchDistance = event.latch_distance_to_target
 local prcDistance = event.prcDistance
 local attachdamge = ability:GetLevelSpecialValueFor( "attachdamge", ability:GetLevel() -1 )
 local disprct = prcDistance/distance
 print(disprct)
 local random = RandomFloat(0, 1)
 local disrandom = random + disprct
 if distance < latchDistance then
   if disrandom > 1 then
	ApplyDamage({victim = target,attacker = caster,damage = attachdamge,damage_type = ability:GetAbilityDamageType()})
	EmitSoundOn("Hero_Sniper.AssassinateDamage",target)
	print(caster:GetUnitName())
	else
	print(random )
    end
 end

end



--[[双刀突袭]]
function ApplyBuff(keys)
	local caster = keys.caster
	local target = keys.target
	local caster_origin = caster:GetAbsOrigin()
	
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local min_distance = ability:GetLevelSpecialValueFor("min_proc_distance", ability:GetLevel() -1)
	local max_distance = ability:GetLevelSpecialValueFor("max_proc_distance", ability:GetLevel() -1)
	local duration = ability:GetLevelSpecialValueFor("buff_duration", ability:GetLevel() -1)
	
	-- Checks if the ability is off cooldown and if the caster is attacking a target
	if target ~= null and ability:IsCooldownReady() then
		-- Checks if the target is an enemy
		if caster:GetTeam() ~= target:GetTeam() then
			local target_origin = target:GetAbsOrigin()
			local distance = math.sqrt((caster_origin.x - target_origin.x)^2 + (caster_origin.y - target_origin.y)^2)
			ability.target = target
			-- Checks if the caster is in range of the target
			if distance >= min_distance and distance <= max_distance then
				-- Removes the 522 move speed cap
				caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", { duration = duration })
				-- Apply the speed buff
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_speed_buff", {})
				-- Start cooldown on the passive
				ability:StartCooldown(cooldown)
			-- If the caster is too far from the target, we continuously check his distance until the attack command is canceled
			elseif distance >= max_distance then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_check_distance", {})
			end
		end
	end
end


function DistanceCheck(keys)
	local caster = keys.caster
	local caster_origin = caster:GetAbsOrigin()
	
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local min_distance = ability:GetLevelSpecialValueFor("min_proc_distance", ability:GetLevel() -1)
	local max_distance = ability:GetLevelSpecialValueFor("max_proc_distance", ability:GetLevel() -1)
	local duration = ability:GetLevelSpecialValueFor("buff_duration", ability:GetLevel() -1)
	
	-- Checks if the caster is still attacking the same target
	if caster:GetAggroTarget() == ability.target then
		local target_origin = ability.target:GetAbsOrigin()
		local distance = math.sqrt((caster_origin.x - target_origin.x)^2 + (caster_origin.y - target_origin.y)^2)
		-- Checks if the caster is in range of the target
		if distance >= min_distance and distance <= max_distance then
			-- Removes the 522 move speed cap
			caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", { duration = duration })
			-- Apply the speed buff
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_speed_buff", {})
			-- Start cooldown on the passive
			ability:StartCooldown(cooldown)
			caster:RemoveModifierByName("modifier_check_distance")
		end
	else
		caster:RemoveModifierByName("modifier_check_distance")
	end
end

function RemoveBuff(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	if target == null or target ~= ability.target then
		caster:RemoveModifierByName("modifier_speed_buff")
	end
end
---武侦制服
function HandleLivingArmor(keys)
	-- init --
	local caster = keys.caster
	local ability = keys.ability

	local damage = keys.damge
	local block = ability:GetLevelSpecialValueFor("damage_block", ability:GetLevel() -1)
	local health_prct = ability:GetLevelSpecialValueFor("health_prct", ability:GetLevel() -1)
	local crruentheal = caster:GetHealth()
	local needheal = caster:GetMaxHealth() * health_prct 
	-- Get the maximum health of this entity.
	-- Get the maximum health of this entity.
	-- heal handling --
	if caster:HasTalent("aria_talent_1") then
	block = block + ability:GetLevelSpecialValueFor("talent_block", (ability:GetLevel() - 1))
	end
	local heal = damage
	if damage > block then heal = block end

	if crruentheal > needheal then
	caster:SetHealth(caster:GetHealth() + heal)
	end
	
	-- stack handling --
end

function ifhasmeelgun(keys)
	-- init --
	local caster = keys.caster
	local ability = keys.ability
	local modifier_meelgun = keys.name1
	local modifier_phantom_rush_datadriven = keys.name2
	--local modifier_speed_buff = caster:FindModifierByName("modifier_speed_buff")
	--local modifier_knifestrike = caster:FindModifierByName("modifier_knifestrike")
	-- Return a handle to the modifier of the given name if found, else nil (string Name )



	if caster.ariagun ~= nil then
	-- print("hasmeelgun")
	if not caster:HasModifier(modifier_meelgun) then
	ability:ApplyDataDrivenModifier(caster, caster, modifier_meelgun, {})
	end
	caster:RemoveModifierByName(modifier_phantom_rush_datadriven)
	--caster:RemoveModifierByName(modifier_speed_buff)
	--caster:RemoveModifierByName(modifier_knifestrike)
	else
	-- print("nohasmeelgun")
	if not caster:HasModifier(modifier_phantom_rush_datadriven) then
	-- Sees if this unit has a given modifier.
	ability:ApplyDataDrivenModifier(caster, caster, modifier_phantom_rush_datadriven, {})
	end
	caster:RemoveModifierByName(modifier_meelgun)
	end
	
	-- stack handling --
end
--紧急逮捕
function DaibuCheck(keys)
	local caster = keys.caster
	local caster_origin = caster:GetAbsOrigin()
	local target = keys.target
	local target_origin = target:GetAbsOrigin()
	--local unit = keys.unit
	local ability = keys.ability
	local max_distance = ability:GetLevelSpecialValueFor("max_distance", ability:GetLevel() -1)
	local time = ability:GetLevelSpecialValueFor("time", ability:GetLevel() -1)
	local death = ability:GetLevelSpecialValueFor("death", ability:GetLevel() -1)
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	print("target",target:GetName())
	--print("unit",unit:GetName())
	

	
	-- Checks if the caster is still attacking the same target
	if caster:HasTalent("aria_talent_2") then
		local distance = (caster_origin - target_origin):Length2D()
		-- Checks if the caster is in range of the target
		if distance <= max_distance then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_daibu", { duration = time })
			-- Start cooldown on the passive
			ability:StartCooldown(cooldown)
			else
			ability.stack = 0
			print("distance =",distance)
	    end
	else
	ability.stack = 0
	end
end

function Daibutimemark(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local death = ability:GetLevelSpecialValueFor("death", ability:GetLevel() -1)
	local target_location = target:GetAbsOrigin()
	local particle_kill = keys.particle_kill
	print("ability.stack =",ability.stack)

	
	

	
	-- Checks if the caster is still attacking the same target
	if ability.stack == nil then
		ability.stack = 1
		elseif ability.stack >= death then
		EmitSoundOn("Hero_Sniper.AssassinateDamage",target)
		 local damage_table = {}
 	     damage_table.victim = target
 	     damage_table.attacker = caster
 	     damage_table.ability = ability
		 damage_table.damage_type = DAMAGE_TYPE_PURE
 	     damage_table.damage = 9999
		 ApplyDamage(damage_table)
		 ability.stack = 0
	     else
	     ability.stack = ability.stack + 1
	end
end
