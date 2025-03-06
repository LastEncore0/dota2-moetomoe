require("ai")

HERO_TANK = {4,9,11}
HERO_WARRIOR = {0,1,3,5,7}
HERO_MAGE = {2,6,10,8,12}
HERO_LIST = {
    [0]= "npc_dota_hero_axe",	
    [1]= "npc_dota_hero_spectre",	
    [2]= "npc_dota_hero_winter_wyvern", 
	[3]= "npc_dota_hero_magnataur" ,
	[4]= "npc_dota_hero_ember_spirit",
	[5]= "npc_dota_hero_templar_assassin", 
	[6]= "npc_dota_hero_storm_spirit",	
	[7]= "npc_dota_hero_clinkz"	,
	[8]= "npc_dota_hero_zuus",	
	[9]= "npc_dota_hero_juggernaut",		
	[10]= "npc_dota_hero_earthshaker",
	[11]= "npc_dota_hero_tusk",	
	[12]= "npc_dota_hero_troll_warlord",
}

function GetRandomHeroName(num)
	local name = nil
	local i = num
	if i==-1 then
		i=RandomInt(0, 12) 
	end
	name=HERO_LIST[i]
	return name
end

function GetRandomHero()
	local name = GetRandomHeroName(-1)
	while PlayerResource:IsHeroSelected(name) do
		name = GetRandomHeroName(-1)
	end
	return name
