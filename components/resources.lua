local graphics = require 'dokidoki.graphics'

background = graphics.sprite_from_image('sprites/background.png', nil, {0, 0})
fighter_sprite = graphics.sprite_from_image('sprites/fighter.png', nil, 'center')
bomber_sprite = graphics.sprite_from_image('sprites/bomber.png', nil, 'center')
frigate_sprite = graphics.sprite_from_image('sprites/frigate.png', nil, 'center')
factory_sprite = graphics.sprite_from_image('sprites/factory.png', nil, 'center')