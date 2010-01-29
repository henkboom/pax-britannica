require 'dokidoki.module' [[ make ]]

local game = require 'dokidoki.game'
local kernel = require 'dokidoki.kernel'
local v2 = require 'dokidoki.v2'

local blueprints = require 'blueprints'

function make ()
  return game.make_game(
    {'update_setup', 'update', 'collision_registry', 'collision_check',
     'update_cleanup'},
    {'draw_setup', 'draw'},
    function (game)
      math.randomseed(os.time())
  
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
      game.init_component('log')
      game.init_component('fast_forward')
      game.init_component('the_one_button')
      
      function game.exit_handler.on_close()
        game.log.print_stats()
        kernel.abort_main_loop()
      end
  
      game.actors.new(blueprints.background,
        {'transform', pos=v2(0, 0)})
  
      game.init_component('particles')
  
      game.actors.new(blueprints.game_flow)
    end)
end

return get_module_exports()
