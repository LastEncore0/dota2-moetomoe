--global
function Endcooldown( keys )
	local caster = keys.caster
	local ability = keys.ability

	ability:EndCooldown()
end
function InitWayPoints()
    WAY_POINTS={}
    BUILDING_FOUNTAIN_GOOD = Entities:FindByName(nil,"judian1")
    BUILDING_FOUNTAIN_BAD = Entities:FindByName(nil,"judian2")
    for i=1,6 do
        WAY_POINTS[i]={}
        local tbl = WAY_POINTS[i]
        if i<4 then
            tbl[0]=BUILDING_FOUNTAIN_GOOD:GetAbsOrigin()
        else
            tbl[0]=BUILDING_FOUNTAIN_BAD:GetAbsOrigin()
        end
    end
    --[[
    for way=1,6 do
        if way==1 then
            way_name="good_top"
        elseif way==2 then
            way_name="good_mid"
        elseif way==3 then
            way_name="good_bot"
        elseif way==4 then
            way_name="bad_top"
        elseif way==5 then
            way_name="bad_mid"
        elseif way==6 then
            way_name="bad_bot"
        end
        local tbl = WAY_POINTS[way]
        ent = Entities:FindByName(nil,"spawner_"..way_name)
        tbl[1]=ent:GetAbsOrigin()
        for i=1,6 do
            local name = way_name.."_"..tostring(i)
            ent = Entities:FindByName(nil,name)
            tbl[i+1]=ent:GetAbsOrigin()
        end
        if way==2 then
            ent = Entities:FindByName(nil,"good_mid_7")
            tbl[8]=ent:GetAbsOrigin()
            ent = Entities:FindByName(nil,"good_mid_8")
            tbl[9]=ent:GetAbsOrigin()
        elseif way==5 then
            ent = Entities:FindByName(nil,"bad_mid_7")
            tbl[8]=ent:GetAbsOrigin()
            ent = Entities:FindByName(nil,"bad_mid_8")
            tbl[9]=ent:GetAbsOrigin()
        elseif way==1 or way==3 then
            ent = Entities:FindByName(nil,"good_mid_8")
            tbl[8]=ent:GetAbsOrigin()
        elseif way==4 or way==6 then
            ent = Entities:FindByName(nil,"bad_mid_8")
            tbl[8]=ent:GetAbsOrigin()
        end
    end
    ]]
end
function InitConst() 
    tWaveStart = 9999
    AI_THINK_INTERVAL = 0.5
    AI_STATE_IDLE = 0 --only move
    AI_STATE_ATTACK = 1 --attack and move
    AI_STATE_RETREAT = 2 --retreat
    AI_STG_PUSH = 0
    AI_STG_GANK = 1
    AI_STG_LINE_GANK = 2
    AI_STG_JUNGLE = 3
    AI_STG_FOLLOW = 4
    AI_ORDER_MOVE = 0
    AI_ORDER_MOVE_ATTACK = 1
    AI_ORDER_ATTACK = 2
    AI_ORDER_CAST = 3
    DUMMY_A = nil
    --DUMMY_A.WEATHER_CURRENT = nil
    InitWayPoints()
    RegStunTable()
end
function InitUnitResist(unit)   
    if unit:IsIllusion() then
        local id = unit:GetPlayerID()
        local player = PlayerResource:GetPlayer(id)
        if player then
            local hero=player:GetAssignedHero()
            if hero then
                unit.fireResist = hero.fireResist
                unit.iceResist = hero.iceResist
                unit.lightningResist = hero.lightningResist
                unit.poisonResist = hero.poisonResist
                unit.arcaneResist = hero.arcaneResist
            end
        end
    else
        unit.fireResist = 0
        unit.iceResist = 0
        unit.lightningResist = 0
        unit.poisonResist = 0
        unit.arcaneResist = 0
        --print(unit:GetUnitName())
    end
end
function RegStunTable()
    --不可净化，但是一些技能可以移除的眩晕（不包括冻结，冻结可以净化）
    TBL_STUN = {
        [1]="modifier_unclebug_charge_stun",
        [2]="modifier_unclebug_chain_stun",
        [3]="modifier_warhol_shout_medusa_stun",
        [4]="modifier_dragon_dragonball_stun",
        [5]="modifier_brew_element_debuff",
        [6]="modifier_soulloli_bonespirit_stun",
        [7]="modifier_basesoil_balloon_medusa",
        --[8]="modifier_creep_zaka_web", --网
        [8]="modifier_creep_tree_stomp_debuff",
        [9]="modifier_creep_hammer_stun_debuff",
        [10]="modifier_item_gravity_stun_effect",
        [11]="modifier_fortytwo_dizzy_stun",
        [12]="modifier_fortytwo_dunk_stun",
        [13]="modifier_lyn_arrow_stun",
        [14]="modifier_vipermagi_inte_stun",
        [15]="modifier_item_daybreak_stun",
        [16]="modifier_remilia_chain_stun",
        [17]="modifier_natalya_flying_stun",
        [18]="modifier_ava_bomb_stun",
        [19]="modifier_pipi_ring_stun",
        [20]="modifier_suika_miss_stun",
        [21]="modifier_suika_throw_stun",
        [22]="modifier_marsace_burning_stun"
    }
end

function RemoveStun(u)
    if IsValidEntity(u) and u:IsAlive() then
        for _,v in pairs(TBL_STUN) do
            if u:HasModifier(v) then
                u:RemoveModifierByName(v)
            end
        end
    end
end
function HasStunBuff(u) --仅眩晕，不包括冻结，若要包括冻结使用IsStunned
    if IsValidEntity(u) and u:IsAlive() then
        for _,v in pairs(TBL_STUN) do
            if u:HasModifier(v) then
                return true
            end
        end
    end
    return false
end

function IsInTable(val,tbl)
    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end
function CountTable(tbl)
    local c = 0
    for k,v in pairs(tbl) do
        c = c + 1
    end
    return c
end
function TableRemoveWithKey(tbl,val)
    for k,v in pairs(tbl) do
        if v == val then
            tbl[k]=nil
        end
    end
end
--[[
function PrintTable(tbl)
    print("{")
    for k,v in pairs(tbl) do
        print(k,v)
    end
    print("}")
end
]]
function GetVectorsCos(v1,v2)
    return v1:Dot(v2)/(v1:Length()*v2:Length())
end

function PointTwo(decimal)
    decimal = decimal * 100
    if decimal % 1 >= 0.5 then  
        decimal=math.ceil(decimal)
    else
        decimal=math.floor(decimal)
    end
    return  decimal * 0.01
end

function GetModifierStat(unit, name, str)
    local modifier = unit:FindModifierByName(name)
    if modifier then
        local ability = modifier:GetAbility()
        if ability then
            local level = ability:GetLevel()-1
            local v = ability:GetLevelSpecialValueFor(str, level)
            return v
        end
    end
    return 0
end

function CalMayDamage(attacker,target)
    local a = target:GetPhysicalArmorValue()
    return attacker:GetAverageTrueAttackDamage(nil)*(1-6*a/(100+6*a))
end

function IsDummy(u)
    if u:HasAbility("dummy_passive") then
        return true
    else
        return false
    end
end
function IsBarrage(u)
    if u:HasAbility("dummy_barrage") then
        return true
    else
        return false
    end
end
function IsValidUnit(u)
    if not IsValidEntity(u) or u:HasAbility("dummy_barrage") or u:HasAbility("dummy_passive") then
        return false
    else
        return true
    end
end
function IsSpecialUnit(u)
    local name = u:GetUnitName()
    if name=="npc_dota_creep_neutral_mephisto" then
        return true
    end
    return false
end
function IsSummonedUnit(u)
    local name = u:GetUnitName()
    if name=="npc_skill_brew_element_fire" or name=="npc_skill_brew_element_wind" or name=="npc_skill_brew_element_earth" then
        return true
    elseif name=="npc_skill_ma_knight" then
        return true
    elseif name=="npc_skill_lyn_treant" then
        return true
    elseif name=="npc_skill_lyn_ancient_treant" then
        return true
    elseif name=="npc_skill_sushi_dryad" then
        return true
    end
    return false
end
function IsBuildingTower(u)
    if u:IsBuilding() and u:GetBaseDamageMin()>0 then
        return true
    end
    return false
