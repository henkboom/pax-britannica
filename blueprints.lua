require 'dokidoki.module'
[[ background, game_flow, fighter, bomber, frigate, selection_factory,
   player_factory, easy_enemy_factory, laser, bomb, missile ]]

local collision = require 'dokidoki.collision'
local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

background = game.make_blueprint('background',
  {'transform'},
  {'sprite', resource='background'})

game_flow = game.make_blueprint('game_flow',
  {'game_flow'})

fighter = game.make_blueprint('fighter',
  {'transform'},
  {'sprite', resource='fighter_sprite'},
  {'collision', collision_type='ship', poly=collision.make_rectangle(9, 6)},
  {'ship', turn_speed=0.025, accel=0.1, hit_points=40},
  {'fighter_shooting'},
  {'fighter_ai'})

bomber = game.make_blueprint('bomber',
  {'transform', scale_x=1, scale_y=1},
  {'sprite', resource='bomber_sprite'},
  {'collision', collision_type='ship', poly=collision.make_rectangle(22, 14)},
  {'ship', turn_speed=0.03, accel=0.05, hit_points=250},
  {'bomber_shooting'},
  {'bomber_ai'})

frigate = game.make_blueprint('frigate',
  {'transform', scale_x=1, scale_y=1},
  {'sprite', resource='frigate_sprite'},
  {'collision', collision_type='ship', poly=collision.make_rectangle(54, 36)},
  {'ship', turn_speed=0.01, accel=0.01, hit_points=1400},
  {'frigate_shooting'},
  {'frigate_ai'})

selection_factory = game.make_blueprint('selection_factory',
  {'transform'},
  {'sprite', resource='factory_sprite', color={0.2, 0.2, 0.2}},
  {'selector'})
  
player_factory = game.make_blueprint('factory',
  {'transform'},
  {'sprite', resource='factory_sprite'},
  {'collision', collision_type='ship', poly=collision.make_rectangle(180, 120)},
  {'ship', turn_speed=0.00028, accel=0.002, hit_points=20000},
  {'factory_ai'},
  {'resources'},
  {'production'},
  {'player_production'})
  
easy_enemy_factory = game.make_blueprint('factory',
  {'transform'},
  {'sprite', resource='factory_sprite'},
  {'collision', collision_type='ship', poly=collision.make_rectangle(180, 120)},
  {'ship', turn_speed=0.00028, accel=0.002, hit_points=20000},
  {'factory_ai'},
  {'resources'},
  {'production'},
  {'easy_enemy_production'})
  
laser = game.make_blueprint('laser',
  {'transform', scale_x=32, scale_y=1},
  {'sprite'},
  {'collision', collision_type='bullet', damage=10, poly=collision.make_rectangle(32, 1)},
  {'bullet'})
  
bomb = game.make_blueprint('bomb',
  {'transform', scale_x=1, scale_y=1},
  {'sprite', resource='bomb_sprite'},
  {'collision', collision_type='bullet', damage=200, poly=collision.make_rectangle(4, 4)},
  {'bullet'})  
  
missile = game.make_blueprint('missile',
  {'transform', scale_x=1, scale_y=1},
  {'sprite', resource='missile_sprite'},
  {'collision', collision_type='bullet', damage=40, poly=collision.make_rectangle(5, 2)},
  {'ship', turn_speed=0.055, accel=0.15, hit_points=1},
  {'heatseeking_ai'})

return get_module_exports()
