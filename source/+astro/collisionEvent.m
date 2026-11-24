function [value,isterminal,direction] = collisionEvent(~,s,p)

%COLLISIONEVENT  Detect projectile collisions with ships or bodies.
%
%   [value,isterminal,direction] = COLLISIONEVENT(~,s,p)
%
%   State Vector (s) and Parameters (p)
%     s(1:2) = x-y position
%     p.Rs   = 1xM array of radius values of M ships (M = p.ns)
%     p.ps   = 2xM array of [x; y] positions of M ships (M = p.ns)
%     p.Rb   = 1xN array of radius values of N bodies (N = p.nb)
%     p.pb   = 2xN array of [x; y] positions of N bodies (N = p.nb)
%
%   See also GRAVITYFIELD

rho = [s(1); s(2)] - [p.ps p.pb];  % position vector from each ship/body to projectile
rho = vecnorm(rho);      % distance (magnitude) from ship/body to projectile
R = [p.Rs p.Rb];         % ship/body radius

n = p.ns + p.nb;         % total number of ships + bodies (M + N)
value = rho - R;         % detect collision when value = 0 (rho = R)
isterminal = ones(1,n);  % stop the integration
direction = -ones(1,n);  % negative direction only

end

% Copyright 2022 The MathWorks, Inc.