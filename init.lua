require 'dokidoki.module' [[]]

local kernel = require 'dokidoki.kernel'
local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

local blueprints = require 'blueprints'

kernel.set_video_mode(1024, 768)
kernel.start_main_loop(game.make_game(
  {'update_setup', 'update', 'collision_registry', 'collision_check',
   'update_cleanup'},
  {'draw_setup', 'draw'},
  function (game)
    game.init_component('exit_handler')
    game.init_component('keyboard')
    game.init_component('opengl_2d')
    game.opengl_2d.width = 1024
    game.opengl_2d.height = 768

    game.init_component('constants')
    game.init_component('collision')
    game.init_component('resources')
    game.init_component('targeting')
    game.init_component('tracing')

    game.actors.new(blueprints.background,
      {'transform', pos=v2(0, 0)})
    game.actors.new(blueprints.player_factory,
      {'transform', pos=v2(500, 200)},
      {'ship', player=1})
    game.actors.new(blueprints.easy_enemy_factory,
      {'transform', pos=v2(500, 600), facing=v2(-1, 0)},
      {'ship', player=2})    
  end))