end
function IsBuildingBarrack(u)
    if u:IsBuilding() then
        local name = u:GetUnitName()
        if name=="npc_earth_barrack" or name=="npc_mars_barrack" then
            return true
        end
    end
    return false
end
--[[
function IsMale(hero)
    local name = hero:GetUnitName()
    if name=="npc_dota_hero_drow_ranger" then
        return false
    elseif name=="npc_dota_hero_crystal_maiden" then
        return false
    elseif name=="npc_dota_hero_vengefulspirit" then
        return false
    elseif name=="npc_dota_hero_windrunner" then
        return false
    elseif name=="npc_dota_hero_nevermore" then
        return false
    elseif name=="npc_dota_hero_queenofpain" then
        return false
    elseif name=="npc_dota_hero_templar_assassin" and not hero:HasModifier("modifier_natalya_male") then
        return false
    elseif name=="npc_dota_hero_shadow_shaman" then
        return false
    elseif name=="npc_dota_hero_silencer" then
        return false
    elseif name=="npc_dota_hero_enchantress" then
        return false
    elseif name=="npc_dota_hero_magnataur" then
        return false
    elseif name=="npc_dota_hero_ancient_apparition" then
        return false
    end
    return true
end
]]

function SetWaveStartTime()
    tWaveStart=GameRules:GetGameTime()
end
function GameTime()
    return GameRules:GetGameTime()-tWaveStart
end

function IsNearFountain(hero,range)
    if hero:GetTeamNumber()==DOTA_TEAM_GOODGUYS then
        local dist = (hero:GetAbsOrigin()-BUILDING_FOUNTAIN_GOOD:GetAbsOrigin()):Length2D()
        if dist<range then
            return true
        end
    end
    if hero:GetTeamNumber()==DOTA_TEAM_BADGUYS then
        local dist = (hero:GetAbsOrigin()-BUILDING_FOUNTAIN_BAD:GetAbsOrigin()):Length2D()
        if dist<range then
            return true
        end
    end
    return false
end
function GetFountain(hero)
     local good = Entities:FindByName(nil,"fountaingood")
     local bad  = Entities:FindByName(nil,"fountainbad")
    if hero:GetTeamNumber()==DOTA_TEAM_GOODGUYS then
        return good
    end
    if hero:GetTeamNumber()==DOTA_TEAM_BADGUYS then
        return bad
    end
    return nil
end
function GetEnemyFountain(hero)
    if hero:GetTeamNumber()==DOTA_TEAM_GOODGUYS then
        return BUILDING_FOUNTAIN_BAD
    end
    if hero:GetTeamNumber()==DOTA_TEAM_BADGUYS then
        return BUILDING_FOUNTAIN_GOOD
    end
    return nil
end
function GetUnitID(u)
    if u:IsHero() then
        id = u:GetPlayerID()   
    else
        id = u:GetPlayerOwnerID()
    end
end
function GetAnEnemyHero(u)
    local heroes = HeroList:GetAllHeroes()
    for _,hero in pairs(heroes) do
        if hero and hero:IsAlive() and hero:GetTeamNumber()~=u:GetTeamNumber() then
            return hero
        end
    end
    return nil
end

function GetMayDamage(attacker,target)
    if IsValidUnit(attacker) and IsValidUnit(target) then
        local a = target:GetPhysicalArmorValue()
        local mayDamage = attacker:GetAverageTrueAttackDamage(nil)*(1-6*a/(100+6*a))
        return mayDamage
    end
    return 0
end




