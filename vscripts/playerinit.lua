


function initplayerstats()

print(initplayerstats)
   local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','') 
   math.randomseed(tonumber(timeTxt))
   PlayerStats={}
   --[[playerid=0
       ...
       playerid=9
     ]]
   for i=0,9 do
     PlayerStats[i]={}  --每个玩家的数据包
     PlayerStats[i]['changdu']=0
   end
 
   --初始化刷怪
  local temp_zuoshang=Entities:FindByName(nil,"zuoshang") --找到左上的实体
  zuoshang_zuobiao=temp_zuoshang:GetAbsOrigin()

  local temp_youxia=Entities:FindByName(nil,"youxia") --找到左上的实体
  youxia_zuobiao=temp_youxia:GetAbsOrigin()
 --[[
  local temp_zuoshang1=Entities:FindByName(nil,"zuoshang1") --找到左上的实体
  zuoshang1_zuobiao=temp_zuoshang1:GetAbsOrigin()

  local temp_youxia1=Entities:FindByName(nil,"youxia1") --找到左上的实体
  youxia1_zuobiao=temp_youxia1:GetAbsOrigin()

   ]]


for i=0,4 do

createunit("npc_dota_neutral_kobold") -- "Kobold"
createunit("npc_dota_neutral_kobold_tunneler") -- "Kobold Soldier"
createunit("npc_dota_neutral_kobold_taskmaster") -- "Kobold Foreman"
createunit("npc_dota_neutral_centaur_outrunner") -- "Centaur Courser"
createunit("npc_dota_neutral_centaur_khan") -- "Centaur Conqueror"
createunit("npc_dota_neutral_fel_beast") -- "Fell Spirit"
createunit("npc_dota_neutral_polar_furbolg_champion") -- "Hellbear"
createunit("npc_dota_neutral_polar_furbolg_ursa_warrior") -- "Hellbear Smasher"
createunit("npc_dota_neutral_mud_golem") -- "Mud Golem"
createunit("npc_dota_neutral_ogre_mauler") -- "Ogre Bruiser"
createunit("npc_dota_neutral_ogre_magi") -- "Ogre Frostmage"
createunit("npc_dota_neutral_giant_wolf") -- "Giant Wolf"
createunit("npc_dota_neutral_alpha_wolf") -- "Alpha Wolf"
createunit("npc_dota_neutral_wildkin") -- "Wildwing"
createunit("npc_dota_neutral_enraged_wildkin") -- "Wildwing Ripper"
createunit("npc_dota_neutral_satyr_soulstealer") -- "Satyr Mindstealer"
createunit("npc_dota_neutral_satyr_hellcaller") -- "Satyr Tormenter"
createunit("npc_dota_neutral_satyr_trickster") -- "Satyr Banisher"
createunit("npc_dota_neutral_jungle_stalker") -- "Ancient Stalker"
createunit("npc_dota_neutral_elder_jungle_stalker") -- "Ancient Primal Stalker"
--createunit("npc_dota_neutral_blue_dragonspawn_sorcerer") -- "Ancient Drakken Sentinel"
--createunit("npc_dota_neutral_blue_dragonspawn_overseer") -- "Ancient Drakken Armorer"
createunit("npc_dota_neutral_rock_golem") -- "Ancient Rock Golem"
createunit("npc_dota_neutral_granite_golem") -- "Ancient Granite Golem"
createunit("npc_dota_neutral_big_thunder_lizard") -- "Ancient Thunderhide"
createunit("npc_dota_neutral_small_thunder_lizard") -- "Ancient Rumblehide"
createunit("npc_dota_neutral_black_drake") -- "Ancient Black Drake"
createunit("npc_dota_neutral_black_dragon") -- "Ancient Black Dragon"
createunit("npc_dota_neutral_gnoll_assassin") -- "Vhoul Assassin"
createunit("npc_dota_neutral_ghost") -- "Ghost"
createunit("npc_dota_neutral_dark_troll") -- "Hill Troll"
createunit("npc_dota_neutral_dark_troll_warlord") -- "Dark Troll Summoner"
createunit("npc_dota_neutral_forest_troll_berserker") -- "Hill Troll Berserker"
createunit("npc_dota_neutral_forest_troll_high_priest") -- "Hill Troll Priest"
createunit("npc_dota_neutral_harpy_scout") -- "Harpy Scout"

createunit("npc_dota_neutral_black_drake") -- "Ancient Granite Golem"
createunit("npc_dota_enraged_wildkin_tornado") -- "Ancient Thunderhide"
createunit("npc_dota_neutral_ice_shaman") -- "Ancient Rumblehide"
createunit("npc_dota_neutral_frostbitten_golem") -- "Ancient Black Drake"
createunit("npc_dota_neutral_warpine_raider") -- "Ancient Black Dragon"

end

end


function createunit(unitname)
  local location=Vector(math.random(youxia_zuobiao.x-zuoshang_zuobiao.x)+zuoshang_zuobiao.x,math.random(youxia_zuobiao.y-zuoshang_zuobiao.y)+zuoshang_zuobiao.y,youxia_zuobiao.z)
  local unit=CreateUnitByName(unitname, location, true, nil, nil, DOTA_TEAM_NEUTRALS)
  print (unitname)
  unit:SetContext("name",unitname,0)
  --unit:SetMaximumGoldBounty(350)
  --unit:SetMinimumGoldBounty(250)
end

function createbaby(playerid)
  local followed_unit=PlayerStats[playerid]['group'][PlayerStats[playerid]['group_pointer']]
  local chaoxiang=followed_unit:GetForwardVector()
  local position=followed_unit:GetAbsOrigin()
  local newposition=position-chaoxiang*100


  local new_unit=CreateUnitByName("littlebug", newposition, true, nil, nil, followed_unit:GetTeam())
  new_unit:SetForwardVector(chaoxiang)
  GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
      new_unit:MoveToNPC(followed_unit)
      return 0.2
     end,0) 
  --new_unit:SetControllableByPlayer(playerid, true)
  PlayerStats[playerid]['group_pointer']=PlayerStats[playerid]['group_pointer']+1
  PlayerStats[playerid]['group'][PlayerStats[playerid]['group_pointer']]=new_unit


end	