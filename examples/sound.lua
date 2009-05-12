require "dokidoki.module" [[]]

require "luagl"
require "SDL"
import(SDL)

kernel = require "dokidoki.kernel"
sound = require "dokidoki.sound"

function make_sound_scene ()
  local sfx = false
  local sfx2 = false

  local function handle_event (event)
    if event.type == SDL_QUIT or
       event.type == SDL_KEYDOWN and event.key == SDLK_ESCAPE then
      kernel.abort_main_loop()
    elseif event.type == SDL_KEYDOWN and event.key == SDLK_1 then
      if not sfx then sfx = sound.sound_effect_from_file("brouing.wav") end
      sfx:play()
    elseif event.type == SDL_KEYDOWN and event.key == SDLK_2 then
      if not sfx2 then sfx2 = sound.sound_effect_from_file("blip.wav") end
      sfx2:play()
    end
  end

  local do_nothing = function () end

  return {handle_event = handle_event, update = do_nothing, draw = do_nothing}
end

kernel.start_main_loop(make_sound_scene())

