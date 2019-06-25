local EulerVector = class("EulerVector")


function EulerVector:ctor(x0,x1,x2)
    self.x0 = x0
    self.x1 = x1
    self.x2 = x2
end

function EulerVector:step(m, af, f, dt)
    self.x2 = (f - af * self.x1) / m;
    self.x1 = self.x1 + self.x2 * dt;
    self.x0 = self.x0 - self.x1 * dt;
end

function EulerVector:clear()
    self.x0 = 0
    self.x1 = 0
    self.x2 = 0
end


return EulerVector