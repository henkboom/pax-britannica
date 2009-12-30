require 'dokidoki.module' [[]]

local kernel = require 'dokidoki.kernel'
local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

local blueprints = require 'blueprints'

kernel.start_main_loop(game.make_game(
  {'update'},
  {'draw_setup', 'draw'},
  function (game)
    game.init_component('exit_handler')
    game.init_component('keyboard')
    game.init_component('opengl_2d')
    game.opengl_2d.width = 1024
    game.opengl_2d.height = 768

    game.init_component('resources')

    game.actors.new(blueprints.fighter, {'transform', pos=v2(200, 100)})
    game.actors.new(blueprints.bomber, {'transform', pos=v2(300, 100)})
    game.actors.new(blueprints.frigate, {'transform', pos=v2(400, 100)})
    game.actors.new(blueprints.factory, {'transform', pos=v2(500, 100)})
  end))
