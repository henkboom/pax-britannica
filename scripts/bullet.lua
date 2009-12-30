assert(velocity, 'missing velocity argument')

function update()
  self.transform.pos = self.transform.pos + velocity * self.transform.facing
end
