require 'dokidoki.module' [[fighter, bomber, frigate, factory]]

local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

fighter = game.make_blueprint('fighter',
  {'transform', scale_x=2, scale_y=2},
  {'sprite', resource='fighter_sprite'},
  {'ship', turn_speed=0.05, accel=0.2},
  {'wasd_ship_control'})

bomber = game.make_blueprint('bomber',
  {'transform', scale_x=4, scale_y=4},
  {'sprite', resource='fighter_sprite'},
  {'ship', turn_speed=0.02, accel=0.1},
  {'wasd_ship_control'})

frigate = game.make_blueprint('frigate',
  {'transform', scale_x=8, scale_y=8},
  {'sprite', resource='fighter_sprite'},
  {'ship', turn_speed=0.01, accel=0.02},
  {'wasd_ship_control'})

factory = game.make_blueprint('factory',
  {'transform', scale_x=30, scale_y=30},
  {'sprite', resource='fighter_sprite'},
  {'ship', turn_speed=0.001, accel=0.005},
  {'wasd_ship_control'})

return get_module_exports()
