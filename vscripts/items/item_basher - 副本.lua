unction item_echo_sabre_datadriven_on_equip (event)
  local caster = event.caster
  local ability = event.ability

  if caster:HasModifier("modifier_echo_strike_buff_stored") then
    ability:ApplyDataDrivenModifier(caster,caster,"modifier_echo_sabre_datadriven_echo_strike_buff",{})
  end 
end

function modifier_echo_sabre_datadriven_on_attack_start (event)
  local caster = event.caster
  local ability = event.ability
  local cooldown = ability:GetCooldown(ability:GetLevel())

  if caster:IsRangedAttacker() then
    caster:RemoveModifierByName("modifier_echo_sabre_datadriven_echo_strike_buff") 
  end 

  if caster:HasModifier("modifier_echo_sabre_datadriven_echo_strike_buff") and ability:IsCooldownReady() then
    caster:RemoveModifierByName("modifier_echo_sabre_datadriven_echo_strike_buff") 
  end

end  

function modifier_echo_sabre_datadriven_echo_strike_on_attack_start (event)
  local caster = event.caster
  local ability = event.ability

  if not caster:IsRangedAttacker() and caster:HasModifier("modifier_echo_strike_buff_stored") then
    ability:ApplyDataDrivenModifier(caster,caster,"modifier_echo_strike_attack_speed_stored",{})
  end 
end 

function modifier_echo_sabre_datadriven_echo_strike_on_attack_landed (event)
  local caster = event.caster
  local target = event.target
  local ability = event.ability
  local cooldown = ability:GetCooldown(ability:GetLevel())
  local duration = ability:GetLevelSpecialValueFor("slow_duration",ability:GetLevel()-1)

  if not caster:IsRangedAttacker() and ability:IsCooldownReady()  then
    ability:ApplyDataDrivenModifier(caster,caster,"modifier_echo_sabre_datadriven_echo_strike_buff",{})
    ability:ApplyDataDrivenModifier(caster,caster,"modifier_echo_strike_buff_stored",{})

    if not target:IsMagicImmune() then 
      ability:ApplyDataDrivenModifier(caster,target,"modifier_echo_sabre_datadriven_echo_strike_movement_debuff",{duration=duration})
      ability:ApplyDataDrivenModifier(caster,target,"modifier_echo_sabre_datadriven_echo_strike_attack_speed_debuff",{duration=duration})
      ability:ApplyDataDrivenModifier(caster,target,"modifier_echo_sabre_datadriven_echo_strike_debuff_tooltip",{duration=duration})
    end

    ability:StartCooldown(cooldown)
  end
end

function modifier_echo_sabre_datadriven_echo_strike_on_attack_failed (event)
  local caster = event.caster
  local ability = event.ability
  local cooldown = ability:GetCooldown(ability:GetLevel())

  if not caster:IsRangedAttacker() and ability:IsCooldownReady() then
    ability:ApplyDataDrivenModifier(caster,caster,"modifier_echo_sabre_datadriven_echo_strike_buff",{})
    ability:ApplyDataDrivenModifier(caster,caster,"modifier_echo_strike_buff_stored",{})
    ability:StartCooldown(cooldown)
  end
end

function modifier_echo_sabre_datadriven_echo_strike_buff_on_attack_landed (event)
  local caster = event.caster
  local target = event.target
  local ability = event.ability
  local duration = ability:GetLevelSpecialValueFor("slow_duration",ability:GetLevel()-1)

  if not target:IsMagicImmune() then 
    ability:ApplyDataDrivenModifier(caster,target,"modifier_echo_sabre_datadriven_echo_strike_movement_debuff",{duration=duration})
    ability:ApplyDataDrivenModifier(caster,target,"modifier_echo_sabre_datadriven_echo_strike_attack_speed_debuff",{duration=duration})
    ability:ApplyDataDrivenModifier(caster,target,"modifier_echo_sabre_datadriven_echo_strike_debuff_tooltip",{duration=duration})
  end

  caster:RemoveModifierByName("modifier_echo_sabre_datadriven_echo_strike_buff") 
  caster:RemoveModifierByName("modifier_echo_strike_buff_stored")
end

function modifier_echo_sabre_datadriven_echo_strike_buff_on_attack_failed (event)
  local caster = event.caster

  caster:RemoveModifierByName("modifier_echo_sabre_datadriven_echo_strike_buff") 
  caster:RemoveModifierByName("modifier_echo_strike_buff_stored")
end  