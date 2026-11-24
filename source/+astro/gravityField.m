function dsdt = gravityField(~,s,p)

%GRAVITYFIELD  Differential equations of motion for an N-Body gravity field.
%   For simplicity (and fun), ignore body interactions (bodies assumed fixed).
%
%   dsdt = GRAVITYFIELD(~,s,p)
%
%   State Vector (s) and Derivative (ds/dt)
%     s(1:2)    = x-y position
%     s(3:4)    = x-y velocity
%     dsdt(1:2) = x-y velocity = s(3:4)
%     dsdt(3:4) = x-y acceleration due to gravity
%
%   Parameters (p)
%     p.mu = normalized gravitational constant (for use with Rb^3 instead of mass)
%     p.Rb = 1xN array of radius values of N bodies (N = p.nb)
%     p.pb = 2xN array of [x; y] positions of N bodies (N = p.nb)
%
%   See also COLLISIONEVENT

dsdt = zeros(4,1);
dsdt(1:2) = s(3:4);
for k = 1:p.nb
    GMk = p.mu*p.Rb(k)^3;     % = grav constant * body mass (based on body size)
    rk = s(1:2) - p.pb(:,k);  % position from body "k" to projectile
    dsdt(3:4) = dsdt(3:4) - GMk*rk/norm(rk)^3;  % sum accelerations due to gravity
end

end

% Copyright 2022 The MathWorks, Inc.