function CountEnemiesNearPoint(pOrg, range, unit, includeHero, includeBuilding) --unit的enemy
    local c = 0
    local units = FindUnitsInRadius(unit:GetTeam(), pOrg, nil,range, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
    if #units > 0 then
        for _,enemy in pairs(units) do
            if enemy ~= nil and IsValidUnit(enemy) and enemy:IsAlive() then
                if enemy:IsRealHero() then
                    if includeHero then
                        c=c+1
                    end
                elseif enemy:IsBuilding() then
                    if includeBuilding then
                        c=c+1
                    end
                else
                    c=c+1
                end
            end
        end
    end
    return c
end
function CountAlliesNearPoint(pOrg, range, unit, includeHero, includeBuilding) --unit的ally，包括自己
    local c = 0
    local units = FindUnitsInRadius(unit:GetTeam(), pOrg, nil,range, DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
    if #units > 0 then
        for _,ally in pairs(units) do
            if ally ~= nil and IsValidUnit(ally) and ally:IsAlive() then
                if ally:IsRealHero() then
                    if includeHero then
                        c=c+1
                    end
                elseif ally:IsBuilding() then
                    if includeBuilding then
                        c=c+1
                    end
                else
                    c=c+1
                end
            end
        end
    end
    return c
end
function GetNearestEnemyNearPoint(pOrg, range, unit, includeHero, includeBuilding) --unit的enemy
    local upick = nil
    local units = FindUnitsInRadius(unit:GetTeam(), pOrg, nil,range, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
    if #units > 0 then
        for _,enemy in pairs(units) do
            if enemy ~= nil and IsValidUnit(enemy) and enemy:IsAlive() then
                if enemy:IsRealHero() then
                    if includeHero then
                        upick = enemy
                        break
                    end
                elseif enemy:IsBuilding() then
                    if includeBuilding then
                        upick = enemy
                        break
                    end
                else
                    upick = enemy
                    break
                end
            end
        end
    end
    return upick
end
function GetNearestEnemyNearPoint_HeroFirst(pOrg, range, unit, includeBuilding) --unit的enemy
    local upick = nil
    local upickH = nil
    local units = FindUnitsInRadius(unit:GetTeam(), pOrg, nil,range, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
    if #units > 0 then
        for _,enemy in pairs(units) do
            if enemy ~= nil and IsValidUnit(enemy) and enemy:IsAlive() then
                if enemy:IsRealHero() then
                    upickH = enemy
                    break
                elseif enemy:IsBuilding() then
                    if includeBuilding then
                        if upick==nil then
                            upick = enemy
                        end
                    end
                else
                    if upick==nil then
                        upick = enemy
                    end
                end
            end
        end
    end
    if upickH~=nil then
        upick = upickH
    end
    return upick
end
function GetNearestAllyNearPoint(pOrg, range, unit, includeHero, includeBuilding) --unit的ally
    local upick = nil
    local units = FindUnitsInRadius(unit:GetTeam(), pOrg, nil,range, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
    if #units > 0 then
        for _,ally in pairs(units) do
            if ally ~= nil and IsValidUnit(ally) and ally:IsAlive() and ally~=unit then
                if ally:IsRealHero() then
                    if includeHero then
                        upick = ally
                        break
                    end
                elseif ally:IsBuilding() then
                    if includeBuilding then
                        upick = ally
                        break
                    end
                else
                    upick = ally
                    break
                end
            end
        end
    end
    return upick
end
function GetStrongAllyHeroNearPoint(pOrg, range, unit) --unit的ally
    local upick = nil
    local gold = 0
    local max = 0
    local units = FindUnitsInRadius(unit:GetTeam(), pOrg, nil,range, DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
    if #units > 0 then
        for _,ally in pairs(units) do
            if ally ~= nil and IsValidUnit(ally) and ally:IsAlive() then
                if ally:IsRealHero() then
                    local i = ally:GetPlayerID()
                    gold = PlayerResource:GetGoldPerMin(i)
                    if gold>max then
                        max = gold
                        upick = ally
                    end
                end
            end
        end
    end
    return upick
end



function AddGoldShow(target,v,p)
    local digits = string.len( math.floor( v ) ) + 1
    local pct = ParticleManager:CreateParticleForPlayer( "particles/msg_fx/msg_gold.vpcf", PATTACH_OVERHEAD_FOLLOW, target, p) 
    ParticleManager:SetParticleControl( pct, 1, Vector( 10, v, 0 ) )
    ParticleManager:SetParticleControl( pct, 2, Vector( 2.0, digits, 0 ) )
    ParticleManager:SetParticleControl( pct, 3, Vector( 255, 200, 33 ) )
end
function AddGoldTeam(iTeam,gold,reliable,reason)
    for i=0,9 do
        local p = PlayerResource:GetPlayer(i)
        if p then
            if PlayerResource:GetTeam(i) == iTeam then
                PlayerResource:ModifyGold(i,gold,reliable,reason)
                local hero = p:GetAssignedHero()
                if hero and hero:IsAlive() then
                    AddGoldShow(hero,gold,p)
                end
            end
        end
    end
end

function ReduceCD(caster,ability,v)
    if not ability:IsCooldownReady() then
        local cd = ability:GetCooldownTimeRemaining()
        cd=cd-v
        ability:EndCooldown() 
        if cd>0 then
            ability:StartCooldown(cd) 
        end
    end
end

function FindItemOnUnit(u,name)
    local it = nil
    local itPick = nil
    for i=0,5 do
        it=u:GetItemInSlot(i)
        if it~=nil then
            if it:GetAbilityName()==name then
                itPick = it
                break
            end
        end
    end
    return itPick
end
--[[
function InitUnit(u) --including barrages
    local hero
    local name=u:GetUnitName()
    --特殊单位属性------------------------------
    if name=="npc_skill_brew_element_fire" or name=="npc_skill_brew_element_wind" or name=="npc_skill_brew_element_earth" then
        u.fireResist = 0
        u.iceResist = 0
        u.lightningResist = 0
        u.poisonResist = 0
        u.arcaneResist = 0
        u.magicEnchant=0
        u.fireEnchant=0
        u.iceEnchant=0
        u.lightningEnchant=0
        u.poisonEnchant=0
        u.arcaneEnchant=0
        return
    end
    --一般单位属性------------------------------
    if u:IsNeutralUnitType() then
        u.fireResist = 0
        u.iceResist = 0
        u.lightningResist = 0
        u.poisonResist = 0
        u.arcaneResist = 0
        u.magicEnchant=0
        u.fireEnchant=0
        u.iceEnchant=0
        u.lightningEnchant=0
        u.poisonEnchant=0
        u.arcaneEnchant=0
    elseif IsBarrage(u) then
        local uc = u.bCredit
        u.magicEnchant=uc.magicEnchant
        u.fireEnchant=uc.fireEnchant
        u.iceEnchant=uc.iceEnchant
        u.lightningEnchant=uc.lightningEnchant
        u.poisonEnchant=uc.poisonEnchant
        u.arcaneEnchant=uc.arcaneEnchant
    else
        if u:IsIllusion() then
            local id = u:GetPlayerID()
            local player = PlayerResource:GetPlayer(id)
            hero=player:GetAssignedHero()
        else
            hero=caster:GetPlayerOwner():GetAssignedHero()
        end
        u.fireResist = hero.fireResist
        u.iceResist = hero.iceResist
        u.lightningResist = hero.lightningResist
        u.poisonResist = hero.poisonResist
        u.arcaneResist = hero.arcaneResist
        u.magicEnchant=hero.magicEnchant
        u.fireEnchant=hero.fireEnchant
        u.iceEnchant=hero.iceEnchant
        u.lightningEnchant=hero.lightningEnchant
        u.poisonEnchant=hero.poisonEnchant
        u.arcaneEnchant=hero.arcaneEnchant
    end
end]]

function MagicShieldCD(u,ability)
    local name = u:GetUnitName().."_magicShieldTimer"
    local t = u.magicShieldTimer
    if t~=nil then
        Timers:RemoveTimer(name)
    end
    if ability and IsValidEntity(u) then
        local itname = ability:GetAbilityName()
        if itname=="item_metalgrid" then
            u.magicShieldTimer=Timers:CreateTimer(name,{
                endTime = 30,
                callback = function()
                    if IsValidEntity(u) then
                        if not u:HasModifier("modifier_item_metalgrid_shield") and u:HasItemInInventory("item_metalgrid") then
                            ability:ApplyDataDrivenModifier(u,u,"modifier_item_metalgrid_shield",nil)
                        end
                    end
                    return 30.0
                end
            })
        elseif itname=="item_mara" then
            u.magicShieldTimer=Timers:CreateTimer(name,{
                endTime = 30,
                callback = function()
                    if IsValidEntity(u) then
                        if not u:HasModifier("modifier_item_mara_shield") and u:HasItemInInventory("item_mara") then
                            ability:ApplyDataDrivenModifier(u,u,"modifier_item_mara_shield",nil)
                        end
                    end
                    return 30.0
                end
            })
        end
    end
end

function GetMangSongEnchant(u)
    local it = FindItemOnUnit(u,"item_mangsong")
    if it~=nil then
        return 0.1+it:GetLevel()*0.05
    else
        return 0
    end
end

function GetChestArmorDam(caster,target,dam)
    if caster and target then
        local v1 = caster:GetAbsOrigin()-target:GetAbsOrigin()
        local v2 = target:GetForwardVector()
        local cos = v1:Dot(v2)/(v1:Length()*v2:Length())
        if cos>0.5 then --夹角小于60度
            dam=dam*0.85
        end
    end
    return dam
end

function GetTriangleDam(target,dam)
    if target then
        local rnd = RandomFloat(0,1)
        local hero = target
        if not target:IsHero() then
            hero = target:GetPlayerOwner():GetAssignedHero()
        end
        if target:HasModifier("modifier_item_triangle_defend") then 
            if rnd<0.8 then
                dam=dam-hero:GetLevel()*4-25 
            end
        else
            if rnd<0.3 then
                dam=dam-hero:GetLevel()*4-25 
            end
        end
    end
    return dam
end

function GetEnchant(caster,target,damType)
    local hero = nil
    local id = nil
    local player = nil
    if caster:IsHero() then
        id = caster:GetPlayerID()   
    else
        id = caster:GetPlayerOwnerID()
    end
    if id>=0 then
        player = PlayerResource:GetPlayer(id) 
        if player then
            hero=player:GetAssignedHero()
        end
    end
    if hero==nil then
        return 0
    end
    --[[
    if caster:IsIllusion() then
        local id = caster:GetPlayerID()
        local player = PlayerResource:GetPlayer(id)
        hero=player:GetAssignedHero()
    else
        hero = caster:GetPlayerOwner():GetAssignedHero()
    end]]
    local e = 0
    if damType>0 and damType<6 then
        if hero.magicEnchant==nil then
            hero.magicEnchant=0
        end
        hero.magicEnchant_item=hero.magicEnchant_item or 0
        e=hero.magicEnchant+hero.magicEnchant_item
        if damType==1 then 
            hero.fireEnchant=hero.fireEnchant or 0
            hero.fireEnchant_item=hero.fireEnchant_item or 0
            e=e+hero.fireEnchant+hero.fireEnchant_item
            if DUMMY_A then
                if DUMMY_A.WEATHER_CURRENT==6 then --柠檬天
                    e=e+0.1
                end
            end
            if hero:HasModifier("modifier_natalya_cobra_dreamhand") then --眼镜蛇攻击
                e=e+0.1
            end
            if hero:HasModifier("modifier_eruru_eat_fire") then --吃人鸟
                e=e+GetModifierStat(hero,"modifier_eruru_eat_fire","fire")/100
            end
        elseif damType==2 then
            hero.iceEnchant=hero.iceEnchant or 0
            hero.iceEnchant_item=hero.iceEnchant_item or 0
            e=e+hero.iceEnchant+hero.iceEnchant_item
            --丧钟 马拉的万花筒
            if hero:HasModifier("modifier_toll_thresher_mara") then
                e=e+0.15
            end
            if DUMMY_A then
                if DUMMY_A.WEATHER_CURRENT==3 then --雪
                    e=e+0.1
                end
            end
            if hero:HasModifier("modifier_natalya_cobra_dreamhand") then --眼镜蛇攻击
                e=e+0.1
            end
        elseif damType==3 then
            hero.lightningEnchant=hero.lightningEnchant or 0
            hero.lightningEnchant_item=hero.lightningEnchant_item or 0
            e=e+hero.lightningEnchant+hero.lightningEnchant_item
            if DUMMY_A then
                if DUMMY_A.WEATHER_CURRENT==2 then --闪电
                    e=e+0.1
                end
            end
            --星尘光环
            if hero:HasModifier("modifier_stardust_aura_action") then
                e=e+GetModifierStat(hero,"modifier_stardust_aura_action","lightningenhance")/100
            end
            if hero:HasModifier("modifier_natalya_cobra_dreamhand") then --眼镜蛇攻击
                e=e+0.1
            end
            if hero:HasModifier("modifier_windbunny_swift_buff") then --扑哧风
                if hero:HasItemInInventory("item_dreamhand") then
                    local c = hero:GetModifierStackCount("modifier_windbunny_swift_buff", nil)
                    e=e+c*0.02
                end
            end
        elseif damType==4 then
            hero.poisonEnchant=hero.poisonEnchant or 0
            hero.poisonEnchant_item=hero.poisonEnchant_item or 0
            e=e+hero.poisonEnchant+hero.poisonEnchant_item
            if DUMMY_A then
                if DUMMY_A.WEATHER_CURRENT==7 then --雾
                    e=e+0.1
                end
            end
            if hero:HasModifier("modifier_natalya_cobra_dreamhand") then --眼镜蛇攻击
                e=e+0.1
            end
        elseif damType==5 then
            hero.arcaneEnchant=hero.arcaneEnchant or 0
            hero.arcaneEnchant_item=hero.arcaneEnchant_item or 0
            e=e+hero.arcaneEnchant+hero.arcaneEnchant_item
            if DUMMY_A then
                if DUMMY_A.WEATHER_CURRENT==4 then --极光
                    e=e+0.1
                end
            end
        end
        --其他buff
        if hero:HasItemInInventory("item_mangsong") then
            e=e+GetMangSongEnchant(hero)
        end
        if hero:HasModifier("modifier_warhol_shout_debuff") then
            e=e+GetModifierStat(hero,"modifier_warhol_shout_debuff","magicreduce")/100
        end
        if hero:HasModifier("modifier_item_talisman_buff") then
            e=e+0.1
        end
        if hero:HasModifier("modifier_item_rune_magic") then
            e = e + 0.2
        end
        if hero:HasModifier("modifier_brew_strike_crown") and damType==1 then
            e=e+0.25
        end
        if hero:HasModifier("modifier_priest_inner") then
            e=e+GetModifierStat(hero,"modifier_priest_inner","enchant")/100
        end
        if hero:HasModifier("modifier_natalya_female") then
            e=e+GetModifierStat(hero,"modifier_natalya_female","female_enhance")/100
        end
    elseif damType==0 then
        if DUMMY_A then
            if DUMMY_A.WEATHER_CURRENT==5 then --风
                e=e+0.1
            end
        end
    end
    return e
end

function GetEvade(uu,us)
    local it = nil
    local name = nil
    local noEvade = 1
    if uu:HasInventory() then
        for i=0,5 do
            it=uu:GetItemInSlot(i)
            if it~=nil then
                name=it:GetAbilityName()
                if name=="item_fishcloth" then
                    noEvade=noEvade*0.85
                elseif name=="item_moonwatch" then
                    noEvade=noEvade*0.75
                elseif name=="item_waterwalk" then
                    if uu:IsStunned() or uu:IsRooted() then
                        noEvade=noEvade*0.5
                    else
                        noEvade=noEvade*0.85
                    end
                end
            end
        end
    end
    if uu:HasModifier("modifier_brew_drunk_evade") then
        local ab = uu:FindAbilityByName("brew_drunk")
        noEvade=noEvade*(1-ab:GetLevelSpecialValueFor("evade",ab:GetLevel()-1)/100)
    end
    if uu:HasModifier("modifier_joy_talent_4") then --祈乙天赋
        noEvade=noEvade*0.85
    end
    if uu:HasModifier("modifier_natalya_male") then --娜塔亚男性
        local ab = uu:FindAbilityByName("natalya_male")
        noEvade=noEvade*(1-ab:GetLevelSpecialValueFor("male_evade",ab:GetLevel()-1)/100)
    end
    if uu:HasModifier("modifier_lazarus_speed") then --拉撒罗斯之螺旋
        noEvade=noEvade*(1-GetModifierStat(uu,"modifier_lazarus_speed","evade")/100)
    elseif  uu:HasModifier("modifier_lazarus_speed_cateye") then
        noEvade=noEvade*(1-GetModifierStat(uu,"modifier_lazarus_speed_cateye","evade")/100)
    end
    if uu:HasModifier("modifier_lazarus_speed_shadow") then --拉撒罗斯之螺旋 影分身
        noEvade=noEvade*0.75
    end
    if uu:HasModifier("modifier_item_blackblade_evade") then
        noEvade=noEvade+0.25
    end
    
    noEvade=math.max(0.5,noEvade)
    --不受闪避上限影响的buff

    noEvade=math.min(noEvade,1)
    return 1-noEvade
end

function SkillEnchant(caster,target,damType,damage)
    local e = 0
    --根据魔法类型技能强化
    if not caster:IsNeutralUnitType() and caster:GetTeamNumber()~=DOTA_TEAM_NEUTRALS then
        e=GetEnchant(caster,target,damType) 
    end
    --其它伤害加成，不限魔法类型
    local name = caster:GetUnitName()
    if name=="npc_dota_hero_crystal_maiden" then
        if caster:HasItemInInventory("item_redmagic") and target:HasModifier("modifier_michelle_march_debuff") then
            e=e+0.15
        end
    end
    return damage*(1+e)
end

function GetResist(caster,target,damType,damage)
    local resist = 0
    if damType==1 and target.fireResist then
        resist = target.fireResist
        if target:HasModifier("modifier_ma_carriage_debuff_shako") then
            resist = resist - 0.2
        end
        if target:HasModifier("modifier_priest_aura_action") then
            resist=resist+GetModifierStat(target,"modifier_priest_aura_action","resist")/100
        end
        if target:HasModifier("modifier_char_beam_triangle") then
            local sta = target:GetModifierStackCount("modifier_char_beam_triangle", nil)
            if sta then
                resist=resist+sta*0.08
            end
        end
        if target:HasModifier("modifier_natalya_fade") then
            resist=resist+GetModifierStat(target,"modifier_natalya_fade","resist")/100
        end
        if target:HasModifier("modifier_ava_sea_mara") then
            resist=resist+0.15
        end
        if target:HasModifier("modifier_ava_sea_mara_enemy") then
            resist=resist-0.15
        end
        if target:HasModifier("modifier_suika_mist_debuff") then
            resist=resist+GetModifierStat(target,"modifier_suika_mist_debuff","resist")/100
        end
        if target:HasModifier("modifier_suika_mist_leviathan_debuff") then
            resist=resist-0.04
        end
        if target:HasModifier("modifier_marsace_flame_buff") then
            resist=resist+GetModifierStat(target,"modifier_marsace_flame_buff","resist_enhance")/100
        end
        if target:HasModifier("modifier_marsace_flame_debuff") then
            resist=resist-GetModifierStat(target,"modifier_marsace_flame_debuff","resist_reduce")/100
            --local unit = target:FindModifierByName("modifier_marsace_flame_debuff"):GetCaster()
            --if unit and unit:HasModifier("modifier_marsace_talent_6") then
                --resist=resist-0.05
            --end
        end
    elseif damType==2 and target.iceResist then
        resist = target.iceResist
        if target:HasModifier("modifier_moran_momo_winterring") then
            resist = resist - 0.2
        end
        if target:HasModifier("modifier_moran_tease_winterring") then
            resist = resist - 0.08
        end
        if target:HasModifier("modifier_ding_steal_mara") then
            resist = resist - 0.1
        end
        if target:HasModifier("modifier_ding_theory_talent") then --天赋5
            resist = resist - 0.25
        end
        if target:HasModifier("modifier_priest_aura_action") then
            resist=resist+GetModifierStat(target,"modifier_priest_aura_action","resist")/100
        end
        if target:HasModifier("modifier_char_beam_triangle") then
            local sta = target:GetModifierStackCount("modifier_char_beam_triangle", nil)
            if sta then
                resist=resist+sta*0.08
            end
        end
        if target:HasModifier("modifier_natalya_fade") then
            resist=resist+GetModifierStat(target,"modifier_natalya_fade","resist")/100
        end
        if target:HasModifier("modifier_ava_sea_mara") then
            resist=resist+0.15
        end
        if target:HasModifier("modifier_ava_sea_mara_enemy") then
            resist=resist-0.15
        end
        if target:HasModifier("modifier_marsace_flame_buff") then
            resist=resist+GetModifierStat(target,"modifier_marsace_flame_buff","resist_enhance")/100
        end
        if target:HasModifier("modifier_mashiro_bird_talent_7") then
            resist=resist-0.25
        end
    elseif damType==3 and target.lightningResist then
        resist = target.lightningResist
        if target:HasModifier("modifier_priest_aura_action") then
            resist=resist+GetModifierStat(target,"modifier_priest_aura_action","resist")/100
        end
        if target:HasModifier("modifier_char_beam_triangle") then
            local sta = target:GetModifierStackCount("modifier_char_beam_triangle", nil)
            if sta then
                resist=resist+sta*0.08
            end
        end
        if target:HasModifier("modifier_natalya_fade") then
            resist=resist+GetModifierStat(target,"modifier_natalya_fade","resist")/100
        end
        if target:HasModifier("modifier_ava_sea_mara") then
            resist=resist+0.15
        end
        if target:HasModifier("modifier_ava_sea_mara_enemy") then
            resist=resist-0.15
        end
        if target:HasModifier("modifier_windbunny_walk_talent8") then
            resist=resist-0.2
        end
        if target:HasModifier("modifier_lazarus_swirl_action") then 
            resist=resist+GetModifierStat(target,"modifier_lazarus_swirl_action","resist")/100
        end
    elseif damType==4 and target.poisonResist then
        resist = target.poisonResist
        if target:HasModifier("modifier_vipermagi_tomb_cloud_rose_resist") then
            local sta = target:GetModifierStackCount("modifier_vipermagi_tomb_cloud_rose_resist", nil)
            if sta then
                resist=resist-sta*0.05
            end
        end
        if target:HasModifier("modifier_natalya_fade") then
            resist=resist+GetModifierStat(target,"modifier_natalya_fade","resist")/100
        end
        if target:HasModifier("modifier_ava_sea_mara") then
            resist=resist+0.15
        end
        if target:HasModifier("modifier_ava_sea_mara_enemy") then
            resist=resist-0.15
        end
    elseif damType==5 and target.arcaneResist then
        resist = target.arcaneResist
        if target:HasModifier("modifier_lyn_flare_harmony") then
            resist = resist - 0.2
        end
        if target:HasModifier("modifier_reisen_red_mara") then
            resist = resist - 0.1
        end
        if target:HasModifier("modifier_pipi_look_mara") then
            resist = resist - 0.15
        end
    end
    return resist
end
function SkillResist(caster,target,damType,damage)
    local dam = damage
    local resist = 0
    --[[
    local hero = nil
    if caster:IsIllusion() then
        local id = caster:GetPlayerID()
        local player = PlayerResource:GetPlayer(id)
        hero=player:GetAssignedHero()
    else
        hero = caster:GetPlayerOwner():GetAssignedHero()
    end]]
    --按伤害类型--------------------------------------------------------
    if damType>0 and damType<6 then --魔法伤害抵抗
        if target:HasModifier("modifier_item_metalgrid_shield") then
            target:RemoveModifierByName("modifier_item_metalgrid_shield")
            MagicShieldCD(target,FindItemOnUnit(target,"item_metalgrid"))
            dam=dam-100
        end
        if target:HasModifier("modifier_item_mara_shield") then
            target:RemoveModifierByName("modifier_item_mara_shield")
            MagicShieldCD(target,FindItemOnUnit(target,"item_mara"))
            dam=dam-200
        end
        --------------------------计算抵抗--------------------------
        resist = GetResist(caster,target,damType,damage)
        dam=dam*(1-resist)
    elseif damType==0 then --物理伤害抵抗
        
    end
    --所有伤害类型-----------------------------------------------------
    if target:HasInventory() then
        if target:HasItemInInventory("item_chest") then --铁质护胸
            dam = GetChestArmorDam(caster,target,dam)
        end
        if target:HasItemInInventory("item_chest") then --赫拉迪克三角形
            dam = GetTriangleDam(target,dam)
        end
    end
    return dam
end

function UnitDamage(caster,target,dam,damageType,damTypeNote,skill,flag)
    dam = SkillEnchant(caster,target,damTypeNote,dam)
    dam = SkillResist(caster,target,damTypeNote,dam)
    --[[闪避在FilterModifyDamage统一计算
    if dam<GameTime()*0.3+200 then --evade
        if RandomFloat(0,1)<GetEvade(target,caster) then
            EvadeSuccess(caster,target)
            dam = -1
        end
    end
    ]]
    if dam>0 then
        local damage_table = {
            attacker = caster,
            victim = target,
            ability = skill,
            damage_type = damageType,
            damage_flags = flag,
            damage = dam
        }
        ApplyDamage(damage_table)
    end
end







function Heal(caster,target,life,show)
    local e = 1
    if caster:HasItemInInventory("item_milksoul") then --牛奶魂
        e=e+0.2
    end
    if caster:HasModifier("modifier_priest_talent_3") then --牧师天赋
        e=e+0.15
    end
    if caster:HasModifier("modifier_sasa_talent_3") then --sasa天赋
        e=e+0.15
    end
    if caster:HasModifier("modifier_char_talent_4") then --char天赋
        e=e+0.2
    end
    if target:HasModifier("modifier_priest_aura_action") then --牧师
        local sta = GetModifierStat(target,"modifier_priest_aura_action","cure")
        if sta then
            e=e+sta/100
        end
    end
    life=life*e
    target:Heal(life, caster)
    if show then
        local digits = string.len( math.floor( life ) ) + 1
        local pct = ParticleManager:CreateParticle( "particles/msg_fx/msg_heal.vpcf", PATTACH_OVERHEAD_FOLLOW, target )
        ParticleManager:SetParticleControl( pct, 1, Vector( 10, life, 0 ) )
        ParticleManager:SetParticleControl( pct, 2, Vector( 2.0, digits, 0 ) )
        ParticleManager:SetParticleControl( pct, 3, Vector( 33, 255, 33 ) )
    end
    --治疗统计
    if caster:GetTeamNumber()==target:GetTeamNumber() and target:IsHero() then
        local hero = nil
        if caster:IsIllusion() then
            local id = caster:GetPlayerID()
            local player = PlayerResource:GetPlayer(id)
            hero=player:GetAssignedHero()
        else
            hero = caster:GetPlayerOwner():GetAssignedHero()
        end
        if hero and hero.stat_heal and hero~=target then
            hero.stat_heal = hero.stat_heal + life
        end
    end
end

function AntiDamageShellCal(attacker,victim,dam) --victim has shell
    local vnow = 0
    print("====================")
    if CountTable(victim.damage_shell)>0 then
        for k, v in pairs( victim.damage_shell ) do
            if v>0 then
                --护盾数值减少
                print("start "..v)
                vnow=v-dam
                print("end "..vnow)
                if vnow<=0 then
                    --该护盾耗尽，删除
                    victim:RemoveModifierByName(k)
                    --victim.damage_shell[k]=nil
                else
                    victim.damage_shell[k]=vnow
                end
                --伤害减少
                dam=dam-v
                if dam<0 then
                    --如果伤害减到0，跳出
                    break
                end
            else
                victim:RemoveModifierByName(k)
                --victim.damage_shell[k]=nil
            end
        end
        --伤害不低于0
        dam=math.max(dam,0)
        --若护盾表内的数据为空，删除表
        --[[
        if CountTable(victim.damage_shell)<=0 then
            AntiDamageShellDestroy(victim)
        end
        if victim.damage_shell then
            PrintTable(victim.damage_shell)
        end]]
    else
        AntiDamageShellDestroy(victim)
    end
    return dam
end
function AntiDamageShell(caster,target,key,args,ability,val,stack) --key就是modifier名字 , stack 1-叠加; 0-不叠加，只补齐最大数值
    if not target.damage_shell then
        target.damage_shell={}
    end
    if target:HasModifier(key) and target.damage_shell[key] then
        if stack then
            target.damage_shell[key]=target.damage_shell[key]+val
        else
            target.damage_shell[key]=math.max(target.damage_shell[key],val)
        end
    else
        target.damage_shell[key]=val
    end
    ability:ApplyDataDrivenModifier(caster, target, key, args)
    --[[ 特效不再统一添加，每个modifier独自添加
    if not target.damage_shell_pct then
        target.damage_shell_pct = ParticleManager:CreateParticle("particles/system/anti_damage_shield.vpcf", PATTACH_POINT_FOLLOW, target)
        ParticleManager:SetParticleControlEnt(target.damage_shell_pct, 0, target, PATTACH_POINT_FOLLOW, "follow_hitloc", target:GetAbsOrigin(), true)
    end]]
    --Msg
    local digits = string.len( math.floor( val ) ) + 1
    local pct = ParticleManager:CreateParticle( "particles/msg_fx/msg_spell.vpcf", PATTACH_OVERHEAD_FOLLOW, target )
    ParticleManager:SetParticleControl( pct, 1, Vector( 0, val, 7 ) )
    ParticleManager:SetParticleControl( pct, 2, Vector( 2, digits, 0 ) )
    ParticleManager:SetParticleControl( pct, 3, Vector( 33, 200, 255 ) )
end
function AntiDamageShellRemove(keys)
    local target = keys.target
    local key = keys.modifier_name
    --PrintTable(keys)
    if target.damage_shell then
        if CountTable(target.damage_shell)>0 then
            if target:HasModifier(key) then
                target:RemoveModifierByName(key)
            end
            target.damage_shell[key]=nil
        end
        if CountTable(target.damage_shell)<=0 then
            AntiDamageShellDestroy(target)
        end
    end
end
function AntiDamageShellDestroy(caster)
    caster.damage_shell=nil
    --[[
    if caster.damage_shell_pct then
        ParticleManager:DestroyParticle(caster.damage_shell_pct, true)
        caster.damage_shell_pct=nil
    end
    ]]
    ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mana_shield_shatter.vpcf", PATTACH_POINT_FOLLOW, caster)
end

--魔法护盾
function AntiMagicShellCal(attacker,victim,dam) --victim has shell
    local vnow = 0
    if CountTable(victim.magic_shell)>0 then
        for k, v in pairs( victim.magic_shell ) do
            if v>0 then
                --护盾数值减少
                vnow=v-dam
                if vnow<=0 then
                    --该护盾耗尽，删除
                    victim:RemoveModifierByName(k)
                else
                    victim.magic_shell[k]=vnow
                end
                --伤害减少
                dam=dam-v
                if dam<0 then
                    --如果伤害减到0，跳出
                    break
                end
            else
                victim:RemoveModifierByName(k)
            end
        end
        --伤害不低于0
        dam=math.max(dam,0)
        --若护盾表内的数据为空，删除表
    else
        AntiMagicShellDestroy(victim)
    end
    return dam
end
function AntiMagicShell(caster,target,key,args,ability,val,stack) --key就是modifier名字 , stack 1-叠加; 0-不叠加，只补齐最大数值
    if not target.magic_shell then
        target.magic_shell={}
    end
    if target:HasModifier(key) and target.magic_shell[key] then
        if stack then
            target.magic_shell[key]=target.magic_shell[key]+val
        else
            target.magic_shell[key]=math.max(target.magic_shell[key],val)
        end
    else
        target.magic_shell[key]=val
    end
    ability:ApplyDataDrivenModifier(caster, target, key, args)
    --Msg
    local digits = string.len( math.floor( val ) ) + 1
    local pct = ParticleManager:CreateParticle( "particles/msg_fx/msg_spell.vpcf", PATTACH_OVERHEAD_FOLLOW, target )
    ParticleManager:SetParticleControl( pct, 1, Vector( 0, val, 7 ) )
    ParticleManager:SetParticleControl( pct, 2, Vector( 2, digits, 0 ) )
    ParticleManager:SetParticleControl( pct, 3, Vector( 0, 255, 96 ) )
end
function AntiMagicShellRemove(keys)
    local target = keys.target
    local key = keys.modifier_name
    if target.magic_shell then
        if CountTable(target.magic_shell)>0 then
            if target:HasModifier(key) then
                target:RemoveModifierByName(key)
            end
            target.magic_shell[key]=nil
        end
        if CountTable(target.magic_shell)<=0 then
            AntiMagicShellDestroy(target)
        end
    end
end
function AntiMagicShellDestroy(caster)
    caster.magic_shell=nil
    ParticleManager:CreateParticle("particles/system/anti_magic_shield_shatter.vpcf", PATTACH_POINT_FOLLOW, caster)
end

---------------补给--------------------------------------
function CreatureDrop(u)
    local team = nil
    local modifier = nil
    if u:GetTeamNumber()==DOTA_TEAM_GOODGUYS then
        team=DOTA_TEAM_BADGUYS
        modifier = "modifier_sys_supply_check"
    elseif u:GetTeamNumber()==DOTA_TEAM_BADGUYS then
        team=DOTA_TEAM_GOODGUYS
        modifier = "modifier_sys_supply_check2"
    end
    if team then
        local ball = CreateUnitByName("dummy_unit", u:GetAbsOrigin(), true, nil,nil,team)
        ball:AddNewModifier(ball, nil, "modifier_kill", {duration = 5})
        ball:AddAbility("sys_supply")
        ball:SetAbsOrigin(ball:GetAbsOrigin() + Vector(0,0,40)) 
        local ab = ball:FindAbilityByName("sys_supply")
        ab:SetLevel(1)
        ab:ApplyDataDrivenModifier(ball, ball, modifier, nil)
        --ball.pct = ParticleManager:CreateParticle( "particles/units/heroes/hero_stardust/stardust_lightning_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, ball )
        --ParticleManager:SetParticleControlEnt(ball.pct, 0, ball, PATTACH_POINT_FOLLOW, "follow_origin", ball:GetAbsOrigin(), true)
    end
end
function CreatureDrop_Pick(keys)
    local caster = keys.caster
    local picker = keys.target
    local ability = keys.ability
    if caster and IsValidEntity(caster) and caster:IsAlive() then
        ability:ApplyDataDrivenModifier(caster, picker, "modifier_sys_supply", nil)
        --caster:RemoveAbility(ability:GetAbilityName()) 
        local pct = ParticleManager:CreateParticle("particles/system/supply_ball_impact.vpcf", PATTACH_POINT_FOLLOW, picker)
        ParticleManager:SetParticleControlEnt(pct, 0, picker, PATTACH_POINT_FOLLOW, "follow_hitloc", picker:GetAbsOrigin(), true)
        picker:EmitSound("Hero_Warlock.ShadowWordCastGood") 
        caster:ForceKill(true)
    end
end
function CreatureDrop_Death(keys)
    local caster = keys.caster
    caster:AddNoDraw()
end



---------------闪避-------------------------------------------------------
function EvadeSuccess(caster,target)
    if IsValidEntity(target) then
        if target:IsAlive() then
            local pct = ParticleManager:CreateParticle( "particles/msg_fx/msg_evade.vpcf", PATTACH_OVERHEAD_FOLLOW, target )
            ParticleManager:SetParticleControl( pct, 1, Vector( 6, 0, 0 ) )
            ParticleManager:SetParticleControl( pct, 2, Vector( 1.0, 1, 0 ) )
            ParticleManager:SetParticleControl( pct, 3, Vector( 100, 255, 255 ) )
            --醉拳----------------------------
            if target:HasModifier("modifier_brew_drunk_evade") and target:HasItemInInventory("item_chest") then
                local ab = target:FindAbilityByName("brew_drunk")
                ab:ApplyDataDrivenModifier(target,target,"modifier_brew_drunk_chest",nil)
            end
        end
    end
end
---------------魔法值-------------------------------------------------------
function ReduceManaShow(target,v)
    local digits = string.len( math.floor( v ) ) + 1
    local pct = ParticleManager:CreateParticle( "particles/msg_fx/msg_mana_loss.vpcf", PATTACH_OVERHEAD_FOLLOW, target )
    ParticleManager:SetParticleControl( pct, 1, Vector( 1, v, 0 ) )
    ParticleManager:SetParticleControl( pct, 2, Vector( 2.0, digits, 0 ) )
    ParticleManager:SetParticleControl( pct, 3, Vector( 33, 33, 255 ) )
end
function GiveManaShow(target,v)
    local digits = string.len( math.floor( v ) ) + 1
    local pct = ParticleManager:CreateParticle( "particles/msg_fx/msg_mana_add.vpcf", PATTACH_OVERHEAD_FOLLOW, target )
    ParticleManager:SetParticleControl( pct, 1, Vector( 10, v, 0 ) )
    ParticleManager:SetParticleControl( pct, 2, Vector( 2.0, digits, 0 ) )
    ParticleManager:SetParticleControl( pct, 3, Vector( 33, 33, 255 ) )
end

function CritShow(target)
    if target:IsAlive() then
        local pct = ParticleManager:CreateParticle( "particles/system/msg_crit.vpcf", PATTACH_OVERHEAD_FOLLOW, target )
        ParticleManager:SetParticleControl( pct, 1, Vector( 10, 0, 4 ) )
        ParticleManager:SetParticleControl( pct, 2, Vector( 1.0, 1, 0 ) )
        ParticleManager:SetParticleControl( pct, 3, Vector( 255, 25, 25 ) )
    end
end

--------------------------------------------------------------------------
---------------天气-------------------------------------------------------
--------------------------------------------------------------------------
function WeatherStart()
    DUMMY_A = CreateUnitByName("dummy_almighty", Vector(0,GetWorldMaxY()-500,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
    local ability = DUMMY_A:AddAbility("weather_buff") 
    local heroes = HeroList:GetAllHeroes()
    local dur = RandomInt(180,300)
    if #heroes>0 then
        for _,hero in pairs(heroes) do
            if hero then
                ability:ApplyDataDrivenModifier(DUMMY_A, hero, "modifier_weather_sunny", {duration = dur})
            end
        end
    end
    ability:ApplyDataDrivenModifier(DUMMY_A, DUMMY_A, "modifier_weather_sunny", {duration = dur})
    DUMMY_A.WEATHER_CURRENT = 0
end
function RandomIntExcept(a,b,ex)
    local pick = 0
    local max = 0
    for i = a,b do
        local rnd = RandomFloat(0,1)
        if i==ex then
            rnd = 0
        end
        if rnd>max then
            max = rnd
            pick = i
        end
    end
    return pick
end
function GetWeatherName(i)
    if i==0 then
        return "modifier_weather_sunny"
    elseif i==1 then
        return "modifier_weather_rainy"
    elseif i==2 then
        return "modifier_weather_thunder"
    elseif i==3 then
        return "modifier_weather_snow"
    elseif i==4 then
        return "modifier_weather_ray"
    elseif i==5 then
        return "modifier_weather_wind"
    elseif i==6 then
        return "modifier_weather_lemon"
    elseif i==7 then
        return "modifier_weather_fog"
    elseif i==8 then
        return "modifier_weather_cloud"
    elseif i==9 then
        return "modifier_weather_cloudless"
    end
    return nil
end
function WeatherWaitTillAlive(hero,toWeather)
    Timers:CreateTimer(function()
        if DUMMY_A.WEATHER_CURRENT~=toWeather then
            return nil
        elseif IsValidEntity(hero) and hero:IsAlive() then
            local name = GetWeatherName(toWeather)
            local buff = DUMMY_A:FindModifierByName(name)
            local ability = DUMMY_A:FindAbilityByName("weather_buff") 
            if buff then
                local dur = buff:GetRemainingTime()
                ability:ApplyDataDrivenModifier(DUMMY_A, hero, name, {duration = dur})
            end
            return nil
        else
            return 1
        end
    end)
end
function WeatherChange(keys)
    local target = keys.target
    local ability = DUMMY_A:FindAbilityByName("weather_buff") 
    if target==DUMMY_A then
        local i = RandomIntExcept(0,9,DUMMY_A.WEATHER_CURRENT)
        DUMMY_A.WEATHER_CURRENT=i
        --print("weather "..DUMMY_A.WEATHER_CURRENT)
        local heroes = HeroList:GetAllHeroes()
        local dur = RandomInt(60,240)
        if DUMMY_A.WEATHER_CURRENT==0 then
            GameRules:SendCustomMessage("The weather turned sunny.", DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS, 0) 
            Notifications:TopToAll({text="note_weather_sunny", duration=6, style={color="rgb(255,255,200)"}})
            ability:ApplyDataDrivenModifier(DUMMY_A, DUMMY_A, "modifier_weather_sunny", {duration = dur})
            if #heroes>0 then
                for _,hero in pairs(heroes) do
                    if hero then
                        if hero:IsAlive() then
                            ability:ApplyDataDrivenModifier(DUMMY_A, hero, "modifier_weather_sunny", {duration = dur})
                        else
                            WeatherWaitTillAlive(hero,DUMMY_A.WEATHER_CURRENT)
                        end
                    end
                end
            end
        elseif DUMMY_A.WEATHER_CURRENT==1 then
            GameRules:SendCustomMessage("The weather turned rainy.", DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS, 0) 
            Notifications:TopToAll({text="note_weather_rainy", duration=6, style={color="rgb(135,206,255)"}})
            ability:ApplyDataDrivenModifier(DUMMY_A, DUMMY_A, "modifier_weather_rainy", {duration = dur})
            if #heroes>0 then
                for _,hero in pairs(heroes) do
                    if hero then
                        if hero:IsAlive() then
                            ability:ApplyDataDrivenModifier(DUMMY_A, hero, "modifier_weather_rainy", {duration = dur})
                        else
                            WeatherWaitTillAlive(hero,DUMMY_A.WEATHER_CURRENT)
                        end
                    end
                end
            end
        elseif DUMMY_A.WEATHER_CURRENT==2 then
            GameRules:SendCustomMessage("The weather turned thundering.", DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS, 0) 
            Notifications:TopToAll({text="note_weather_thunder", duration=6, style={color="rgb(255,255,0)"}})
            ability:ApplyDataDrivenModifier(DUMMY_A, DUMMY_A, "modifier_weather_thunder", {duration = dur})
            if #heroes>0 then
                for _,hero in pairs(heroes) do
                    if hero then
                        if hero:IsAlive() then
                            ability:ApplyDataDrivenModifier(DUMMY_A, hero, "modifier_weather_thunder", {duration = dur})
                        else
                            WeatherWaitTillAlive(hero,DUMMY_A.WEATHER_CURRENT)
                        end
                    end
                end
            end
            WeatherThunder()
        elseif DUMMY_A.WEATHER_CURRENT==3 then
            GameRules:SendCustomMessage("The weather turned snowy.", DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS, 0) 
            Notifications:TopToAll({text="note_weather_snow", duration=6, style={color="rgb(210,255,255)"}})
            ability:ApplyDataDrivenModifier(DUMMY_A, DUMMY_A, "modifier_weather_snow", {duration = dur})
            if #heroes>0 then
                for _,hero in pairs(heroes) do
                    if hero then
                        if hero:IsAlive() then
                            ability:ApplyDataDrivenModifier(DUMMY_A, hero, "modifier_weather_snow", {duration = dur})
                        else
                            WeatherWaitTillAlive(hero,DUMMY_A.WEATHER_CURRENT)
                        end
                    end
                end
            end
        elseif DUMMY_A.WEATHER_CURRENT==4 then
            GameRules:SendCustomMessage("The weather turned auroral.", DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS, 0) 
            Notifications:TopToAll({text="note_weather_ray", duration=6, style={color="rgb(255,0,255)"}})
            ability:ApplyDataDrivenModifier(DUMMY_A, DUMMY_A, "modifier_weather_ray", {duration = dur})
            if #heroes>0 then
                for _,hero in pairs(heroes) do
                    if hero then
                        if hero:IsAlive() then
                            ability:ApplyDataDrivenModifier(DUMMY_A, hero, "modifier_weather_ray", {duration = dur})
                        else
                            WeatherWaitTillAlive(hero,DUMMY_A.WEATHER_CURRENT)
                        end
                    end
                end
            end
        elseif DUMMY_A.WEATHER_CURRENT==5 then
            GameRules:SendCustomMessage("The weather turned windy.", DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS, 0) 
            Notifications:TopToAll({text="note_weather_wind", duration=6, style={color="rgb(0,255,127)"}})
            ability:ApplyDataDrivenModifier(DUMMY_A, DUMMY_A, "modifier_weather_wind", {duration = dur})
            if #heroes>0 then
                for _,hero in pairs(heroes) do
                    if hero then
                        if hero:IsAlive() then
                            ability:ApplyDataDrivenModifier(DUMMY_A, hero, "modifier_weather_wind", {duration = dur})
                        else
                            WeatherWaitTillAlive(hero,DUMMY_A.WEATHER_CURRENT)
                        end
                    end
                end
            end
        elseif DUMMY_A.WEATHER_CURRENT==6 then
            GameRules:SendCustomMessage("The weather turned lemon.", DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS, 0) 
            Notifications:TopToAll({text="note_weather_lemon", duration=6, style={color="rgb(255,165,0)"}})
            ability:ApplyDataDrivenModifier(DUMMY_A, DUMMY_A, "modifier_weather_lemon", {duration = dur})
            if #heroes>0 then
                for _,hero in pairs(heroes) do
                    if hero then
                        if hero:IsAlive() then
                            ability:ApplyDataDrivenModifier(DUMMY_A, hero, "modifier_weather_lemon", {duration = dur})
                        else
                            WeatherWaitTillAlive(hero,DUMMY_A.WEATHER_CURRENT)
                        end
                    end
                end
            end
        elseif DUMMY_A.WEATHER_CURRENT==7 then
            GameRules:SendCustomMessage("The weather turned foggy.", DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS, 0) 
            Notifications:TopToAll({text="note_weather_fog", duration=6, style={color="rgb(255,205,255"}})
            ability:ApplyDataDrivenModifier(DUMMY_A, DUMMY_A, "modifier_weather_fog", {duration = dur})
            if #heroes>0 then
                for _,hero in pairs(heroes) do
                    if hero then
                        if hero:IsAlive() then
                            ability:ApplyDataDrivenModifier(DUMMY_A, hero, "modifier_weather_fog", {duration = dur})
                        else
                            WeatherWaitTillAlive(hero,DUMMY_A.WEATHER_CURRENT)
                        end
                    end
                end
            end
        elseif DUMMY_A.WEATHER_CURRENT==8 then
            GameRules:SendCustomMessage("The weather turned cloudy.", DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS, 0) 
            Notifications:TopToAll({text="note_weather_cloud", duration=6, style={color="rgb(255,105,180)"}})
            ability:ApplyDataDrivenModifier(DUMMY_A, DUMMY_A, "modifier_weather_cloud", {duration = dur})
            if #heroes>0 then
                for _,hero in pairs(heroes) do
                    if hero then
                        if hero:IsAlive() then
                            ability:ApplyDataDrivenModifier(DUMMY_A, hero, "modifier_weather_cloud", {duration = dur})
                        else
                            WeatherWaitTillAlive(hero,DUMMY_A.WEATHER_CURRENT)
                        end
                    end
                end
            end
        elseif DUMMY_A.WEATHER_CURRENT==9 then
            GameRules:SendCustomMessage("The weather turned cloudless.", DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS, 0) 
            Notifications:TopToAll({text="note_weather_cloudless", duration=6, style={color="rgb(150,255,255)"}})
            ability:ApplyDataDrivenModifier(DUMMY_A, DUMMY_A, "modifier_weather_cloudless", {duration = dur})
            if #heroes>0 then
                for _,hero in pairs(heroes) do
                    if hero then
                        if hero:IsAlive() then
                            ability:ApplyDataDrivenModifier(DUMMY_A, hero, "modifier_weather_cloudless", {duration = dur})
                        else
                            WeatherWaitTillAlive(hero,DUMMY_A.WEATHER_CURRENT)
                        end
                    end
                end
            end
        end

    end
end

function WeatherLemon(keys)
    local target = keys.target
    if target:IsHero() and target:IsAlive() then
        local life = target:GetHealth()*0.005
        target:SetHealth(math.max(10,target:GetHealth()-life))
    end
end
function WeatherThunder()
    local dur = RandomFloat(3,12)
    Timers:CreateTimer(dur,function()
        if DUMMY_A.WEATHER_CURRENT==2 then
            --随机雷电
            local max = -1
            local uPick = nil
            local heroes = HeroList:GetAllHeroes()
            if #heroes>0 then
                for _,hero in pairs(heroes) do
                    if hero and hero:IsAlive() then
                        local rnd = RandomFloat(0, 1)
                        if rnd>max then
                            max=rnd
                            uPick = hero
                        end
                    end
                end
                if uPick then
                    local pOrg = uPick:GetAbsOrigin()+RandomVector(RandomInt(300,900))
                    local ability = DUMMY_A:FindAbilityByName("weather_buff") 
                    local pct = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, uPick)
                    ParticleManager:SetParticleControl(pct, 0, pOrg+Vector(0,0,800))
                    ParticleManager:SetParticleControl(pct, 1, pOrg)   
                    EmitSoundOnLocationWithCaster(pOrg, "Hero_Zuus.LightningBolt", DUMMY_A)
                    local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, pOrg, nil,200, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
                    if #units > 0 then
                        for _,enemy in pairs(units) do
                            if enemy ~= nil and IsValidUnit(enemy) and not enemy:IsInvulnerable() and not enemy:IsMagicImmune() then
                                UnitDamage(DUMMY_A,enemy,RandomFloat(50, 800),DAMAGE_TYPE_MAGICAL,3,ability,nil)
                            end
                        end
                    end
                end
            end
            WeatherThunder()
        end
        return nil
    end)
end
function WeatherCloudLeech(keys)
    local caster = keys.attacker
    local ability=keys.ability
    local dam = keys.amount
    if dam>1 and dam<9999 then
        local life = dam*0.05
        if life>1 then
            caster:Heal(life, caster)
            local digits = string.len( math.floor( life ) ) + 1
            local pct = ParticleManager:CreateParticle( "particles/msg_fx/msg_heal.vpcf", PATTACH_OVERHEAD_FOLLOW, caster )
            ParticleManager:SetParticleControl( pct, 1, Vector( 10, life, 0 ) )
            ParticleManager:SetParticleControl( pct, 2, Vector( 2.0, digits, 0 ) )
            ParticleManager:SetParticleControl( pct, 3, Vector( 33, 255, 33 ) )
            local pct0 = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_POINT_FOLLOW, caster )
        end
    end
end
--英雄特殊天气相关技能
function WeatherWind_Create(keys)
    local hero = keys.target
    if hero:IsRealHero() then
        local name = hero:GetUnitName()
        if name=="npc_dota_hero_storm_spirit" then
            local ab = hero:FindAbilityByName("windbunny_swift")
            if ab then
                local level = ab:GetLevel() - 1
                if level>-1 then
                    Timers:CreateTimer(0.5,function()
                        ab:ApplyDataDrivenModifier(hero, hero, "modifier_windbunny_swift_weather", nil)
                    end)
                end
            end
        end
    end
end
function WeatherWind_End(keys)
    local hero = keys.target
    if hero:HasModifier("modifier_windbunny_swift_weather") then
        hero:RemoveModifierByName("modifier_windbunny_swift_weather")
    end
end
function WeatherThunder_Create(keys)
    local hero = keys.target
    if hero:IsRealHero() then
        local name = hero:GetUnitName()
        if name=="npc_dota_hero_storm_spirit" then
            local ab = hero:FindAbilityByName("windbunny_swift")
            if ab then
                local level = ab:GetLevel() - 1
                if level>-1 then
                    Timers:CreateTimer(0.5,function()
                        ab:ApplyDataDrivenModifier(hero, hero, "modifier_windbunny_swift_weather", nil)
                    end)
                end
            end
        end
    end
end
function WeatherThunder_End(keys)
    local hero = keys.target
    if hero:HasModifier("modifier_windbunny_swift_weather") then
        hero:RemoveModifierByName("modifier_windbunny_swift_weather")
    end
end

function ConfusedAction(keys)
    local caster = keys.caster
    local target = keys.target
    local forceTarget = target:GetForceAttackTarget()
    if forceTarget==nil or IsValidEntity(forceTarget) or not forceTarget:IsAlive() then
        --换一个攻击目标
        forceTarget = GetNearestEnemyNearPoint(target:GetAbsOrigin(), 900, target, true, true)
        if forceTarget then
            target:SetForceAttackTarget(forceTarget)
            --[[local order = 
            {
                UnitIndex = target:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                TargetIndex = forceTarget:entindex()
            }

            ExecuteOrderFromTable(order)]]
            target:MoveToTargetToAttack(forceTarget)
        else
            target:Stop()
            target:SetForceAttackTarget(nil)
        end
    end
end
function ConfusedEnd(keys)
    local caster = keys.caster
    local target = keys.target
    target:SetForceAttackTarget(nil)
end

function notInTable(value, tbl)
    for _, v in ipairs(tbl) do
        if value == v then
            return false
        end
    end
    return true
end

-- Talent handling
function CDOTA_BaseNPC:HasTalent(talentName)
	if self and not self:IsNull() and self:HasAbility(talentName) then
		if self:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end

	return false
end

