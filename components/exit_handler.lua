--- dokidoki.components.exit_handler
--- ================================
---
--- Allows an action to be taken when an exit event is received.
---
--- By default `kernel.abort_main_loop()` is called, assign another function to
--- `exit_handler.on_close` to do something else:
---
---     function game.exit_handler.on_close()
---       -- do something
---     end

--- Implementation
--- --------------

local kernel = require 'dokidoki.kernel'

on_close = on_close or kernel.abort_main_loop

game.actors.new_generic('exit_handler', function ()
  function handle_event(event)
    if event.type == 'quit' then
      on_close()
    end
  end
end)
