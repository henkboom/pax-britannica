function update()
  local space = game.keyboard.key_held(string.byte(' '))

  local target = game.targeting.get_nearest_of_type(self, 'factory')

  if target then
    self.ship.go_towards(target.transform.pos, true)
  end

  if space then 
	  self.fighter_shooting.shoot()
  end
end
