local gl = require 'gl'
local blueprints = require 'blueprints'
local v2 = require 'dokidoki.v2'

local BUILDING_SPEED = 3

local SEGMENTS = 16
local RADIUS = 25
local OFFSET = -30

UNIT_COSTS = { fighter = 60, bomber = 180, frigate = 360, upgrade = 720 }

local potential_cost = 0
button_held = false

local function spawn(blueprint)
  self.resources.amount = self.resources.amount - UNIT_COSTS[blueprint.name]

  game.actors.new(blueprint,
    {'transform', pos=self.transform.pos, facing=self.transform.facing},
    {'ship', player=self.ship.player})
end

function update()  
  if button_held then
    if (potential_cost == 0 and self.resources.amount >= potential_cost) then 
      potential_cost = UNIT_COSTS.fighter 
    end
    if (self.resources.amount > potential_cost + BUILDING_SPEED-1) then
      potential_cost = potential_cost + BUILDING_SPEED
    end
  else
    if potential_cost > UNIT_COSTS.upgrade then
      spawn(blueprints.upgrade)    
    elseif potential_cost > UNIT_COSTS.frigate then
      game.log.record_spawn(blueprints.frigate)
      spawn(blueprints.frigate)  
    elseif potential_cost > UNIT_COSTS.bomber then
      game.log.record_spawn(blueprints.bomber)
      spawn(blueprints.bomber)
    elseif potential_cost > UNIT_COSTS.fighter then
      game.log.record_spawn(blueprints.fighter)
      spawn(blueprints.fighter)
    end
    potential_cost = 0
  end
  
  -- this is debugging code and should be removed sometime soon...
  local key_z = game.keyboard.key_pressed(string.byte('Z'))
  local key_x = game.keyboard.key_pressed(string.byte('X'))
  local key_c = game.keyboard.key_pressed(string.byte('C'))
  local key_v = game.keyboard.key_pressed(string.byte('V'))

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
  if key_v then spawn(blueprints.upgrade) end
end

local function scale_angle(frames)
  local angle = 0
  if (frames < UNIT_COSTS.fighter) then
    angle = 0.25
  elseif (frames < UNIT_COSTS.bomber) then
    angle = (frames - UNIT_COSTS.fighter) / (UNIT_COSTS.bomber - UNIT_COSTS.fighter) * 0.25 + 0.25
  elseif (frames < UNIT_COSTS.frigate) then
    angle = (frames - UNIT_COSTS.bomber) / (UNIT_COSTS.frigate - UNIT_COSTS.bomber) * 0.25 + 0.5
  else
    angle = (frames - UNIT_COSTS.frigate) / (UNIT_COSTS.upgrade - UNIT_COSTS.frigate) * 0.25 + 0.75
  end
  return math.min(angle - 0.25, 1)
end

local function get_resources_spent(frames)
  local spent
  if (frames < UNIT_COSTS.fighter) then
    spent = 0
  elseif (frames < UNIT_COSTS.bomber) then
    spent = UNIT_COSTS.fighter
  elseif (frames < UNIT_COSTS.frigate) then
    spent = UNIT_COSTS.bomber
  elseif (frames < UNIT_COSTS.upgrade) then
    spent = UNIT_COSTS.frigate
  else
    spent = UNIT_COSTS.upgrade
  end
  return spent
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
  
  -- Draw the available resources pie-slice
  gl.glBegin(gl.GL_POLYGON)
    local angle = scale_angle(self.resources.amount)
    gl.glColor4d(0, 0, 0, 0.25)
    gl.glVertex2d(0, 0)
    for point = 0,SEGMENTS-1 do
      gl.glVertex2d(math.sin(point / SEGMENTS * angle * math.pi * 2) * RADIUS, math.cos(point / SEGMENTS * angle * math.pi * 2) * RADIUS)
      gl.glVertex2d(math.sin((point+1) / SEGMENTS * angle * math.pi * 2) * RADIUS, math.cos((point+1) / SEGMENTS * angle * math.pi * 2) * RADIUS)
    end
    gl.glVertex2d(0, 0)
  gl.glEnd()   
  
  -- Draw the actually used resources slice (if any)
  if self.resources.amount > UNIT_COSTS.fighter and button_held then
    gl.glBegin(gl.GL_TRIANGLE_FAN)
      local cost = get_resources_spent(potential_cost)
      local bottom_highlight_angle = scale_angle(cost) * math.pi * 2
      gl.glColor4d(1, 1, 1, 0.5)
      gl.glVertex2d(0, 0)
      for point = 0,SEGMENTS-1 do
        gl.glVertex2d(math.sin(point / SEGMENTS * math.pi * 0.5 + bottom_highlight_angle) * RADIUS, math.cos(point / SEGMENTS * math.pi * 0.5 + bottom_highlight_angle) * RADIUS)
        gl.glVertex2d(math.sin((point+1) / SEGMENTS * math.pi * 0.5 + bottom_highlight_angle) * RADIUS, math.cos((point+1) / SEGMENTS * math.pi * 0.5 + bottom_highlight_angle) * RADIUS)
      end
    gl.glEnd()    
  else
    -- TODO : Grey out the entire thing, or close doors, whatever
  end
  
  -- Draw the needle
  local angle = scale_angle(potential_cost)
  gl.glColor3d(1, 1, 1)
  gl.glPushMatrix()
    gl.glScaled(0.5, 0.5, 1)
    gl.glRotated(-angle * 360, 0, 0, 1)
    game.resources.needle_sprite:draw()
  gl.glPopMatrix()    
  
  -- Draw the outline
  gl.glBegin(gl.GL_LINE_LOOP)
    local color = self.resources.amount< UNIT_COSTS.fighter and {1, 0, 0} or {1, 1, 1}
    gl.glColor3d(color[1], color[2], color[3])
    for point = 0,SEGMENTS do
      gl.glVertex2d(math.sin(point / SEGMENTS * math.pi * 2) * RADIUS, math.cos(point / SEGMENTS * math.pi * 2) * RADIUS)
    end
  gl.glEnd()
  
  -- Draw the separating lines
  gl.glBegin(gl.GL_LINES)
    local angle = 0.25
    gl.glColor3d(1, 0, 0)
    gl.glVertex2d(0, 0)
    gl.glVertex2d(math.sin(math.pi * 2 * angle) * RADIUS, math.cos(math.pi * 2 * angle) * RADIUS)
    
    angle = 0.5
    gl.glColor3d(0, 1, 0)
    gl.glVertex2d(0, 0)
    gl.glVertex2d(math.sin(math.pi * 2 * angle) * RADIUS, math.cos(math.pi * 2 * angle) * RADIUS)

    angle = 0.75
    gl.glColor3d(0, 0, 1)
    gl.glVertex2d(0, 0)
    gl.glVertex2d(math.sin(math.pi * 2 * angle) * RADIUS, math.cos(math.pi * 2 * angle) * RADIUS)
  gl.glEnd() 
  gl.glColor3d(1, 1, 1)
  
  gl.glDisable(gl.GL_LINE_SMOOTH)
  
  gl.glPopMatrix()
end
