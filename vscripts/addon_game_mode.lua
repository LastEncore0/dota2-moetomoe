-- Generated from template
require('util')
require('timers')
require('physics')
require('barebones')
require('playerinit')
require("DamageSystem")
require("ai")
-- require("talents/talents")
require("mtmhero")
require("system")
require("statcollection/init")
temp_flag = 0

END_GAME_ON_KILLS = true        -- Should the game end after a certain number of kills? 是否击杀数量到一定值结束游戏
KILLS_TO_END_GAME_FOR_TEAM = 30 -- How many kills for a team should signify an end of game? 结束游戏的击杀数量值


gameMaps = {
       "dota",
       "mtmfs"
}

if mtm == nil then
       mtm = class({})
end

if mtmSpawner == nil then
       mtmSpawner = class({})
end

function Precache(context)
       --[[
	This function is used to precache resources/units/items/abilities that will be needed
	for sure in your game and that cannot or should not be precached asynchronously or
	after the game loads.
	See GameMode:PostLoadPrecache() in barebones.lua for more information
	]]
       print("[BAREBONES] Performing pre-load precache")
       -- Particles can be precached individually or by folder
       -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
       PrecacheResource("particle",
              "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
       PrecacheResource("particle_folder", "particles/test_particle", context)
       -- Models can also be precached by folder or individually
       -- PrecacheModel should generally used over PrecacheResource for individual models
       PrecacheResource("model_folder", "particles/heroes/antimage", context)
       PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
       PrecacheResource("model", "models/props_structures/tower_dragon_black.vmdl", context)
       PrecacheResource("model", "models/props_structures/tower_dragon_white.vmdl", context)
       PrecacheModel("models/heroes/viper/viper.vmdl", context)
       -- Sounds can precached here like anything else
       PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)
       -- Entire items can be precached by name
       -- Abilities can also be precached in this way despite the name
       PrecacheItemByNameSync("example_ability", context)
       PrecacheItemByNameSync("item_example_item", context)
       -- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
       -- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
       PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
       PrecacheUnitByNameSync("npc_dota_hero_enigma", context)
end

-- Create the game mode when we activate
function Activate()
       GameRules.GameMode = GameMode()
       GameRules.GameMode:InitGameMode()
       GameRules.GameMode:CaptureGameMode()
       GameRules.AddonTemplate = mtm()
       GameRules.AddonTemplate:InitGameMode()
end

