function [traj,iEvent] = launchPayload(app,ship)

%LAUNCHPAYLOAD  Computes trajectory "traj" for the specified "ship" (1 or 2)
%   using "app" properties (xs, ys, Rs, xb, yb, Rb, hq) and components
%   (UIAxes, AngleSlider1, VelocitySlider1, AngleSlider2, VelocitySlider2).
%   "iEvent" indicates if the trajectory ended by reaching ship 1 or 2 (or a body).
%
%   [traj,iEvent] = LAUNCHPAYLOAD(app,ship)

% Setup simulation parameters
% DEFINE: 10 du = Re = 6,371,000 m
% DEFINE: mu = G*Me/10^3 such that it can be used with Rk^3 instead of Mk
p.mu = 1.5e-6;  % normalized gravitational constant [1/s^2]
p.pb = [app.xb; app.yb];  % body x-y positions
p.ps = [app.xs; app.ys];  % ship x-y positions
p.Rb = app.Rb;  % body sizes (for collision detection and mass ~ Rk^3)
p.Rs = app.Rs;  % ship sizes (for collision detection)

% Set maximum allowable velocity and maximum trajectory time
Mb = p.Rb.^3;  % normalized mass of each body, based on size
M  = sum(Mb);  % total normalized system mass
rcm  = sum(Mb.*p.pb,2)/M;     % system center of mass
rmin = vecnorm(p.ps - rcm);   % min distance of each ship to center of system mass
vmax = sqrt(2*p.mu*M./rmin);  % escape velocity (rough estimate), [du/s]
a = norm(p.ps(:,2) - p.ps(:,1))/2;  % hack for trajectory semi-major axis
Tmax = 4*pi*sqrt(a^3/(p.mu*M));     % two orbital periods, [sec]

% Set initial conditions
ax = app.UIAxes;
if isobject(app)  % used inside App Designer
    ang = app.("AngleSlider"+ship).Value;
    vel = vmax(ship)*app.("VelocitySlider"+ship).Value/100;
else  % used outside of App Designer
    ang = app.ang;
    vel = vmax(ship)*app.vel/100;
end
p0 = [app.xs(ship); app.ys(ship)];
v0 = vel*[cosd(ang); sind(ang)];
if (ship == 2)
    v0(1) = -v0(1); % flip x-direction
end

% Integrate equations of motion until event occurs
opts = odeset("Events",@(t,s) collisionEvent(t,s,p),"RelTol",2.5e-14,"AbsTol",2.5e-16);
[time,traj,~,~,iEvent] = ode113(@(t,s) gravityField(t,s,p),[0 Tmax],[p0; v0],opts);

% Do not plot points where trajectory does not return to inside axes limits
xa = ax.XLim([2 1 1 2]);
ya = ax.YLim([2 2 1 1]);
in = inpolygon(traj(:,1),traj(:,2),xa,ya);
n = size(traj,1);
n = min(find(in,1,"last")+1,n); % find last point still inside

% Keep previous comet from each ship, delete oldest
h = findobj(ax.Children,"tag","tail");
ns = numel(app.Rs);
if (numel(h) >= ns)
    delete(h(end))
    h = findobj(ax.Children,"tag","body");
    delete(h(end))
    h = findobj(ax.Children,"tag","head");
    delete(h(end))
end
delete(app.hq)  % delete quiver

% Set comet colors (which could just be stored in "app" with other parameters,
% but to reduce app properties/complexity extract it from the plot instead)
cs = flip(findobj(ax.Children,"Type","patch"));
cs = cs(ship).FaceColor;  % current ship color
set(ax,"ColorOrder",[cs; cs; .5 .5 .5])

% When plotting comet trajectory animation speed is based on the number of points,
% which ironically makes it slower during the faster portions of the trajectory.
% Limit to nmax points for faster animation
nmax = 100*time(n)/(Tmax/4); % max 100 points per half period (Tmax ~ 2 periods)
nmax = max(1,round(nmax));
j = max(1,round(n/nmax));
k = 1:j:n;  % only keep every jth point
npts = numel(k);
xpts = npts - nmax;
if (xpts > 0)  % clean-up extra points when npts ~ (nmax, 1.5*nmax)
    j = round(npts/xpts);
    k(j:j:end) = []; % remove every jth point
end
if (k(end) ~= n)
    k = [k n];  % ensure last point is plotted
end
traj = traj(k,1:2);

end

%% =============================================================================== %%
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
%     p.Rb = 1xN array of radius values of N bodies
%     p.pb = 2xN array of [x; y] positions of N bodies
%
%   See also COLLISIONEVENT

dsdt = zeros(4,1);
dsdt(1:2) = s(3:4);
for k = 1:numel(p.Rb)
    GMk = p.mu*p.Rb(k)^3;     % = grav constant * body mass (based on body size)
    rk = s(1:2) - p.pb(:,k);  % position from body "k" to projectile
    dsdt(3:4) = dsdt(3:4) - GMk*rk/norm(rk)^3;  % sum accelerations due to gravity
end

end

%% =============================================================================== %%
function [value,isterminal,direction] = collisionEvent(~,s,p)

%COLLISIONEVENT  Detect projectile collisions with ships or bodies.
%
%   [value,isterminal,direction] = COLLISIONEVENT(~,s,p)
%
%   State Vector (s) and Parameters (p)
%     s(1:2) = x-y position
%     p.Rs   = 1xM array of radius values of M ships
%     p.ps   = 2xM array of [x; y] positions of M ships
%     p.Rb   = 1xN array of radius values of N bodies
%     p.pb   = 2xN array of [x; y] positions of N bodies
%
%   See also GRAVITYFIELD

rho = [s(1); s(2)] - [p.ps p.pb];  % position vector from each ship/body to projectile
rho = vecnorm(rho);      % distance (magnitude) from ship/body to projectile
R = [p.Rs p.Rb];         % ship/body radius

n = numel(R);            % total number of ships + bodies (M + N)
value = rho - R;         % detect collision when value = 0 (rho = R)
isterminal = ones(1,n);  % stop the integration
direction = -ones(1,n);  % negative direction only

end

% Copyright 2022 The MathWorks, Inc.