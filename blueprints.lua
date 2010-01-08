require 'dokidoki.module' [[fighter, bomber, frigate, factory, laser, bomb, missile]]

local collision = require 'dokidoki.collision'
local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

fighter = game.make_blueprint('fighter',
  {'transform', scale_x=1, scale_y=1},
  {'sprite', resource='fighter_sprite'},
  {'collision', collision_type='ship', poly=collision.make_rectangle(12, 8)},
  {'ship', turn_speed=0.015, accel=0.1, hit_points=50},
  {'fighter_shooting'},
  {'fighter_ai'})

bomber = game.make_blueprint('bomber',
  {'transform', scale_x=3, scale_y=3},
  {'sprite', resource='fighter_sprite'},
  {'collision', collision_type='ship', poly=collision.make_rectangle(24, 16)},
  {'ship', turn_speed=0.03, accel=0.05, hit_points=200},
  {'bomber_shooting'},
  {'bomber_ai'})

frigate = game.make_blueprint('frigate',
  {'transform', scale_x=6, scale_y=6},
  {'sprite', resource='fighter_sprite'},
  {'collision', collision_type='ship', poly=collision.make_rectangle(48, 32)},
  {'ship', turn_speed=0.01, accel=0.01, hit_points=500},
  {'frigate_shooting'},
  {'frigate_ai'})

factory = game.make_blueprint('factory',
  {'transform', scale_x=30, scale_y=30},
  {'sprite', resource='fighter_sprite'},
  {'collision', collision_type='ship', poly=collision.make_rectangle(180, 120)},
  {'ship', turn_speed=0.001, accel=0.005, hit_points=10000},
  {'factory_ai'})
  
laser = game.make_blueprint('laser',
  {'transform', scale_x=32, scale_y=1},
  {'sprite'},
  {'collision', collision_type='bullet', poly=collision.make_rectangle(32, 1)},
  {'bullet'})
  
bomb = game.make_blueprint('bomb',
  {'transform', scale_x=4, scale_y=4},
  {'sprite'},
  {'collision', collision_type='bullet', poly=collision.make_rectangle(4, 4)},
  {'bullet'})  
  
missile = game.make_blueprint('missile',
  {'transform', scale_x=8, scale_y=2},
  {'sprite'},
  {'collision', collision_type='bullet', poly=collision.make_rectangle(8, 2)},
  {'ship', turn_speed=0.1, accel=0.15, hit_points=1},
  {'heatseeking_ai'})  

return get_module_exports()