function mtm:InitGameMode()
       print("Template addon is loaded.")
       GameRules:GetGameModeEntity():SetThink("OnThink", self, "GlobalThink", 2)
       --监听游戏进度
       ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(mtm, "OnGameRulesStateChange"), self)
       ListenToGameEvent('entity_killed', Dynamic_Wrap(mtm, 'OnEntityKilled'), self)

       --监听玩家选择英雄
       ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(mtm, "OnHeroPick"), self)

       --监听英雄升级
       ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap(mtm, "OnHeroLevelUp"), self)



       -- ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CAddonTemplateGameMode,"OnGameRulesStateChange"), self)
       -- ListenToGameEvent("npc_spawned", Dynamic_Wrap(mtm, "OnNPCSpawned"), self)
       --监听UI事件,这是新的事件管理器
       -- CustomGameEventManager:RegisterListener( "myui_open", OnMyUIOpen )
       -- CustomGameEventManager:RegisterListener( "js_to_lua", OnJsToLua )
       --CustomGameEventManager:RegisterListener( "lua_to_js", OnLuaToJs )
       --CustomUI:DynamicHud_Create(keys.PlayerID,"MyUIMain","file://{resources}/layout/custom_game/mtmpedia.xml",nil)
       --CustomUI:DynamicHud_Create(keys.PlayerID,"MyUIMain","file://{resources}/layout/custom_game/mtmpedia_herobutton.xml",nil)
       if temp_flag == 0 then
              initplayerstats()
              temp_flag = 1
       end
       --初始化单位
       local Erobert1 = Entities:FindByName(nil, "robert1") --找到机器人位置
       local Erobert2 = Entities:FindByName(nil, "robert2") --找到机器人位置
       local Erobert7 = Entities:FindByName(nil, "robert7") --找到机器人位置
       local Erobert11 = Entities:FindByName(nil, "robert11") --找到机器人位置
       local elder = Entities:FindByName(nil, "elder") --找到elder位置

       robert1 = Erobert1:GetAbsOrigin()
       robert2 = Erobert2:GetAbsOrigin()
       --  robert3=Erobert3:GetAbsOrigin()
       --  robert4=Erobert4:GetAbsOrigin()
       --  robert5=Erobert5:GetAbsOrigin()
       --  robert6=Erobert6:GetAbsOrigin()
       robert7 = Erobert7:GetAbsOrigin()
       -- robert8=Erobert8:GetAbsOrigin()
       --  robert9=Erobert9:GetAbsOrigin()
       -- robert10=Erobert10:GetAbsOrigin()
       robert11 = Erobert11:GetAbsOrigin()
       --   -- robert12=Erobert12:GetAbsOrigin()
       --   robert13=Erobert13:GetAbsOrigin()
       elderorg = elder:GetAbsOrigin()

       kuangyu1 = CreateUnitByName("guangyu", robert1, true, nil, nil, DOTA_TEAM_NEUTRALS)
       kuangyu2 = CreateUnitByName("guangyu", robert2, true, nil, nil, DOTA_TEAM_NEUTRALS)
       -- kuangyu3 = CreateUnitByName("guangyu", robert3, true, nil, nil, DOTA_TEAM_NEUTRALS)
       --  kuangyu4 = CreateUnitByName("guangyu", robert4, true, nil, nil, DOTA_TEAM_NEUTRALS)
       -- kuangyu5 = CreateUnitByName("guangyu", robert5, true, nil, nil, DOTA_TEAM_NEUTRALS)
       --  kuangyu6 = CreateUnitByName("guangyu", robert6, true, nil, nil, DOTA_TEAM_NEUTRALS)
       kuangyu7 = CreateUnitByName("guangyu", robert7, true, nil, nil, DOTA_TEAM_NEUTRALS)
       --  kuangyu8 = CreateUnitByName("guangyu", robert8, true, nil, nil, DOTA_TEAM_NEUTRALS)
       --  kuangyu9 = CreateUnitByName("guangyu", robert9, true, nil, nil, DOTA_TEAM_NEUTRALS)
       --  kuangyu10 = CreateUnitByName("guangyu", robert10, true, nil, nil, DOTA_TEAM_NEUTRALS)
       kuangyu11 = CreateUnitByName("guangyu", robert11, true, nil, nil, DOTA_TEAM_NEUTRALS)



       -- kuangyu12 = CreateUnitByName("guangyu", robert12, true, nil, nil, DOTA_TEAM_NEUTRALS)
       -- kuangyu13 = CreateUnitByName("guangyu", robert13, true, nil, nil, DOTA_TEAM_NEUTRALS)
       mogic = CreateUnitByName("elder", elderorg, true, nil, nil, DOTA_TEAM_NEUTRALS)


       local Eflame1 = Entities:FindByName(nil, "flame1") --找到机器人位置
       local Eflame2 = Entities:FindByName(nil, "flame2") --找到机器人位置
       local Eflame3 = Entities:FindByName(nil, "flame3") --找到机器人位置
       local Eflame4 = Entities:FindByName(nil, "flame4") --找到机器人位置


       flame1 = Eflame1:GetAbsOrigin()
       flame2 = Eflame2:GetAbsOrigin()
       flame3 = Eflame3:GetAbsOrigin()
       flame4 = Eflame4:GetAbsOrigin()



       flame1 = CreateUnitByName("flame_1", flame1, true, nil, nil, DOTA_TEAM_NEUTRALS)
       flame2 = CreateUnitByName("flame_1", flame2, true, nil, nil, DOTA_TEAM_NEUTRALS)
       flame3 = CreateUnitByName("flame", flame3, true, nil, nil, DOTA_TEAM_NEUTRALS)
       flame4 = CreateUnitByName("flame", flame4, true, nil, nil, DOTA_TEAM_NEUTRALS)
       -- ApplyDataDrivenModifier( hCaster, hTarget, pszModifierName, hModifierTable )
       -- Applies a data driven modifier to the target
