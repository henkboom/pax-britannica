local gl = require 'gl'
local blueprints = require 'blueprints'
local v2 = require 'dokidoki.v2'

local SEGMENTS = 16
local RADIUS = 25
local OFFSET = -30

UNIT_FRAMES = { fighter = 60, bomber = 120, frigate = 180 }
local TOTAL_FRAMES = UNIT_FRAMES.frigate

local frames_button_held = 0
button_held = false

local function spawn(blueprint)
  game.actors.new(blueprint,
    {'transform', pos=self.transform.pos, facing=self.transform.facing},
    {'ship', player=self.ship.player})
end

function update()  
  if button_held then
    if frames_button_held < TOTAL_FRAMES then frames_button_held = frames_button_held + 1 end
  else
    if frames_button_held > UNIT_FRAMES.bomber then
      game.log.record_spawn(blueprints.frigate)
      spawn(blueprints.frigate)
    elseif frames_button_held > UNIT_FRAMES.fighter then
      game.log.record_spawn(blueprints.bomber)
      spawn(blueprints.bomber)
    elseif frames_button_held ~= 0 then
      game.log.record_spawn(blueprints.fighter)
      spawn(blueprints.fighter)
    end
    frames_button_held = 0
  end
  
  local key_z = game.keyboard.key_pressed(string.byte('Z'))
  local key_x = game.keyboard.key_pressed(string.byte('X'))
  local key_c = game.keyboard.key_pressed(string.byte('C'))

  if key_z then
    game.log.record_spawn(blueprints.fighter)
    spawn(blueprints.fighter)
  end
  if key_x then
    game.log.record_spawn(blueprints.bomber)
    spawn(blueprints.bomber)
  end
  if key_c then
    game.log.record_spawn(blueprints.frigate)
    spawn(blueprints.frigate)
  end
end

function draw()
  local pos = self.transform.pos;
  local offset = OFFSET * self.transform.facing

  gl.glPushMatrix()
  gl.glTranslated(pos.x + offset.x, pos.y + offset.y, 0)
  
  gl.glEnable(gl.GL_LINE_SMOOTH)
  gl.glHint(gl.GL_LINE_SMOOTH_HINT, gl.GL_NICEST)
	gl.glEnable(gl.GL_BLEND)
	gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  
  -- Draw the filled pie-slice
  gl.glBegin(gl.GL_POLYGON)
    local angle = frames_button_held / TOTAL_FRAMES
    gl.glColor3d(0.5, 0.5, 0.5)
    gl.glVertex2d(0, 0)
    for point = 0,SEGMENTS do
      gl.glVertex2d(math.sin(point / SEGMENTS * math.pi * 2 * angle) * RADIUS, math.cos(point / SEGMENTS * math.pi * 2 * angle) * RADIUS)
      gl.glVertex2d(math.sin((point+1) / SEGMENTS * math.pi * 2 * angle) * RADIUS, math.cos((point+1) / SEGMENTS * math.pi * 2 * angle) * RADIUS)
    end
    gl.glVertex2d(0, 0)
  gl.glEnd()   
  
  -- Draw the outline
  gl.glBegin(gl.GL_LINE_LOOP)
    gl.glColor3d(1, 1, 1)
    for point = 0,SEGMENTS do
      gl.glVertex2d(math.sin(point / SEGMENTS * math.pi * 2) * RADIUS, math.cos(point / SEGMENTS * math.pi * 2) * RADIUS)
    end
  gl.glEnd() 
  
  -- Draw the separating lines
  gl.glBegin(gl.GL_LINES)
    local angle = UNIT_FRAMES.fighter / TOTAL_FRAMES
    gl.glColor3d(1, 0, 0)
    gl.glVertex2d(0, 0)
    gl.glVertex2d(math.sin(math.pi * 2 * angle) * RADIUS, math.cos(math.pi * 2 * angle) * RADIUS)
    
    angle = UNIT_FRAMES.bomber / TOTAL_FRAMES
    gl.glColor3d(0, 1, 0)
    gl.glVertex2d(0, 0)
    gl.glVertex2d(math.sin(math.pi * 2 * angle) * RADIUS, math.cos(math.pi * 2 * angle) * RADIUS)

    angle = UNIT_FRAMES.frigate / TOTAL_FRAMES
    gl.glColor3d(0, 0, 1)
    gl.glVertex2d(0, 0)
    gl.glVertex2d(math.sin(math.pi * 2 * angle) * RADIUS, math.cos(math.pi * 2 * angle) * RADIUS)
  gl.glEnd() 
  gl.glColor3d(1, 1, 1)
  
  gl.glDisable(gl.GL_LINE_SMOOTH)
  
  gl.glPopMatrix()
end
