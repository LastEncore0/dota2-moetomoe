function juanshu( event )
	-- Variables
	local caster = event.caster
	local target = event.target
	local ability = event.ability
    local juanshu = event.latch_modifier

	-- Store the ally unit
	

	if ability.juanshu == nil and not target:HasModifier( juanshu )then
		ability:ApplyDataDrivenModifier( caster, target, juanshu, {} )
		renyerenjuanshu = target
		-- Swap sub ability
	local mainAbilityName	= ability:GetAbilityName()
	local subAbilityName	= event.sub_ability_name
	caster:SwapAbilities( mainAbilityName, subAbilityName, false, true )
	end

	
end

function juanshudeath( event )
	-- Variables
	local caster = event.caster
	local target = event.target
	local ability = event.ability
    renyerenjuanshu = nil
	-- Swap sub ability
	local mainAbilityName	= ability:GetAbilityName()
	local subAbilityName	= event.sub_ability_name
	caster:SwapAbilities( mainAbilityName, subAbilityName, true, false )
end

function energysteal( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local steal = ability:GetLevelSpecialValueFor( "steal" , ability:GetLevel() - 1  )
	local stealadd = steal + ability:GetLevelSpecialValueFor( "add" , ability:GetLevel() - 1  )
	if caster:HasModifier("modifier_shinobu_talent_1") then
	local manasteal = target:GetMaxMana() * stealadd/100
	print("manasteal =",manasteal)
    target:SpendMana(manasteal, ability)
	caster:Heal(manasteal, caster)
	else
	local manasteal = target:GetMaxMana() * steal/100
	print("manasteal =",manasteal)
    target:SpendMana(manasteal, ability)
	caster:Heal(manasteal, caster)
	end
end

function energydamage( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local steal = ability:GetLevelSpecialValueFor( "energydamage" , ability:GetLevel() - 1  )
	local manasteal = target:GetMaxMana() * steal/100
	print("manasteal =",manasteal)
    target:SpendMana(manasteal, ability)
	caster:Heal(manasteal, caster)
	ApplyDamage({ victim = target, attacker = caster, damage = manasteal, damage_type = DAMAGE_TYPE_MAGICAL })
end

function energysuck( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local steal = ability:GetLevelSpecialValueFor( "energysuck" , ability:GetLevel() - 1  )
	local damage = ability:GetLevelSpecialValueFor( "damage" , ability:GetLevel() - 1  )
	local stealadd = steal + ability:GetLevelSpecialValueFor( "addsuck" , ability:GetLevel() - 1  )
	local manasteal = target:GetMaxMana() * steal/100

	if caster:HasModifier("modifier_shinobu_talent_2") then
	manasteal = target:GetMaxMana() * stealadd/100
	else
	manasteal = target:GetMaxMana() * steal/100
	end

	
if target:GetMana() <= manasteal then
		-- If it is then purge it and manually remove unpurgable modifiers
		-- target:Purge(true, true, false, false, true)

	

		--[[ Play the kill particle
		local culling_kill_particle = ParticleManager:CreateParticle(particle_kill, PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
		ParticleManager:ReleaseParticleIndex(culling_kill_particle)
]]

		-- Update the table info and apply the damage
		local damage_table = {}
 	    damage_table.victim = target
 	    damage_table.attacker = caster
 	    damage_table.ability = ability
		damage_table.damage_type = DAMAGE_TYPE_PURE
		damage_table.damage = damage
		ApplyDamage(damage_table)
        print("manasteal =",manasteal)
		-- Find the valid units in the area that should recieve the speed buff and then apply it to them
		

		-- Reset the ability cooldown if its a hero
		if not caster:HasItemInInventory("item_ethereal_blade") then
			caster:RemoveModifierByName("modifier_energy_suck")
		end				
	else
		-- If its not equal or below the threshold then play the failure sound and deal normal damage
		caster:RemoveModifierByName("modifier_energy_suck")
		target:SpendMana(manasteal, ability)
		caster:GiveMana(manasteal)
		print("Mana =",target:GetMana())
	end
end

function juanshusteal( event )
	local caster = event.caster
	local attacker = event.attacker
	local target = event.target
	local ability = event.ability
	local steal = ability:GetLevelSpecialValueFor( "steal" , ability:GetLevel() - 1  )
	local manasteal = target:GetMaxMana() * steal/100
	print("manasteal =",manasteal)
    target:SpendMana(manasteal, ability)
	attacker:Heal(manasteal, caster)
end

function HolyPersuasion( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_team = caster:GetTeamNumber()
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local model = keys.model
	local ability_level = ability:GetLevel() - 1
	local modifier_geass_zero = keys.modifier_geass_zero
	local health_cost = ability:GetLevelSpecialValueFor( "health_cost" , ability:GetLevel() - 1  )
    local health = caster:GetHealth()
    local new_health = (health - health_cost)

	 local max_units = ability:GetLevelSpecialValueFor("max_units", ability_level)
	-- Initialize the tracking data
	ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count or 0
	ability.holy_persuasion_table = ability.holy_persuasion_table or {}
    
	-- Ability variables
	caster:ModifyHealth(new_health, ability, false, 0)

	
	ability:ApplyDataDrivenModifier(caster, target, modifier_geass_zero, {})

	--print("health_bonus =",health_bonus)
	--print("max_units =",max_units)
   

print("max_units =",max_units)
print("zero_units =",zero_units)


	-- Change the ownership of the unit and restore its mana to full
	print(target:GetUnitName())
	target:SetTeam(caster_team)
	target:SetOwner(caster)
	target:SetControllableByPlayer(player, true)
	target:GiveMana(target:GetMaxMana())
	target:SetOriginalModel(model)
	-- Set the minimum health bonus as max hp if the current is lower than that

	ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count + 1
	table.insert(ability.holy_persuasion_table, target)
	if ability.holy_persuasion_unit_count > max_units then
		ability.holy_persuasion_table[1]:ForceKill(true) 
	end

	
end

function backorign( keys )

	-- orign:SetTeam(orign_team)
	orign:SetOwner(orign)
	orign:SetControllableByPlayer(orign_player, true)

	orign_player = nil
	orign_team = nil
    orign = nil

	
end

--[[Author: Pizzalol
	Date: 06.04.2015.
	Removes the target from the table]]
function HolyPersuasionRemove( keys )
	local target = keys.target
	local ability = keys.ability

	-- Find the unit and remove it from the table
	for i = 1, #ability.holy_persuasion_table do
		if ability.holy_persuasion_table[i] == target then
			table.remove(ability.holy_persuasion_table, i)
			ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count - 1
			break
		end
	end
end

--[[
    Author: jacklarnes, RcColes
    Date: 08.07.2015.

    Note: feel free to contact me with suggestions or if you're finishing it and you have questions.
    Email: christucket@gmail.com
    reddit: /u/jacklarnes, /u/RcColes

    Note: Problems may occur if used on heroes with more then 5 abilities.
]]

function infest_check_valid( keys )
    local caster = keys.caster
    local target = keys.target

    print(target:GetUnitLabel())
    print(target:GetUnitName())

    --check for validity. theres a lot of exceptions, and i'd like a better way to do this.
    --unsure of the formatting as well as it's a long list.
    local enemyexceptionlist = {"spirit_bear", "visage_familiars"}
    local enemyisexception = false
    for _,item in pairs(enemyexceptionlist) do
        if item == target:GetUnitLabel() and target:GetTeamNumber() ~= caster:GetTeamNumber() then
            enemyisexception = true
            break
        end
    end

    if target:IsHero() and target:GetTeamNumber() ~= caster:GetTeamNumber() or caster == target or target:IsCourier() or target:IsBoss() or target:IsAncient() or enemyisexception then
        caster:Hold()
    end
end

function infest_add_consume( keys )
    if not keys.caster:HasAbility("life_stealer_consume_datadriven") then
        keys.caster:AddAbility("life_stealer_consume_datadriven")
    end
end

function infest_start( keys )
    local target = keys.target
    local caster = keys.caster
    local ability = keys.ability
    if target == renyerenjuanshu then
    caster.ability = {}
    caster.ability["damage"] = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1) 
    caster.ability["range"] = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1) 

    caster.host = target
    caster.removed_spells = {}
    --add the particle
    caster.particleid = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_life_stealer/life_stealer_infested_unit_icon.vpcf", 7, target, caster:GetTeamNumber())


    -- Strong Dispel
    local RemovePositiveBuffs = false
    local RemoveDebuffs = true
    local BuffsCreatedThisFrameOnly = false
    local RemoveStuns = true
    local RemoveExceptions = false
    caster:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)

    -- Hide the hero underground
    caster:SetAbsOrigin(caster.host:GetAbsOrigin() - Vector(0, 0, 322))
    caster:SwapAbilities("into_shadow", "out_shadow", false, true) 
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_infest_hide", {})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_infest_buff", {})
    -- Remove the abilities.
    --Timers:CreateTimer(10, function() reset(keys) end)
	end
end

function infest_move_unit( keys )
    local caster = keys.caster
    --Check if the host still exists
	local ability = keys.ability
    if caster.host == nil or not caster.host:IsAlive() then -- CHANGE THIS PLEASE?
    caster:SetAbsOrigin(caster.host:GetAbsOrigin())
    caster:RemoveModifierByName("modifier_infest_hide")
    caster.host:RemoveModifierByName("modifier_infest_buff")
    caster:SwapAbilities("into_shadow", "out_shadow", true, false) 
    --return the abilities
    local into_shadow = caster:FindAbilityByName("into_shadow")
    local colddown = ability:GetLevelSpecialValueFor("colddown", ability:GetLevel() - 1) 
    into_shadow:StartCooldown( colddown )



    ParticleManager:DestroyParticle(caster.particleid, true)

    else
        caster:SetAbsOrigin(caster.host:GetAbsOrigin() - Vector(0, 0, 322))
    end
end

function infest_consume(keys)
    print(keys.caster.host:GetUnitLabel())
    print(keys.caster.host:GetUnitName())
    local caster = keys.caster
    local ability = keys.ability
	local into_shadow = caster:FindAbilityByName("into_shadow")
    local colddown = ability:GetLevelSpecialValueFor("colddown", ability:GetLevel() - 1) 
    into_shadow:StartCooldown( colddown )
    caster:SetAbsOrigin(caster.host:GetAbsOrigin())
    caster:RemoveModifierByName("modifier_infest_hide")
    caster.host:RemoveModifierByName("modifier_infest_buff")
    caster:SwapAbilities("into_shadow", "out_shadow", true, false) 
    

    local exceptionlist = {"spirit_bear", "visage_familiars"}
    local isexception = false
    for _,item in pairs(exceptionlist) do
        if item == caster.host:GetUnitLabel()  then
            isexception = true
            break
        end
    end
  
    --remove the particle
    ParticleManager:DestroyParticle(caster.particleid, true)
end

--[[
    author: jacklarnes, Pizzalol
    email: christucket@gmail.com
    reddit: /u/jacklarnes
]]
function feast_attack( keys )
    local attacker = keys.attacker
    local target = keys.target
    local ability = keys.ability

    ability.hp_leech_percent = ability:GetLevelSpecialValueFor("hp_leech_percent", ability:GetLevel() - 1)
    local feast_modifier = keys.feast_modifier 

    local damage = target:GetHealth() * (ability.hp_leech_percent / 100)

    -- this sets the number of stacks of damage
    ability:ApplyDataDrivenModifier(attacker, attacker, feast_modifier, {})
    attacker:SetModifierStackCount(feast_modifier, ability, damage)
end

function feast_heal( keys )
  local attacker = keys.attacker
  local target = keys.target
  local ability = keys.ability

  ability.hp_leech_percent = ability:GetLevelSpecialValueFor("hp_leech_percent", ability:GetLevel() - 1)
  local damage = target:GetHealth() * (ability.hp_leech_percent / 100)

  attacker:Heal(damage, ability)
end

function LevelUpAbilitykissshot( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name_1 = event.ability_name_1
	local ability_name_2 = event.ability_name_2
	local ability_handle_1 = caster:FindAbilityByName(ability_name_1)	
	local ability_handle_2 = caster:FindAbilityByName(ability_name_2)	
	local ability_level_1 = ability_handle_1:GetLevel()
	local ability_level_2 = ability_handle_2:GetLevel()
	local one = 1
	


	-- Check to not enter a level up loop
	if ability_level_1 ~= this_abilityLevel then
		ability_handle_1:SetLevel(this_abilityLevel)
	end
	if ability_level_2 ~= this_abilityLevel then
		ability_handle_2:SetLevel(this_abilityLevel)
	end
end

function applybody( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    local modifier_body_change = caster:FindAbilityByName("modifier_body_change")
	-- Store the ally unit
	if target == renyerenjuanshu then
		-- Saves the original model and attack capability
		print("renyerenjuanshu =",renyerenjuanshu)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_body_change", {})
	else
	print("target =",target)
	end
end

function Changebody( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    local model = keys.model

	-- Store the ally unit
	
		-- Saves the original model and attack capability
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end
    local modifier_energysteal = caster:FindAbilityByName("modifier_energysteal")
	local modifier_blood_kiss = caster:FindAbilityByName("modifier_blood_kiss")
	-- Sets the new model and projectile
	caster:SetOriginalModel(model)

    caster:SwapAbilities("blood_kiss", "energysteal", true, false)
	caster:SwapAbilities("duopo", "into_shadow", true, false)
	caster:SwapAbilities("reheal", "renyeren_empty", true, false)

	caster:SwapAbilities("small_change", "body_change", true, false) 
	
end

function smallbody( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- Store the ally unit

    caster:SwapAbilities("blood_kiss", "energysteal", false, true) 
	caster:SwapAbilities("duopo", "into_shadow", false, true) 
	caster:SwapAbilities("reheal", "renyeren_empty", false, true) 
    caster:SetModel(caster.caster_model)
	caster:SetOriginalModel(caster.caster_model)
	caster:SwapAbilities("small_change", "body_change", false, true) 
end