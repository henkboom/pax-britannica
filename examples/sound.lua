require "dokidoki.module" [[]]

require "glfw"

kernel = require "dokidoki.kernel"
sound = require "dokidoki.sound"

function make_sound_scene ()
  local sfx = false
  local sfx2 = false

  local function handle_event (event)
    if event.type == 'quit' or
       event.type == 'key' and event.is_down and event.key == glfw.KEY_ESC then
      kernel.abort_main_loop()
    elseif event.type == 'key' and event.is_down
           and event.key == ("1"):byte() then
      if not sfx then sfx = sound.sound_effect_from_file("brouing.wav") end
      sfx:play()
    elseif event.type == 'key' and event.is_down
           and event.key == ("2"):byte() then
      if not sfx2 then sfx2 = sound.sound_effect_from_file("blip.wav") end
      sfx2:play()
    end
  end

  local do_nothing = function () end

  return {handle_event = handle_event, update = do_nothing, draw = do_nothing}
end

kernel.start_main_loop(make_sound_scene())

