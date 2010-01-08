function update() 
  -- todo : put the joystick stuff in there

  if self.ship.player == 1 then
    self.production.button_held = game.keyboard.key_held(string.byte('1'))
  elseif self.ship.player == 2 then
    self.production.button_held = game.keyboard.key_held(string.byte('2'))
  elseif self.ship.player == 3 then
    self.production.button_held = game.keyboard.key_held(string.byte('3'))
  elseif self.ship.player == 4 then
    self.production.button_held = game.keyboard.key_held(string.byte('4'))
  end
end