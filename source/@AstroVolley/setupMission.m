function setupMission( app )

%SETUPMISSION  Sets up the following ship, body, and scenario parameters used to 
%   generate a new mission map.  Parameters are added to the input object (app).
%
%   Ship Parameters
%     app.ns = number of ships (M)
%     app.ps = 2xM array of [x; y] positions of M ships
%     app.Rs = 1xM array of radius values of M ships
%     app.cs = Mx3 array of R-G-B colors of M ships
%
%   Body Parameters
%     app.nb = number of gravitationl bodies (N), [defined outside this function]
%     app.pb = 2xN array of [x; y] positions of N bodies
%     app.Rb = 1xN array of radius values of N bodies
%     app.cb = Nx3 array of R-G-B colors of N bodies
%
%   Scenario Parameters
%     app.mu = normalized gravitational constant (for use with Rb^3 instead of mass)
%     app.vmax   = maximum allowable velocity
%     app.qscale = scale factor used by quiver
%     app.Tmax   = maximum trajectory time
%
%   See also PLOTMISSION, GRAVITYFIELD

xaxlim = 300;
yaxlim = 200;
app.UIAxes.XLim = [-1 1]*xaxlim;
app.UIAxes.YLim = [-1 1]*yaxlim;

% Spaceship locations
app.ns = 2;        % number spaceships
dxs = xaxlim*3/4;  % distance units from x = 0
dys = yaxlim*3/4;  % distance units from y = 0
xs = [-dxs dxs];   % fixed x positions (opposite sides)
ys = 2*dys*rand(1,2) - dys; % random y positions
bmax = max(app.levels,[],"all"); % max # of bodies
Rs = linspace(10,5,bmax);   % ship radius values (larger when less bodies)
app.ps = [xs; ys];          % x-y position of spaceships
app.Rs = Rs(app.nb)*[1 1];  % ship radius used for collision detection
app.cs = [0 .73 .96; 1 1 .4]; % R-G-B colors of ships

% Gravitational bodies locations and size
cmap = turbo;          % color map
idx = randi(size(cmap,1),app.nb,1); % random indices into color map
dxb = xaxlim/2;        % distance units from x = 0
dyb = yaxlim/2;        % distance units from y = 0
xb = 2*dxb*rand(1,app.nb) - dxb;
yb = 2*dyb*rand(1,app.nb) - dyb;
app.pb = [xb; yb];     % x-y position of bodies
app.Rb = 5 + 10*rand(1,app.nb);  % random radius of bodies, range: [5 15]
app.cb = cmap(idx,:);  % random R-G-B colors of bodies

%% DEFINE: 10 du = Re = 6,371,000 m
%   G = 6.67408e-11;    % m^3/(kg*s^2), universal gravitational constant
%   G = 2.58088e-28;    % du^3/(kg*s^2), universal gravitational constant
%   Me = 5.97237e24;    % kg, earth mass
%   Vk = (4/3)*pi*Rk^3  % volume of body k
%   Mk = Me*(Vk/Ve)     % mass of body k, assume same density as Earth
%   G*Mk = G*Me*(Vk/Ve) = G*Me*(Rk/Re)^3 = (G*Me/10^3)*Rk^3, recall Re = 10 du
% DEFINE mu := G*Me/10^3 such that it can be used with Rk^3 instead of Mk
app.mu = 1.5e-6;        % normalized gravitational constant

% Set maximum allowable velocity
Mb = app.Rb.^3;  % normalized mass of each body, based on size
M = sum(Mb);     % total normalized system mass
rcm = sum(Mb.*app.pb,2)/M;     % system center of mass
rmin = vecnorm(app.ps - rcm);  % min distance of each ship to center of system mass
app.vmax = sqrt(2*app.mu*M./rmin);   % escape velocity (rough estimate)
app.qscale = (dxs - dxb)./app.vmax;  % scale factor used by quiver

% Set maximum trajectory time
a = norm(app.ps(:,2) - app.ps(:,1))/2;  % hack for trajectory semi-major axis
app.Tmax = 4*pi*sqrt(a^3/(app.mu*M));   % two orbital periods

end % function

% Copyright 2022-2026 The MathWorks, Inc.