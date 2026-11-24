function launchVolley( app )

% Extract parameters from app properties
p.mu = app.mu;  % normalized gravitational constant
p.ns = app.ns;  % number spaceships (2)
p.ps = app.ps;  % x-y position of spaceships
p.Rs = app.Rs;  % radius of circle encompassing ship
p.nb = app.nb;  % number gravitational bodies
p.pb = app.pb;  % x-y position of bodies
p.Rb = app.Rb;  % radius of bodies

% Integrate equations of motion until event occurs
tspan = [0, app.Tmax];  % maximum time span of integration
s0 = [app.p0; app.v0];  % initial state
opts = odeset( Events=@(t,s) astro.collisionEvent(t,s,p), ...
    RelTol=2.5e-14, AbsTol=2.5e-16 );
[time,traj,~,~,app.iEvent] = ode113( ...
    @(t,s) astro.gravityField(t,s,p), tspan, s0, opts );

% Do not plot points where trajectory does not return to inside axes limits
xa = app.UIAxes.XLim([2,1,1,2]);
ya = app.UIAxes.YLim([2,2,1,1]);
in = inpolygon(traj(:,1),traj(:,2),xa,ya);
n = size(traj,1);
n = min(find(in,1,"last")+1,n); % find last point still inside

% Keep two (app.ns) most recent comets, delete oldest
h = findobj( app.UIAxes.Children, Tag="tail" );
if (numel(h) >= app.ns)
    delete( h(end) )
    h = findobj( app.UIAxes.Children, Tag="body" );
    delete( h(end) )
    h = findobj( app.UIAxes.Children, Tag="head" );
    delete( h(end) )
end
delete( app.hQuiver )

% Plot new comet trajectory (animation speed is based on the number of points,
% which ironically makes it slower during the faster portions of the trajectory)
% Limit to nmax points for faster animation
nmax = 100*time(n)/(app.Tmax/4); % max 100 points per half period (Tmax ~ 2 periods)
nmax = max(1,round(nmax));
j = max(1,round(n/nmax));
k = 1:j:n;  % only keep every jth point
npts = numel(k);
xpts = npts - nmax;
if (xpts > 0)  % clean-up extra points when npts ~ (nmax, 1.5*nmax)
    j = round(npts/xpts);
    k(j:j:end) = [];  % remove every jth point
end
if (k(end) ~= n)
    k = [k, n];  % ensure last point is plotted
end

% Set comet color order (head, body, tail) based on active ship
app.UIAxes.ColorOrder = [app.cs([app.ship app.ship],:); .5 .5 .5];
comet( app.UIAxes, traj(k,1), traj(k,2) );

% Lock comet colors after plotting (so unaffected by changes to ColorOrder)
set( findobj( app.UIAxes.Children, Tag="head" ), ColorMode="manual" );
set( findobj( app.UIAxes.Children, Tag="body" ), ColorMode="manual" );
set( findobj( app.UIAxes.Children, Tag="tail" ), ColorMode="manual" );

end % function

% Copyright 2022-2026 The MathWorks, Inc.