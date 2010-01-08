local gl = require 'gl'
local blueprints = require 'blueprints'
local v2 = require 'dokidoki.v2'

local SEGMENTS = 16
local RADIUS = 25
local OFFSET = {-30, 0}

local FIGHTER_FRAMES = 60;
local BOMBER_FRAMES = 60;
local FRIGATE_FRAMES = 60;
local TOTAL_FRAMES = FIGHTER_FRAMES + BOMBER_FRAMES + FRIGATE_FRAMES

local frames_button_held = 0

local function spawn(blueprint)
  game.actors.new(blueprint,
    {'transform', pos=self.transform.pos},
    {'ship', player=self.ship.player})
end

function update()
  local key_space = game.keyboard.key_held(string.byte(' '))
  
  if key_space then
    if frames_button_held < TOTAL_FRAMES then frames_button_held = frames_button_held + 1 end
  else
    if frames_button_held > TOTAL_FRAMES - FRIGATE_FRAMES then
      spawn(blueprints.frigate)
    elseif frames_button_held > FIGHTER_FRAMES then
      spawn(blueprints.bomber)
    elseif frames_button_held ~= 0 then
      spawn(blueprints.fighter)
    end
    frames_button_held = 0
  end
  
  local key_z = game.keyboard.key_pressed(string.byte('Z'))
  local key_x = game.keyboard.key_pressed(string.byte('X'))
  local key_c = game.keyboard.key_pressed(string.byte('C'))

  if key_z then spawn(blueprints.fighter) end
  if key_x then spawn(blueprints.bomber)  end
  if key_c then spawn(blueprints.frigate) end
end

function draw()
  local pos = self.transform.pos;

  gl.glPushMatrix()
  gl.glTranslated(pos.x, pos.y, 0)
  
  gl.glEnable(gl.GL_LINE_SMOOTH)
  gl.glHint(gl.GL_LINE_SMOOTH_HINT, gl.GL_NICEST)
	gl.glEnable(gl.GL_BLEND)
	gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  
  -- Draw the filled pie-slice
  gl.glBegin(gl.GL_POLYGON)
    local angle = frames_button_held / TOTAL_FRAMES
    gl.glColor3d(0.5, 0.5, 0.5)
    gl.glVertex2d(OFFSET[1], OFFSET[2])
    for point = 0,SEGMENTS do
      gl.glVertex2d(math.sin(point / SEGMENTS * math.pi * 2 * angle) * RADIUS + OFFSET[1], math.cos(point / SEGMENTS * math.pi * 2 * angle) * RADIUS + OFFSET[2])
      gl.glVertex2d(math.sin((point+1) / SEGMENTS * math.pi * 2 * angle) * RADIUS + OFFSET[1], math.cos((point+1) / SEGMENTS * math.pi * 2 * angle) * RADIUS + OFFSET[2])
    end
    gl.glVertex2d(OFFSET[1], OFFSET[2])
  gl.glEnd()   
  
  -- Draw the outline
  gl.glBegin(gl.GL_LINE_LOOP)
    gl.glColor3d(1, 1, 1)
    for point = 0,SEGMENTS do
      gl.glVertex2d(math.sin(point / SEGMENTS * math.pi * 2) * RADIUS + OFFSET[1], math.cos(point / SEGMENTS * math.pi * 2) * RADIUS + OFFSET[2])
    end
  gl.glEnd() 
  
  -- Draw the separating lines
  gl.glBegin(gl.GL_LINES)
    local angle = FIGHTER_FRAMES / TOTAL_FRAMES
    gl.glColor3d(1, 0, 0)
    gl.glVertex2d(OFFSET[1], OFFSET[2])
    gl.glVertex2d(math.sin(math.pi * 2 * angle) * RADIUS + OFFSET[1], math.cos(math.pi * 2 * angle) * RADIUS + OFFSET[2])
    
    angle = (FIGHTER_FRAMES + BOMBER_FRAMES) / TOTAL_FRAMES
    gl.glColor3d(0, 1, 0)
    gl.glVertex2d(OFFSET[1], OFFSET[2])
    gl.glVertex2d(math.sin(math.pi * 2 * angle) * RADIUS + OFFSET[1], math.cos(math.pi * 2 * angle) * RADIUS + OFFSET[2])

    angle = (FIGHTER_FRAMES + BOMBER_FRAMES + FRIGATE_FRAMES) / TOTAL_FRAMES
    gl.glColor3d(0, 0, 1)
    gl.glVertex2d(OFFSET[1], OFFSET[2])
    gl.glVertex2d(math.sin(math.pi * 2 * angle) * RADIUS + OFFSET[1], math.cos(math.pi * 2 * angle) * RADIUS + OFFSET[2])
  gl.glEnd() 
  
  gl.glDisable(gl.GL_LINE_SMOOTH)
  
  gl.glPopMatrix()
end