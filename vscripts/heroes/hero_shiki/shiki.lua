--[[
	两仪式
]]
--猫返
function neko_gaeshi( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )
	local damageType = ability:GetAbilityDamageType()
	caster:PerformAttack(target, true, true, true, true, true, false, false)
	if caster:HasTalent("shiki_talent_1") then
	local damageTable = {
		victim = keys.target,
		attacker = keys.caster,
		damage = damage,
		damage_type = damageType
	}
	ApplyDamage( damageTable )
end
end
--阴阳螺旋
function Inyou_Rasen( keys )
	-- Check if spell has already casted
	if keys.caster.ball_lightning_is_running ~= nil and keys.caster.ball_lightning_is_running == true then
		keys.ability:RefundManaCost()
		return
	end

	-- Variables from keys
	local caster = keys.caster
	local casterLoc = caster:GetAbsOrigin()
	local target = keys.target_points[ 1 ] 
	local ability = keys.ability
	-- Variables inheritted from ability
	local speed = ability:GetLevelSpecialValueFor( "Inyou_Rasen_move_speed", ability:GetLevel() - 1 )
	local destroy_radius = ability:GetLevelSpecialValueFor( "Inyou_Rasen_radius", ability:GetLevel() - 1 )
	local vision_radius = ability:GetLevelSpecialValueFor( "Inyou_Rasen_vision_radius", ability:GetLevel() - 1 )
	
	-- Variables based on modifiers and precaches
	local particle_dummy = "particles/status_fx/status_effect_base.vpcf"
	local loop_sound_name = "Hero_StormSpirit.BallLightning.Loop"
	local modifierName = "modifier_ball_lightning_buff_datadriven"
	
	-- Necessary pre-calculated variable
	local currentPos = casterLoc
	local intervals_per_second = speed / destroy_radius		-- This will calculate how many times in one second unit should move based on destroy tree radius
	local forwardVec = ( target - casterLoc ):Normalized()
	
	-- Set global value for damage mechanism
	caster.ball_lightning_start_pos = casterLoc
	caster.ball_lightning_is_running = true
	
	-- Adjust vision
	caster:SetDayTimeVisionRange( vision_radius )
	caster:SetNightTimeVisionRange( vision_radius )
	
	-- Start
	local distance = 0.0
    print("intervals_per_second",intervals_per_second)
		Timers:CreateTimer( function()
				-- Spending mana
				distance = distance + speed / intervals_per_second
				-- Update location
				caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
				currentPos = currentPos + forwardVec * ( speed / intervals_per_second )
				-- caster:SetAbsOrigin( currentPos ) -- This doesn't work because unit will not stick to the ground but rather travel in linear
				FindClearSpaceForUnit( caster, currentPos, false )
				
				-- Check if unit is close to the destination point
				if ( target - currentPos ):Length2D() <= speed / intervals_per_second then
					-- Exit condition
					caster:RemoveModifierByName( modifierName )
					--StopSoundEvent( loop_sound_name, caster )
					caster.ball_lightning_is_running = false
					return nil
				else
					return 1 / intervals_per_second
				end
			end
		)
end

--[[
	Author: kritth
	Date: 12.01.2015.
	Damage the units that user runs into based on the distance
]]
function ball_lightning_damage( keys )
	-- Variables
	local ability = keys.ability
	local caster = keys.caster
	local damage = ability:GetAbilityDamage()
	local damageType = ability:GetAbilityDamageType()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
	-- Calculate and damage the unit
	local damageTable = {
		victim = keys.target,
		attacker = keys.caster,
		damage = damage,
		damage_type = damageType
	}
	ApplyDamage( damageTable )
end

function addstack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local maxStack = ability:GetLevelSpecialValueFor("max_stacks", (ability:GetLevel() - 1))
	local modifierBuffName = "modifier_Inyou_Rasen"
	local modifier = "modifier_Inyou_Rasen_stack"
	local modifierCount = caster:GetModifierStackCount( modifier, ability )
	local currentStack = 0
	local modifierName
	ability:EndCooldown()

	if caster:HasTalent("shiki_talent_2") then
		maxStack = maxStack + ability:GetLevelSpecialValueFor("add", (ability:GetLevel() - 1))
		end

	if caster:HasModifier(modifier) then
		-- Get the current stacks
		local stack_count = caster:GetModifierStackCount(modifier, ability)
			print("stack_count",stack_count)
		-- Check if the current stacks are lower than the maximum allowed
		if stack_count < maxStack then
			-- Increase the count if they are
			caster:SetModifierStackCount(modifier, ability, stack_count + 1)
			if not caster:HasModifier(modifierBuffName) then
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
			end
		end
	else
		-- Apply the attack speed modifier and set the starting stack number
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
		caster:SetModifierStackCount(modifier, ability, 1)
	end
