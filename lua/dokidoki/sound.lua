require "dokidoki.module"
[[ sound_effect_from_file, get_sound_effect_count ]]

require "SDL"
require "SDL_mixer"

import(SDL)
import(SDL_mixer)

will = require "dokidoki.private.will"

-- only supports simple sound effect playing for now

---- Sound Effects ------------------------------------------------------------

do
  local sound_effect_count = 0

  index =
  {
    play = function (self)
      if Mix_Playing(-1) < Mix_AllocateChannels(-1) then
        sdl_check(Mix_PlayChannel(-1, self.mix_chunk, 0) ~= -1)
      end
    end,
    delete = function (self)
      if self.mix_chunk then
        for i = 0, Mix_AllocateChannels(-1) - 1 do
          if Mix_Playing(i) ~= 0
             and Mix_SameChunk(Mix_GetChunk(i), self.mix_chunk) ~= 0 then
            Mix_HaltChannel(i)
          end
        end
        Mix_FreeChunk(self.mix_chunk)
        self.mix_chunk = false
        sound_effect_count = sound_effect_count - 1
      end
    end,
  }

  mt = {__index = index}

  function make_sound_effect(mix_chunk)
    local s = setmetatable({mix_chunk = mix_chunk}, mt)
    will.attach_will(s, function () s:delete() end)
    sound_effect_count = sound_effect_count + 1
    return s
  end

  function get_sound_effect_count()
    return sound_effect_count
  end
end

init_done = false
function sound_effect_from_file (filename)
  if not init_done then
    Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 512)
    init_done = true
  end
  return make_sound_effect(Mix_LoadWAV(filename))
end

function sdl_check(condition)
  if not condition then
    error(SDL_GetError())
    else
  end
end

return get_module_exports()
