local graphics = require 'dokidoki.graphics'

background = graphics.sprite_from_image('sprites/background.png', nil, {0, 0})

fighter_sprite = graphics.sprite_from_image('sprites/fighter.png', nil, 'center')
bomber_sprite = graphics.sprite_from_image('sprites/bomber.png', nil, 'center')
frigate_sprite = graphics.sprite_from_image('sprites/frigate.png', nil, 'center')

factory_sprite = graphics.sprite_from_image('sprites/factory.png', nil, 'center')
factory_layer_0 = graphics.sprite_from_image('sprites/factory0.png', nil, 'center')
factory_layer_1 = graphics.sprite_from_image('sprites/factory1.png', nil, 'center')
factory_layer_2 = graphics.sprite_from_image('sprites/factory2.png', nil, 'center')
factory_layer_3 = graphics.sprite_from_image('sprites/factory3.png', nil, 'center')
factory_layer_4 = graphics.sprite_from_image('sprites/factory4.png', nil, 'center')

needle_sprite = graphics.sprite_from_image('sprites/needle.png', nil, 'center')
fighter_preview_sprite = graphics.sprite_from_image('sprites/fighter_outline.png', nil, 'center')
bomber_preview_sprite = graphics.sprite_from_image('sprites/bomber_outline.png', nil, 'center')
frigate_preview_sprite = graphics.sprite_from_image('sprites/frigate_outline.png', nil, 'center')

bomb_sprite = graphics.sprite_from_image('sprites/bomb.png', nil, 'center')
missile_sprite = graphics.sprite_from_image('sprites/missile.png', nil, 'center')

bubble_sprite = graphics.sprite_from_image('sprites/bubble.png', nil, 'center')
explosion_sprite = graphics.sprite_from_image('sprites/explosion.png', nil, 'center')
spark_sprite = graphics.sprite_from_image('sprites/spark.png', nil, 'center')

-- woot for hacks, this fixes some icky jittering when the factory moves
local gl = require 'gl'

local function smoothen(sprite)
  sprite.tex:enable()
  gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  sprite.tex:disable()
end

smoothen(factory_sprite)
smoothen(factory_layer_0)
smoothen(factory_layer_1)
smoothen(factory_layer_2)
smoothen(factory_layer_3)
smoothen(factory_layer_4)
