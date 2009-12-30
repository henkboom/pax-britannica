require 'dokidoki.module' [[fighter, bomber, frigate, factory]]

local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

fighter = game.make_blueprint('fighter',
  {'transform', scale_x=2, scale_y=2},
  {'sprite', resource='fighter_sprite'},
  {'ship', turn_speed=math.pi/60, accel=0.15},
  {'wasd_ship_control'})

bomber = game.make_blueprint('bomber',
  {'transform', scale_x=2, scale_y=2},
  {'sprite', resource='fighter_sprite'},
  {'ship', turn_speed=math.pi/60, accel=0.15},
  {'wasd_ship_control'})

frigate = game.make_blueprint('frigate',
  {'transform', scale_x=2, scale_y=2},
  {'sprite', resource='fighter_sprite'},
  {'ship', turn_speed=math.pi/60, accel=0.15},
  {'wasd_ship_control'})

factory = game.make_blueprint('factory',
  {'transform', scale_x=2, scale_y=2},
  {'sprite', resource='fighter_sprite'},
  {'ship', turn_speed=math.pi/60, accel=0.15},
  {'wasd_ship_control'})

return get_module_exports()