end

-- Evaluate the state of the game
function mtm:OnThink()
       if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
              -- print( "Template addon script is running." )
       elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
              return nil
       end
       return 1
end

function mtm:OnGameRulesStateChange(keys)
       print("OnGameRulesStateChange")
       DeepPrintTable(keys)  --详细打印传递进来的表


       --获取游戏进度
       local newState = GameRules:State_Get()

       if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
              print("Player begin select hero") --玩家处于选择英雄界面
              InitConst()
              --InitConst()
       elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
              print("Player ready game begin") --玩家处于游戏准备状态
              GameRules:SendCustomMessage("#DOTA_Tips_Command_AI", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
              --GameRules:SendCustomMessage("#DOTA_Tips_Command_More", DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS, 0)
       elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
              print("Player game begin") --玩家开始游戏
              --if AI_HASAI then
              AIObserveStart()
              -- end
       end
end

function AIObserveStart()
       Timers:CreateTimer(30, function()
              if GameRules:State_Get() >= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
                     local heroes = HeroList:GetAllHeroes()
                     for _, hero in pairs(heroes) do
                            if hero:IsAlive() then
                                   AILineGank_Check(hero)
                            end
                     end
              end
              return 1
       end)
end

function AISelectHero(mode) --mode=0,全部填充, mode=1,仅圣盟, mode=2,仅林登
       local k = 0
       AI_HASAI = true
       Timers:CreateTimer(function()
              local pot = PlayerResource:GetPlayer(k)
              if PlayerResource:GetConnectionState(k) == 0 then
                     if mode == 0 then
                            local count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
                            if count < 5 then
                                   AddBotToTeam(DOTA_TEAM_GOODGUYS)
                                   --Tutorial:AddBot(GetRandomHero(),"","",true)
                            else
                                   AddBotToTeam(DOTA_TEAM_BADGUYS)
                                   --Tutorial:AddBot(GetRandomHero(),"","",false)
                            end
                     elseif mode == 1 then
                            local count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
                            if count < 5 then
                                   AddBotToTeam(DOTA_TEAM_GOODGUYS)
                                   --Tutorial:AddBot(GetRandomHero(),"","",true)
                            end
                     elseif mode == 2 then
                            local count = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
                            if count < 5 then
                                   AddBotToTeam(DOTA_TEAM_BADGUYS)
                                   --Tutorial:AddBot(GetRandomHero(),"","",false)
                            end
                     end
              end
              k = k + 1
              if k > 9 then
                     return nil
              else
                     return 1
              end
       end)
end

function mtm:OnHeroPick(keys)
       print("Pick A Hero")
       DeepPrintTable(keys) --详细打印传递进来的表
       local i = keys.player
       local heroindex = keys.heroindex
       local hero = EntIndexToHScript(heroindex)
       --local ability=hero:FindAbilityByName("hero_upgrade")
       --ability:SetLevel(1)
       InitHero(hero)
end

function InitHero(hero)
       Timers:CreateTimer(0.5, function()
              InitHeroTrig(hero)
              Talents.OnUnitCreate(hero)
       end)

       --print(hero:GetUnitName()..hero:GetModelScale())
end

function mtm:OnHeroLevelUp(keys)
       --DeepPrintTable(keys)
       local i = keys.player --未-1
       local p = PlayerResource:GetPlayer(i - 1)
       local lv = keys.level
       local hero = p:GetAssignedHero()
       local name = hero:GetUnitName()
       --print(lv.." "..pt)


       --if PlayerResource:IsFakeClient(i-1) then --AI学技能
       if IsAI(i - 1) then
              Timers:CreateTimer(0.1, function()
                     AILearnAbility(hero, lv)
                     return nil
              end)
       end
end

function mtm:OnEntityKilled(keys)
       local unit = EntIndexToHScript(keys.entindex_killed)
       local label = unit:GetContext("name")


       --判断是不是野怪

       if label then
              if label == "npc_dota_neutral_kobold" then
                     createunit("npc_dota_neutral_kobold")
              end -- Koboldif label=="
              if label == "npc_dota_neutral_kobold_tunneler" then
                     createunit("npc_dota_neutral_kobold_tunneler")
              end -- Kobold Soldierif label=="
              if label == "npc_dota_neutral_kobold_taskmaster" then
                     createunit("npc_dota_neutral_kobold_taskmaster")
              end -- Kobold Foremanif label=="
              if label == "npc_dota_neutral_centaur_outrunner" then
                     createunit("npc_dota_neutral_centaur_outrunner")
              end -- Centaur Courserif label=="
              if label == "npc_dota_neutral_centaur_khan" then
                     createunit("npc_dota_neutral_centaur_khan")
              end -- Centaur Conquerorif label=="
              if label == "npc_dota_neutral_fel_beast" then
                     createunit("npc_dota_neutral_fel_beast")
              end -- Fell Spiritif label=="
              if label == "npc_dota_neutral_polar_furbolg_champion" then
                     createunit("npc_dota_neutral_polar_furbolg_champion")
              end -- Hellbearif label=="
              if label == "npc_dota_neutral_polar_furbolg_ursa_warrior" then
                     createunit("npc_dota_neutral_polar_furbolg_ursa_warrior")
              end -- Hellbear Smasherif label=="
              if label == "npc_dota_neutral_mud_golem" then
                     createunit("npc_dota_neutral_mud_golem")
              end -- Mud Golemif label=="
              if label == "npc_dota_neutral_ogre_mauler" then
                     createunit("npc_dota_neutral_ogre_mauler")
              end -- Ogre Bruiserif label=="
              if label == "npc_dota_neutral_ogre_magi" then
                     createunit("npc_dota_neutral_ogre_magi")
              end -- Ogre Frostmageif label=="
              if label == "npc_dota_neutral_giant_wolf" then
                     createunit("npc_dota_neutral_giant_wolf")
              end -- Giant Wolfif label=="
              if label == "npc_dota_neutral_alpha_wolf" then
                     createunit("npc_dota_neutral_alpha_wolf")
              end -- Alpha Wolfif label=="
              if label == "npc_dota_neutral_wildkin" then
                     createunit("npc_dota_neutral_wildkin")
              end -- Wildwingif label=="
              if label == "npc_dota_neutral_enraged_wildkin" then
                     createunit("npc_dota_neutral_enraged_wildkin")
              end -- Wildwing Ripperif label=="
              if label == "npc_dota_neutral_satyr_soulstealer" then
                     createunit("npc_dota_neutral_satyr_soulstealer")
              end -- Satyr Mindstealerif label=="
              if label == "npc_dota_neutral_satyr_hellcaller" then
                     createunit("npc_dota_neutral_satyr_hellcaller")
              end -- Satyr Tormenterif label=="
              if label == "npc_dota_neutral_satyr_trickster" then
                     createunit("npc_dota_neutral_satyr_trickster")
              end -- Satyr Banisherif label=="
              if label == "npc_dota_neutral_jungle_stalker" then
                     createunit("npc_dota_neutral_jungle_stalker")
              end -- Ancient Stalkerif label=="
              if label == "npc_dota_neutral_rock_golem" then
                     createunit("npc_dota_neutral_rock_golem")
              end -- Ancient Rock Golemif label=="
              if label == "npc_dota_neutral_granite_golem" then
                     createunit("npc_dota_neutral_granite_golem")
              end -- Ancient Granite Golemif label=="
              if label == "npc_dota_neutral_big_thunder_lizard" then
                     createunit("npc_dota_neutral_big_thunder_lizard")
              end -- Ancient Thunderhideif label=="
              if label == "npc_dota_neutral_small_thunder_lizard" then
                     createunit("npc_dota_neutral_small_thunder_lizard")
              end -- Ancient Rumblehideif label=="
              if label == "npc_dota_neutral_black_drake" then
                     createunit("npc_dota_neutral_black_drake")
              end -- Ancient Black Drakeif label=="
              if label == "npc_dota_neutral_black_dragon" then
                     createunit("npc_dota_neutral_black_dragon")
              end -- Ancient Black Dragonif label=="
              if label == "npc_dota_neutral_gnoll_assassin" then
                     createunit("npc_dota_neutral_gnoll_assassin")
              end -- Vhoul Assassinif label=="
              if label == "npc_dota_neutral_ghost" then
                     createunit("npc_dota_neutral_ghost")
              end -- Ghostif label=="
              if label == "npc_dota_neutral_dark_troll" then
                     createunit("npc_dota_neutral_dark_troll")
              end -- Hill Trollif label=="
              if label == "npc_dota_neutral_dark_troll_warlord" then
                     createunit("npc_dota_neutral_dark_troll_warlord")
              end -- Dark Troll Summonerif label=="
              if label == "npc_dota_neutral_forest_troll_berserker" then
                     createunit("npc_dota_neutral_forest_troll_berserker")
              end -- Hill Troll Berserkerif label=="
              if label == "npc_dota_neutral_forest_troll_high_priest" then
                     createunit("npc_dota_neutral_forest_troll_high_priest")
              end -- Hill Troll Priestif label=="
              if label == "npc_dota_neutral_harpy_scout" then
                     createunit("npc_dota_neutral_harpy_scout")
              end -- Harpy Scoutif label=="	
              if label == "npc_dota_neutral_elder_jungle_stalker" then
                     createunit("npc_dota_neutral_elder_jungle_stalker")
              end -- Harpy Scoutif label=="	
              if label == "npc_dota_neutral_black_drake" then
                     createunit("npc_dota_neutral_black_drake")
              end -- Dark Troll Summonerif label=="
              if label == "npc_dota_enraged_wildkin_tornado" then
                     createunit("npc_dota_enraged_wildkin_tornado")
              end -- Hill Troll Berserkerif label=="
              if label == "npc_dota_neutral_ice_shaman" then
                     createunit("npc_dota_neutral_ice_shaman")
              end -- Hill Troll Priestif label=="
              if label == "npc_dota_neutral_frostbitten_golem" then
                     createunit("npc_dota_neutral_frostbitten_golem")
              end -- Harpy Scoutif label=="	
              if label == "npc_dota_neutral_warpine_raider" then
                     createunit("npc_dota_neutral_warpine_raider")
              end -- Harpy Scoutif label=="
       end
end

function mtm:OnGameRulesStateChange(keys)
       --        local state = GameRules:State_Get()

       if state == DOTA_GAMERULES_STATE_PRE_GAME then
              --调用UI
       end
end

--[[function CAddonTemplateGameMode:OnGameRulesStateChange( keys )
 --        local state = GameRules:State_Get()

 --        if state == DOTA_GAMERULES_STATE_PRE_GAME then
                   --调用UI
  --                 CustomUI:DynamicHud_Create(-1,"MyUIButton","file://{resources}/layout/custom_game/MyUI_button.xml",nil)
 --     end
end

function OnMyUIOpen( index,keys )
         --index 是事件的index值
         --keys 是一个table，固定包含一个触发的PlayerID，其余的是传递过来的数据
         CustomUI:DynamicHud_Create(keys.PlayerID,"MyUIMain","file://{resources}/layout/custom_game/MyUI_main.xml",nil)
end

function OnJsToLua( index,keys )
         print("num:"..keys.num.." str:"..tostring(keys.str))
         CustomUI:DynamicHud_Destroy(keys.PlayerID,"MyUIMain")
end

function OnLuaToJs( index,keys )
         CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(keys.PlayerID), "on_lua_to_js", {str="Lua"} )
         CustomUI:DynamicHud_Destroy(keys.PlayerID,"MyUIMain")
End
	]]
