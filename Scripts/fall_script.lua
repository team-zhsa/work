--Ceiling dropping system (WIP)
--Reproduces the "fall from uper floors" effects

--Usage : Call this script from any game launching system or use the event manager script to set the metatables then do your maps as usuel

--Extracting actual destination and ground from teletransporters since map;on_started(destination) dosen't take special destinations in account, then stirong it to a savegame variable lCan be useful for dungeons like Skull Dungeon (Level 3 of ALTTP, which has many hole entrances).
--Note, here, everything is in a single script, but in a real project you may have multiple file (one for each metatable)

local teletransporter_meta=sol.main.get_metatable("teletransporter")
local map_meta=sol.main.get_metatable("map")

function teletransporter_meta:on_activated()
  local game=self:get_game()
  local ground=self:get_map():get_ground(game:get_hero():get_position())
  game:set_value("tp_ground",ground)
end

--the actual trigger
function map_meta:on_started(destination)
  local hero=self:get_hero()
  local game=self:get_game()
  local x,y=hero:get_position()
  local ground=game:get_value("tp_ground")
  if ground=="hole" then
    --Falling from the ceiling
    hero:set_visible(false)
    hero:freeze()
    --disabling teletransoprters to avoid
    local disabled_teletransoprters={}
    for t in self:get_entities_by_type("teletransporter") do
      if t:is_enabled() then
        disabled_teletransporters[#disabled_teletransporters+1]=v
        t:set_enabled(false)
      end
    end
    --Creating a "stunt actor" moving vertically from the ceiling
    local falling_hero=self:create_custom_entity({
      name="falling_link",
      x=x,
      y=math.max(y-100,24),
      direction=0,
      layer=self:get_max_layer(),
      sprite=hero:get_tunic_sprite_id(),
      width=24,
      height=24,
    })
    falling_hero:get_sprite():set_animation("stopped")
    falling_hero:set_can_traverse_ground("wall",true)
    falling_hero:set_can_traverse_ground("empty",true)
    falling_hero:set_can_traverse_ground("traversable",true)

    --Creating a reception platform (prevents the hero from falling into consecutive holes during the animation)
    local platform=self:create_custom_entity({
      name="platform",
      direction=0,
      layer=layer,
      x=x,
      y=y,
      width=32,
      height=32,
      sprite="entities/shadow",
    })
    platform:bring_to_front()
    platform:get_sprite():set_animation("big")
    platform:set_modified_ground("traversable")

    --Creating the actual movement for the stunt actor
    local movement=sol.movement.create("target")
    movement:set_target(x,y)
    movement:set_speed(96)  --The falling speed.
    --Spinning the stunt actor on itself
    sol.timer.start(falling_hero, 100, function()
      falling_hero:set_direction((falling_hero:get_direction()+1)%4)
      return true
    end)
    movement:start(falling_hero, function()
      --Movement is now complete, restoring the disabled teletransoprters and getting rid of the temporary entities
      sol.audio.play_sound("hero_lands")
      platform:remove()
      falling_hero:remove()
      hero:set_visible(true)
      hero:unfreeze()
      for _,t in pairs(disabled_teletransporters) do
        t:set_enabled(true)
      end
    end)
    --]]
  end
end