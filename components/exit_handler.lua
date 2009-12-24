local kernel = require 'dokidoki.kernel'

on_close = on_close or kernel.abort_main_loop

game.actors.new_generic('exit_handler', function ()
  function handle_event(event)
    if event.type == 'quit' then
      on_close()
    end
  end
end)