end

function addmodfiertalent( keys )
	local caster = keys.caster
	local ability = FindAbilityByName("Inyou_Rasen")
	-- Retrieve an ability by name from the unit.
	local modifierBuffName = "modifier_Inyou_Rasen"


	if not caster:HasModifier(modifierBuffName) then
		ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end

end

function shiki_reduce( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierBuffName = "modifier_Inyou_Rasen"
	local modifier = "modifier_Inyou_Rasen_stack"
	local modifierCount = caster:GetModifierStackCount( modifier, ability )
	local currentStack = 0
	local modifierName
	local cooldown = ability:GetLevelSpecialValueFor("time", (ability:GetLevel() - 1))

	if caster:HasModifier(modifier) then
		-- Get the current stacks
		local stack_count = caster:GetModifierStackCount(modifier, ability)
			print("stack_count",stack_count)
		-- Check if the current stacks are lower than the maximum allowed
		if stack_count > 0 then
		if stack_count > 1 then
			-- Increase the count if they are
			caster:SetModifierStackCount(modifier, ability, stack_count - 1)
			if not caster:HasModifier(modifierBuffName) then
				ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
				end

	else
		print("cooldown",cooldown)
		-- Apply the attack speed modifier and set the starting stack number

			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		caster:SetModifierStackCount(modifier, ability, 0)
		ability:StartCooldown(cooldown)
		-- 
	end
end
end
end
--- 斩杀因果
function checkdeatheye( keys )
	local ability = keys.ability
	local caster = keys.caster
	if not caster:HasModifier("modifier_death_eye_datadriven") then
	ability:SetActivated(false)
	caster:RemoveModifierByName("modifier_slay_conceptual") 
	else
	ability:SetActivated(true)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_slay_conceptual", {})	
	end
	--print("checkdeatheye")
end

function slayconceptual( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local random = RandomInt(0,5)
	if random == 0 then
	ability:ApplyDataDrivenModifier(caster, target, "modifier_slay_conceptual_root", {})	
	elseif random == 1 then
	ability:ApplyDataDrivenModifier(caster, target, "modifier_slay_conceptual_silence", {})	
    elseif random == 2 then
	ability:ApplyDataDrivenModifier(caster, target, "modifier_slay_conceptual_muted", {})	
    elseif random == 3 then
	ability:ApplyDataDrivenModifier(caster, target, "modifier_slay_conceptual_pd", {})	
    elseif random == 4 then
	ability:ApplyDataDrivenModifier(caster, target, "modifier_slay_conceptual_disarmed", {})
	else
    ability:ApplyDataDrivenModifier(caster, target, "modifier_slay_conceptual_blind", {})		
	end
	--print("checkdeatheye")
end

---直死之魔眼
function modifier_shiki_mana_cost(keys)
	local  caster = keys.caster
	local  ability = keys.ability
	local mana_cost = ability:GetManaCost(-1)
	-- local modifier_flamewing = keys.modifier_flamewing
	if not caster:HasTalent("shiki_talent_3") then
		if caster:GetMana() >= mana_cost or caster:IsSilenced() then
		caster:SpendMana(mana_cost, ability)
		else
		ability:ToggleAbility()
	end
	
	else
	print("has talent")
	end
	
	end

	function death_eye(keys)
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local ability_level = ability:GetLevel() - 1
	    local death = ability:GetLevelSpecialValueFor("death", (ability:GetLevel() - 1))/100
	
		-- Ability variables
		local kill_threshold = target:GetMaxHealth() * death 
	
	
		-- Initializing the damage table
		if target:GetHealth() < kill_threshold then
		-- Get the health of this entity.
		local damage_table = {}
		 damage_table.victim = target
		 damage_table.attacker = caster
		 damage_table.ability = ability
		 damage_table.damage_type = DAMAGE_TYPE_PURE
		 damage_table.damage = kill_threshold
		 ApplyDamage(damage_table)
        end
	end