end
function GetRandomHeroFromGroup(tbl)
	local i = RandomInt(1,#tbl)
	local k = 10 --保护
	local name = GetRandomHeroName(tbl[i])
	while PlayerResource:IsHeroSelected(name) and k>0 do
		name = GetRandomHeroName(tbl[i])
		k=k-1
	end
	if PlayerResource:IsHeroSelected() then
		return nil
	end
	return name
end
function GetIDFromHeroList(hero)
	local name = hero:GetUnitName() 
	for k,v in pairs(HERO_LIST) do
		if name==v then
			return k
		end
	end
	return -1
end

function CheckAITeam(team) --检查AI阵容的构成
	local tbl = {[1]=0,[2]=0,[3]=0,[4]=0}
	local heroes = HeroList:GetAllHeroes()
	if #heroes>0 then
		for _,hero in pairs(heroes) do
			if hero:GetTeamNumber()==team then
				local id = GetIDFromHeroList(hero)
				if IsInTable(id,HERO_TANK) then
					tbl[1]=tbl[1]+1
				end
				if IsInTable(id,HERO_WARRIOR) then
					tbl[2]=tbl[2]+1
				end
				if IsInTable(id,HERO_MAGE) then
					tbl[3]=tbl[4]+1
				end
			end
		end
	end
	--PrintTable(tbl)
	if tbl[1]+tbl[2]+tbl[3]+tbl[4]>=3 then --最后两个位置再检定
		if tbl[1]==0 then
			return 1
		end
		if tbl[4]==0 then
			return 4
		end
		if tbl[2]==0 then
			return 2
		end
		if tbl[3]==0 then
			return 3
		end
	end
	return 0
end
function AddBotToTeam(team)
	local k = CheckAITeam(team) --缺少的位置
	local name = nil
	if name==nil then
		name = GetRandomHeroName(-1)
	end
	if team==DOTA_TEAM_GOODGUYS then
		
		Tutorial:AddBot(name,"","",true)
	else
		
		Tutorial:AddBot(name,"","",false)
	end
end

function InitHeroTrig(hero)
	local name = hero:GetUnitName()
	local i = hero:GetPlayerID()
	local isAI = false
	local id = GetIDFromHeroList(hero)
    print("InitHeroTrig")
	if IsAI(i) then
    print("IsAI")
		isAI = true
	end
		print("name =",name)
	if name=="npc_dota_hero_axe" then
		hero.skill_tree = {}
        for lv=1,18 do
			if lv==1 or lv==4 or lv==5 or lv==7 then
				hero.skill_tree[lv]="redmodel"
			elseif lv==2 or lv==8 or lv==9 or lv==11 or lv==13 then
				hero.skill_tree[lv]="bluemodel"
			elseif lv==3 or lv==14 or lv==16 or lv==17 then
				hero.skill_tree[lv]="greenmodel"
			elseif lv==6 or lv==12 or lv==18 then
				hero.skill_tree[lv]="worldend"
			end
            hero.skill_tree[101]="kuroyuki_talent_1"
            hero.skill_tree[102]="special_bonus_attack_damage_10"
            hero.skill_tree[103]="kuroyuki_talent_2"
            hero.skill_tree[104]="special_bonus_attack_damage_20"
            hero.skill_tree[105]="special_bonus_attack_damage_30"
            hero.skill_tree[106]="special_bonus_evasion_25"
            hero.skill_tree[107]="special_bonus_attack_damage_40"
            hero.skill_tree[108]="special_bonus_attack_speed_100"
        end
	elseif name=="npc_dota_hero_spectre" then
		hero.skill_tree = {}
        for lv=1,18 do
			if lv==1 or lv==4 or lv==5 or lv==7 then
				hero.skill_tree[lv]="hand_sonic"
			elseif lv==2 or lv==8 or lv==9 or lv==11 or lv==13 then
				hero.skill_tree[lv]="Dispersion"
			elseif lv==3 or lv==14 or lv==16 or lv==17 then
				hero.skill_tree[lv]="dealy"
			elseif lv==6 or lv==12 or lv==18 then
				hero.skill_tree[lv]="redeye_angel"
			end
            hero.skill_tree[101]="kanade_talent_1"
            hero.skill_tree[102]="special_bonus_vision_200"
            hero.skill_tree[103]="special_bonus_magic_resistance_15"
            hero.skill_tree[104]="special_bonus_mp_regen_6"
            hero.skill_tree[105]="kanade_talent_2"
            hero.skill_tree[106]="special_bonus_hp_400"
            hero.skill_tree[107]="special_bonus_agility_25"
            hero.skill_tree[108]="kanade_talent_3"
        end
	elseif name=="npc_dota_hero_winter_wyvern" then
		hero.skill_tree = {}
        for lv=1,18 do
			if lv==1 or lv==4 or lv==5 or lv==7 then
				hero.skill_tree[lv]="killselfgeass"
			elseif lv==2 or lv==8 or lv==9 or lv==11 or lv==13 then
				hero.skill_tree[lv]="emperor_commend"
			elseif lv==3 or lv==14 or lv==16 or lv==17 then
				hero.skill_tree[lv]="geass"
			elseif lv==6 or lv==12 or lv==18 then
				hero.skill_tree[lv]="zeroleader"
			end
            hero.skill_tree[101]="leloch_talent_1"
            hero.skill_tree[102]="special_bonus_cast_range_200"
            hero.skill_tree[103]="special_bonus_intelligence_15"
            hero.skill_tree[104]="special_bonus_mp_regen_6"
            hero.skill_tree[105]="special_bonus_cooldown_reduction_15"
            hero.skill_tree[106]="special_bonus_attack_damage_90"
            hero.skill_tree[107]="leloch_talent_2"
            hero.skill_tree[108]="leloch_talent_3"
        end
	elseif name=="npc_dota_hero_magnataur" then
		hero.skill_tree = {}
        for lv=1,18 do
			if lv==1 or lv==4 or lv==5 or lv==7 then
				hero.skill_tree[lv]="hayaku_run"
			elseif lv==2 or lv==8 or lv==9 or lv==11 or lv==13 then
				hero.skill_tree[lv]="four_fangzhan"
			elseif lv==3 or lv==14 or lv==16 or lv==17 then
				hero.skill_tree[lv]="nitaoliu"
			elseif lv==6 or lv==12 or lv==18 then
				hero.skill_tree[lv]="star_burst_stream"
			end
            hero.skill_tree[101]="kirito_talent_1"
            hero.skill_tree[102]="special_bonus_mp_regen_2"
            hero.skill_tree[103]="special_bonus_lifesteal_10"
            hero.skill_tree[104]="special_bonus_armor_8"
            hero.skill_tree[105]="special_bonus_attack_damage_40"
            hero.skill_tree[106]="special_bonus_hp_400"
            hero.skill_tree[107]="special_bonus_agility_25"
            hero.skill_tree[108]="kirito_talent_2"
        end
	elseif name=="npc_dota_hero_ember_spirit" then
		hero.skill_tree = {}
        for lv=1,18 do
			if lv==1 or lv==3 or lv==4 or lv==5 or lv==7 or lv==8 or lv==9 then
				hero.skill_tree[lv]="shanatruered"
			elseif lv==11 or lv==13 or lv==14 or lv==16 or lv==17 then
				hero.skill_tree[lv]="alasterhand"
			elseif lv==6 or lv==12 or lv==18 then
				hero.skill_tree[lv]="brakesky"
			end
            hero.skill_tree[101]="shana_talent_1"
            hero.skill_tree[102]="special_bonus_magic_resistance_20"
            hero.skill_tree[103]="special_bonus_strength_15"
            hero.skill_tree[104]="special_bonus_movement_speed_25"
            hero.skill_tree[105]="special_bonus_spell_amplify_15"
            hero.skill_tree[106]="special_bonus_attack_damage_25"
            hero.skill_tree[107]="shana_talent_2"
            hero.skill_tree[108]="shana_talent_3"
        end
	elseif name=="npc_dota_hero_templar_assassin" then
		hero.skill_tree = {}
        for lv=1,18 do
			if lv==1 or lv==4 or lv==5 or lv==7 then
				hero.skill_tree[lv]="double_gunandknife"
			elseif lv==2 or lv==8 or lv==9 or lv==11 or lv==13 then
				hero.skill_tree[lv]="doubleknifestrike"
			elseif lv==3 or lv==14 or lv==16 or lv==17 then
				hero.skill_tree[lv]="clotharia"
			elseif lv==6 or lv==12 or lv==18 then
				hero.skill_tree[lv]="daibu"
			end
            hero.skill_tree[101]="aria_talent_1"
            hero.skill_tree[102]="special_bonus_movement_speed_20"
            hero.skill_tree[103]="special_bonus_armor_10"
            hero.skill_tree[104]="special_bonus_magic_resistance_20"
            hero.skill_tree[105]="special_bonus_strength_25"
            hero.skill_tree[106]="special_bonus_attack_damage_30"
            hero.skill_tree[107]="aria_talent_2"
            hero.skill_tree[108]="special_bonus_agility_25"
        end
	elseif name=="npc_dota_hero_storm_spirit" then
		hero.skill_tree = {}
        for lv=1,18 do
			if lv==1 or lv==4 or lv==5 or lv==7 then
				hero.skill_tree[lv]="railgun"
			elseif lv==2 or lv==8 or lv==9 or lv==11 or lv==13 then
				hero.skill_tree[lv]="lightlance"
			elseif lv==3 or lv==14 or lv==16 or lv==17 then
				hero.skill_tree[lv]="diancichang"
			elseif lv==6 or lv==12 or lv==18 then
				hero.skill_tree[lv]="truethunder"
			end
            hero.skill_tree[101]="misaka_talent_1"
            hero.skill_tree[102]="special_bonus_armor_6"
            hero.skill_tree[103]="special_bonus_strength_20"
            hero.skill_tree[104]="special_bonus_attack_range_300"
            hero.skill_tree[105]="special_bonus_cooldown_reduction_15"
            hero.skill_tree[106]="special_bonus_agility_25"
            hero.skill_tree[107]="misaka_talent_2"
            hero.skill_tree[108]="misaka_talent_3"
        end
	elseif name=="npc_dota_hero_clinkz" then
		hero.skill_tree = {}
        for lv=1,18 do
			if lv==1 or lv==4 or lv==5 or lv==7 then
				hero.skill_tree[lv]="madokaruler"
			elseif lv==2 or lv==8 or lv==9 or lv==11 or lv==13 then
				hero.skill_tree[lv]="madokasave"
			elseif lv==3 or lv==14 or lv==16 or lv==17 then
				hero.skill_tree[lv]="madokalunhui"
			elseif lv==6 or lv==12 or lv==18 then
				hero.skill_tree[lv]="madokami"
			end
            hero.skill_tree[101]="madoka_talent_1"
            hero.skill_tree[102]="special_bonus_magic_resistance_25"
            hero.skill_tree[103]="special_bonus_hp_500"
            hero.skill_tree[104]="special_bonus_attack_speed_60"
            hero.skill_tree[105]="special_bonus_attack_range_250"
            hero.skill_tree[106]="special_bonus_lifesteal_20"
            hero.skill_tree[107]="special_bonus_strength_25"
            hero.skill_tree[108]="madoka_talent_2"
        end
	elseif name=="npc_dota_hero_zuus" then
		hero.skill_tree = {}
        for lv=1,18 do
			if lv==1 or lv==4 or lv==5 or lv==7 then
				hero.skill_tree[lv]="sashigayfire"
			elseif lv==2 or lv==8 or lv==9 or lv==11 or lv==13 then
				hero.skill_tree[lv]="thousand_bird"
			elseif lv==3 or lv==14 or lv==16 or lv==17 then
				hero.skill_tree[lv]="xielunyan"
			elseif lv==6 or lv==12 or lv==18 then
				hero.skill_tree[lv]="susanoo"
			end
            hero.skill_tree[101]="sasuke_talent_1"
            hero.skill_tree[102]="special_bonus_mp_regen_4"
            hero.skill_tree[103]="special_bonus_intelligence_15"
            hero.skill_tree[104]="special_bonus_all_stats_5"
            hero.skill_tree[105]="special_bonus_armor_15"
            hero.skill_tree[106]="special_bonus_attack_damage_65"
            hero.skill_tree[107]="sasuke_talent_2"
            hero.skill_tree[108]="sasuke_talent_3"
        end
	elseif name=="npc_dota_hero_juggernaut" then
		hero.skill_tree = {}
        for lv=1,18 do
			if lv==1 or lv==4 or lv==5 or lv==7 then
				hero.skill_tree[lv]="fengwang"
			elseif lv==2 or lv==8 or lv==9 or lv==11 or lv==13 then
				hero.skill_tree[lv]="saber_defend"
			elseif lv==3 or lv==14 or lv==16 or lv==17 then
				hero.skill_tree[lv]="magic_out"
			elseif lv==6 or lv==12 or lv==18 then
				hero.skill_tree[lv]="excalibur"
			end
            hero.skill_tree[101]="saber_talent_1"
            hero.skill_tree[102]="special_bonus_attack_speed_25"
            hero.skill_tree[103]="special_bonus_all_stats_8"
            hero.skill_tree[104]="special_bonus_strength_12"
            hero.skill_tree[105]="special_bonus_mp_regen_14"
            hero.skill_tree[106]="special_bonus_magic_resistance_25"
            hero.skill_tree[107]="special_bonus_attack_damage_45"
            hero.skill_tree[108]="saber_talent_2"
        end
	elseif name=="npc_dota_hero_earthshaker" then
	print("edward skill")
		hero.skill_tree = {}
        for lv=1,18 do
			if lv==1 or lv==4 or lv==5 or lv==7 then
				hero.skill_tree[lv]="alchemist"
			elseif lv==2 or lv==8 or lv==9 or lv==11 or lv==13 then
				hero.skill_tree[lv]="iron_arm"
			elseif lv==3 or lv==14 or lv==16 or lv==17 then
				hero.skill_tree[lv]="alchemist_str"
			elseif lv==6 or lv==12 or lv==18 then
				hero.skill_tree[lv]="edward_real"
			end
            hero.skill_tree[101]="edward_talent_1"
            hero.skill_tree[102]="special_bonus_exp_boost_20"
            hero.skill_tree[103]="special_bonus_strength_20"
            hero.skill_tree[104]="special_bonus_agility_25"
            hero.skill_tree[105]="special_bonus_agility_25"
            hero.skill_tree[106]="special_bonus_cooldown_reduction_15"
            hero.skill_tree[107]="edward_talent_2"
            hero.skill_tree[108]="special_bonus_respawn_reduction_60"
        end
	elseif name=="npc_dota_hero_tusk" then
		hero.skill_tree = {}
        for lv=1,18 do
			if lv==1 or lv==4 or lv==5 or lv==7 then
				hero.skill_tree[lv]="energysteal"
			elseif lv==2 or lv==8 or lv==9 or lv==11 or lv==13 then
				hero.skill_tree[lv]="into_shadow"
			elseif lv==3 or lv==14 or lv==16 or lv==17 then
				hero.skill_tree[lv]="reheal"
			elseif lv==6 or lv==12 or lv==18 then
				hero.skill_tree[lv]="energy_suck"
			end
            hero.skill_tree[101]="special_bonus_gold_income_10"
            hero.skill_tree[102]="shinobu_talent_1"
            hero.skill_tree[103]="special_bonus_all_stats_10"
            hero.skill_tree[104]="special_bonus_lifesteal_15"
            hero.skill_tree[105]="special_bonus_magic_resistance_30"
            hero.skill_tree[106]="special_bonus_lifesteal_20"
            hero.skill_tree[107]="special_bonus_respawn_reduction_60"
            hero.skill_tree[108]="shinobu_talent_2"
        end
	elseif name=="npc_dota_hero_troll_warlord" then
		hero.skill_tree = {}
        for lv=1,18 do
			if lv==1 or lv==4 or lv==5 or lv==7 then
				hero.skill_tree[lv]="card_attack"
			elseif lv==2 or lv==8 or lv==9 or lv==11 or lv==13 then
				hero.skill_tree[lv]="Dimensional_Rift"
			elseif lv==3 or lv==14 or lv==16 or lv==17 then
				hero.skill_tree[lv]="YinYang_Orbs"
			elseif lv==6 or lv==12 or lv==18 then
				hero.skill_tree[lv]="Fantasy_Seal"
			end
            hero.skill_tree[101]="reimu_talent_1"
            hero.skill_tree[102]="special_bonus_mp_250"
            hero.skill_tree[103]="special_bonus_attack_damage_30"
            hero.skill_tree[104]="special_bonus_all_stats_15"
            hero.skill_tree[105]="special_bonus_attack_speed_100"
            hero.skill_tree[106]="special_bonus_evasion_25"
            hero.skill_tree[107]="special_bonus_attack_damage_90"
            hero.skill_tree[108]="reimu_talent_2"
        end
	end
	if IsInTable(id,HERO_TANK) then
	 hero.item_tree = {	
    [1]= "item_travel_boots",	
    [2]= "item_echo_sabre", 
	[3]= "item_sange_and_yasha" ,
	[4]= "item_radiance",
	[5]= "item_abyssal_blade", 
	[6]= "item_lotus_orb",	
	[7]= 0,
	--[[
	[8]= "item_satanic",	
	[9]= "item_blade_mail",		
	[10]= "item_black_king_bar",
	[11]= "item_heart",	
	[12]= "item_assault",
	]]
}
				end
				if IsInTable(id,HERO_WARRIOR) then
					 hero.item_tree = {	
    [1]= "item_travel_boots",	
    [2]= "item_desolator", 
	[3]= "item_sange_and_yasha" ,
	[4]= "item_butterfly",
	[5]= "item_mjollnir", 
	[6]= "item_monkey_king_bar",	
	[7]= 0,
	--[[
	[8]= "item_butterfly",	
	[9]= "item_monkey_king_bar",		
	[10]= "item_moon_shard",
	[11]= "item_bloodthorn",	
	[12]= "item_skadi",
	]]
}
				end
				if IsInTable(id,HERO_MAGE) then
					hero.item_tree = {	
    [1]= "item_travel_boots",	
    [2]= "item_aether_lens", 
	[3]= "item_bloodstone" ,
	[4]= "item_shivas_guard",
	[5]= "item_holy", 
	[6]= "item_octarine_core",	
	[7]= 0,
	--[[
	[8]= "item_shivas_guard",	
	[9]= "item_cyclone",		
	[10]= "item_aether_lens",
	[11]= "item_bloodstone",	
	[12]= "item_ethereal_blade",
	]]
}
				end
	SetPlayerSlotInTeam(i,hero)
	--统计数据
	hero.stat_damage_hero = 0
	hero.stat_damage_siege = 0
	hero.stat_damage_physical = 0
	hero.stat_damage_magical = 0
	hero.stat_damage_taken = 0 --只统计受到敌方英雄的伤害
	hero.stat_heal = 0 --只统计对友方英雄的治疗

	if isAI and hero:IsRealHero() then
    print("AIstart")
		AIStart(hero)
	end
	--PrintTable(hero.item_tree)
	--PrintTable(hero.skill_tree)
end

function IsAI(id)
    local p = PlayerResource:GetPlayer(id)
    if p then
        local u = p:GetAssignedHero() 
        if u then
            if PlayerResource:GetConnectionState(id)==1 then
                return true
            end
        end
    end
    return false
end



function SetPlayerSlotInTeam(i,hero)
    local pid = nil
    local p = PlayerResource:GetPlayer(i)
    if p then
        for k=1,5 do
            pid = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, k)
            if i==pid then
                p.teamSlot = k
            end
            pid = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, k)
            if i==pid then
                p.teamSlot = k+5
            end
        end
        hero.teamSlot = p.teamSlot 
        SetPlayerColor(p,hero)
    end
end
function SetPlayerColor(p,hero)
    local i = p.teamSlot
    local v = Vector(120,120,120)
    if i==1 then
        v=Vector(33,100,255)
    elseif i==2 then
        v=Vector(33,255,200)
    elseif i==3 then
        v=Vector(200,33,255)
    elseif i==4 then
        v=Vector(255,255,33)
    elseif i==5 then
        v=Vector(255,128,33)
    elseif i==6 then
        v=Vector(255,128,200)
    elseif i==7 then
        v=Vector(200,200,255)
    elseif i==8 then
        v=Vector(100,180,255)
    elseif i==9 then
        v=Vector(33,255,33)
    elseif i==10 then
        v=Vector(150,75,33)
    end
    p.color=v
    hero.color=v
    PlayerResource:SetCustomPlayerColor(p:GetPlayerID(),v.x,v.y,v.z)
end

