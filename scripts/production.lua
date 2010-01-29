local gl = require 'gl'
local blueprints = require 'blueprints'
local v2 = require 'dokidoki.v2'

BUILDING_SPEED = 3

local SEGMENTS = 32
local RADIUS = 32
local OFFSET = -4

UNIT_COSTS = { fighter = 50, bomber = 170, frigate = 360, upgrade = 720 }

local potential_cost = 0
local needle_angle = 0
local needle_velocity = 0

local texcoord_scroller = -0.25

button_held = false
halt_production = false

local function spawn(unit_type)
  self.resources.amount = self.resources.amount - UNIT_COSTS[unit_type]
  
  if (unit_type == 'upgrade') then 
    self.resources.harvest_rate = self.resources.harvest_rate * 1.25
  else
    game.log.record_spawn(blueprints[unit_type])
    game.actors.new(blueprints[unit_type],
      {'transform', pos=self.transform.pos, facing=self.transform.facing},
      {'ship', player=self.ship.player})
  end
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
      spawn('upgrade')    
    elseif potential_cost > UNIT_COSTS.frigate then
      spawn('frigate')  
    elseif potential_cost > UNIT_COSTS.bomber then
      spawn('bomber')
    elseif potential_cost > UNIT_COSTS.fighter then
      spawn('fighter')
    end
    potential_cost = 0
  end
  
  -- this is debugging code and should be removed sometime soon...
  local key_z = game.keyboard.key_pressed(string.byte('Z'))
  local key_x = game.keyboard.key_pressed(string.byte('X'))
  local key_c = game.keyboard.key_pressed(string.byte('C'))
  local key_v = game.keyboard.key_pressed(string.byte('V'))

  if key_z then spawn('fighter') end
  if key_x then spawn('bomber')  end
  if key_c then spawn('frigate') end
  if key_v then spawn('upgrade') end
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
  if halt_production then
    return
  end

  local pos = self.transform.pos;
  local offset = OFFSET * self.transform.facing

  gl.glPushMatrix()
  gl.glTranslated(pos.x + offset.x, pos.y + offset.y, 0)
  
  gl.glEnable(gl.GL_LINE_SMOOTH)
  gl.glHint(gl.GL_LINE_SMOOTH_HINT, gl.GL_NICEST)
	gl.glEnable(gl.GL_BLEND)
	gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  
  gl.glPushMatrix()
  
  game.resources.production_layer_1:draw()
  
  -- Draw the available resources pie-slice
  gl.glBegin(gl.GL_TRIANGLE_FAN)
    local angle = scale_angle(self.resources.amount) * math.pi * 2
    gl.glColor4d(0, 0, 0, 0.6)
    gl.glVertex2d(0, 0)
    for point = 0,SEGMENTS-1 do
      gl.glVertex2d(math.sin(point / SEGMENTS * angle) * RADIUS, math.cos(point / SEGMENTS * angle) * RADIUS)
      gl.glVertex2d(math.sin((point+1) / SEGMENTS * angle) * RADIUS, math.cos((point+1) / SEGMENTS * angle) * RADIUS)
    end
    gl.glVertex2d(0, 0)
  gl.glEnd()   
  
  -- Draw the actually used resources slice (if any)
  if self.resources.amount > UNIT_COSTS.fighter and button_held then
    gl.glBegin(gl.GL_TRIANGLE_FAN)
      local cost = get_resources_spent(potential_cost)
      local bottom_highlight_angle = scale_angle(cost) * math.pi * 2
      gl.glColor4d(0.7, 1, 1, 0.7)
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
  if angle == 0  then
    if needle_angle > 0 or needle_velocity < 0 then
      needle_velocity = math.min(needle_velocity + 0.002, 0.025)
      needle_angle = math.max(needle_angle - needle_velocity, 0)
      if (needle_angle == 0) then needle_velocity = needle_velocity * -0.475 end
    end
  else
    needle_velocity = 0
    needle_angle = angle
  end
  gl.glColor3d(1, 1, 1)
  gl.glPushMatrix()
    gl.glScaled(0.5, 0.5, 1)
    gl.glRotated(-needle_angle * 360, 0, 0, 1)
    game.resources.needle_sprite:draw()
  gl.glPopMatrix()
  
  game.resources.production_layer_2:draw()
  game.resources.production_layer_3:draw()
  
  -- Draw the preview outline 
  if button_held then
    if potential_cost > UNIT_COSTS.upgrade then
      game.resources.upgrade_preview_sprite:draw()
    elseif potential_cost > UNIT_COSTS.frigate then
      game.resources.frigate_preview_sprite:draw() 
    elseif potential_cost > UNIT_COSTS.bomber then
      game.resources.bomber_preview_sprite:draw() 
    elseif potential_cost > UNIT_COSTS.fighter then
      game.resources.fighter_preview_sprite:draw()
    end
  else
    texcoord_scroller = texcoord_scroller + 0.01
    if texcoord_scroller > 0.25 then texcoord_scroller = texcoord_scroller - 0.5 end    
    gl.glMatrixMode(gl.GL_TEXTURE)
    gl.glTranslated(texcoord_scroller, 0,0)
    gl.glMatrixMode(gl.GL_MODELVIEW)
  
    if self.ship.health_percentage() < 0.3 then
      game.resources.health_none:draw()
    elseif self.ship.health_percentage() < 0.6 then
      game.resources.health_some:draw()
    else
      game.resources.health_full:draw()
    end
    
    gl.glMatrixMode(gl.GL_TEXTURE)
    gl.glLoadIdentity()
    gl.glMatrixMode(gl.GL_MODELVIEW)      
  end
  
  gl.glColor3d(1, 1, 1)
  
  gl.glPopMatrix() -- tilt rotation to compensate for art
  
  gl.glDisable(gl.GL_LINE_SMOOTH)
  
  gl.glPopMatrix() -- main push
end
