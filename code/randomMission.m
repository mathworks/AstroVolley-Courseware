function app = randomMission(app)

if (nargin == 0)  % no inputs, if used outside of App Designer
    app.UIAxes = gca;  % must define UIAxes and
    app.hq = [];       % initialize quiver handle
end
ax = app.UIAxes;  % get axes
cla(ax)           % clear axes

%% Plot Spaceships
app.xs = [-225  225];         % ship x-positions
app.ys = 300*rand(1,2) - 150; % ship y-positions
app.Rs = [   5    5];         % ship sizes
cs = [0 .73 .96; 1 1 .4];     % ship colors

xt = [-5 4 4 -5]/5;          % triangle x-points
yt = [ 0 3 -3 0]/5;          % triangle y-points

fill(ax,app.xs(1)-app.Rs(1)*xt, ...
        app.ys(1)+app.Rs(1)*yt,cs(1,:))
hold(ax,"on")
fill(ax,app.xs(2)+app.Rs(2)*xt, ...
        app.ys(2)+app.Rs(2)*yt,cs(2,:))

%% Plot Gravitational Bodies
nb = randi(5);                  % number of bodies
app.xb = 300*rand(1,nb) - 150;  % body x-positions
app.yb = 200*rand(1,nb) - 100;  % body y-positions
app.Rb = 5 + 10*rand(1,nb);     % body sizes, range: [5 15]
cmap = turbo;                   % color map
idx = randi(size(cmap,1),nb,1); % random indices into color map
cb = cmap(idx,:);               % body colors, or lines(nb)

ang = 0:5:360;                  % angle, degrees 
xc = cosd(ang);                 % circle x-points
yc = sind(ang);                 % circle y-points

for k = 1:nb
   fill(ax,app.xb(k)+app.Rb(k)*xc, ...
           app.yb(k)+app.Rb(k)*yc,cb(k,:))
end
axis(ax,"equal")
xlim(ax,[-300 300])
ylim(ax,[-200 200])

% Customize figure axes (in App Desinger)
% set(ax,"Color",[0 0 0])
% set(ax,"GridColor",[1 1 1])
% set(ax,"XTickLabel",[],"YTickLabel",[])
% set(ax,"XTick",-300:50:300,"YTick",-200:50:200)

end % function

% Copyright 2022 The MathWorks, Inc.