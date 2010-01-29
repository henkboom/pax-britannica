require 'dokidoki.module' [[]]

local kernel = require 'dokidoki.kernel'

local the_game = require 'the_game'

kernel.set_video_mode(1024, 768)
kernel.start_main_loop(the_game.make())
