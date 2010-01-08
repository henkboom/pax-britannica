local SCRIPTED_ACTIONS = { 'fighter', 'fighter', 'fighter', 'bomber', 
                           'fighter', 'fighter', 'bomber', 'bomber', 
                           'fighter', 'fighter', 'frigate' }

local action_index = 0
local frames_to_hold = 0
local accumulated_frames = 0

local frames_to_wait = 0

-- todo : waiting for available resources

local function next_action()
  accumulated_frames = 0  
 
  action_index = action_index + 1
  if action_index > table.getn(SCRIPTED_ACTIONS) then action_index = 1 end
  
  -- how much time to hold the button (with randomness to fool CAPTCHAS)
  frames_to_hold = self.production.UNIT_FRAMES[SCRIPTED_ACTIONS[action_index]] - 30
  frames_to_hold = frames_to_hold + (math.random() - 0.5) * 20
  
  -- how much time to wait before actually performing the scripted action?
  frames_to_wait = math.random() * 60
end

-- take the first action on init
next_action()

function update()
  accumulated_frames = accumulated_frames + 1
  
  self.production.button_held = accumulated_frames > frames_to_wait and accumulated_frames < frames_to_hold + frames_to_wait
  if accumulated_frames >= frames_to_hold + frames_to_wait then
    next_action()
  end
end