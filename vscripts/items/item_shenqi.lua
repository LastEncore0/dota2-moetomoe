--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when Refresher Orb is cast.  Takes the player's abilities and items off cooldown.
================================================================================================================= ]]
function zero_time(keys)
local caster = keys.caster
local HealthRestore = caster:GetMaxHealth()
-- Get the maximum health of this entity.
-- Get the maximum mana of this unit.
local flMana = caster:GetMaxMana( )
-- Get the maximum health of this entity.
local modifierBuffName = "modifier_item_zero_time_2"
local ability = keys.ability


    caster:SetHealth(HealthRestore)
	caster:SetMana(flMana)
	--Refresh all abilities on the caster.
	for i=0, 15, 1 do  --The maximum number of abilities a unit can have is currently 16.
		local current_ability = keys.caster:GetAbilityByIndex(i)
		if current_ability ~= nil then
			current_ability:EndCooldown()
		end
	end
	
	--Refresh all items the caster has.
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() ~= "item_refresher_datadriven" then  --Refresher Orb does not refresh itself.
				current_item:EndCooldown()
			end
		end
	end


	ability:ApplyDataDrivenModifier( caster, caster, modifierBuffName, {} )

end
function blink_start(keys)
	ProjectileManager:ProjectileDodge(keys.caster)  --Disjoints disjointable incoming projectiles.
	
	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, keys.caster)
	keys.caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
	
	local origin_point = keys.caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local difference_vector = target_point - origin_point
	
	if difference_vector:Length2D() > keys.MaxBlinkRange then  --Clamp the target point to the BlinkRangeClamp range in the same direction.
		target_point = origin_point + (target_point - origin_point):Normalized() * keys.BlinkRangeClamp
	end
	
	keys.caster:SetAbsOrigin(target_point)
	FindClearSpaceForUnit(keys.caster, target_point, false)
	
	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, keys.caster)
end
function Blink(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local ability = keys.ability
	local range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() - 1))

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)
	
	local blinkIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
	Timers:CreateTimer( 1, function()
		ParticleManager:DestroyParticle( blinkIndex, false )
		return nil
		end
	)
end
function modifier_damage(keys)
	local attacker_name = keys.attacker:GetName()

	if keys.attacker:IsControllableByAnyPlayer() then  --If the damage was dealt by neutrals or lane creeps, essentially.
		if keys.ability:GetCooldownTimeRemaining() < keys.DamageCooldown then
			keys.ability:StartCooldown(keys.DamageCooldown)
		end
	end
end
function ifesteal_impact(keys)
	if keys.target.GetInvulnCount == nil then
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.attacker, "modifier_ifesteal_impact", {duration = 0.03})
	end
end
function GiveVision(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local sight_radius = ability:GetLevelSpecialValueFor("sight_radius", (ability:GetLevel() -1))
	local sight_duration = ability:GetLevelSpecialValueFor("sight_duration", (ability:GetLevel() -1))
	
	AddFOWViewer(caster:GetTeam(), point, sight_radius, sight_duration, false)
end

function Fryja_kill( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local unit = keys.unit

	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local kill_pct = ability:GetLevelSpecialValueFor("kill_pct", ability_level)
	local unit_hp = unit:GetHealth()
	local unit_hp_pct = (unit_hp / unit:GetMaxHealth()) * 100

	-- Threshold check
	if unit_hp_pct <= kill_pct then
		local damage_table = {}

		damage_table.victim = unit
		damage_table.damage_type = DAMAGE_TYPE_PURE
		damage_table.ability = ability
		damage_table.damage = unit_hp + 1

		-- If the unit damaged itself then the kill is awarded to the caster instead
		-- of being counted as a suicide
		if attacker == unit then
			damage_table.attacker = caster
		else
			damage_table.attacker = attacker
		end

		ApplyDamage(damage_table)
	end
end

function Dropzero( keys )
    local caster = keys.caster
    local pos = caster: GetOrigin()
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_zero_time" then  --Refresher Orb does not refresh itself.
				caster: DropItemAtPositionImmediate(current_item,pos)
			end
		end
	end
end
function Dropdisaster( keys )
    local caster = keys.caster
    local pos = caster: GetOrigin()
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_disaster" then  --Refresher Orb does not refresh itself.
				caster: DropItemAtPositionImmediate(current_item,pos)
			end
		end
	end
end
function DropFryja( keys )
    local caster = keys.caster
    local pos = caster: GetOrigin()
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_Fryja" then  --Refresher Orb does not refresh itself.
				caster: DropItemAtPositionImmediate(current_item,pos)
			end
		end
	end
end
function Dropmadokamirule( keys )
    local caster = keys.caster
    local pos = caster: GetOrigin()
	for i=0, 5, 1 do
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_madokamirule" then  --Refresher Orb does not refresh itself.
				caster: DropItemAtPositionImmediate(current_item,pos)
			end
		end
	end
end