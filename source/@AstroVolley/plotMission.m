function plotMission( app )

%PLOTMISSION  Plots ships and gravitational bodies for current mission map.
%   Requires the following parameters be defined in the input object (app).
%
%   Ship Parameters
%     app.ns = number of ships (M)
%     app.ps = 2xM array of [x; y] positions of M ships
%     app.Rs = 1xM array of radius values of M ships
%     app.cs = Mx3 array of R-G-B colors of M ships
%
%   Body Parameters
%     app.nb = number of gravitationl bodies (N)
%     app.pb = 2xN array of [x; y] positions of N bodies
%     app.Rb = 1xN array of radius values of N bodies
%     app.cb = Nx3 array of R-G-B colors of N bodies
%
%   See also SETUPMISSION, GRAVITYFIELD

cla(app.UIAxes)
grid(app.UIAxes,"on")

% x-y points to plot a triangle with length = (3/2)*width -> W/2 = L/3
% R := radius of circle encompassing triangle
% (W/2)^2 + (L-R)^2 = R^2 -> 10*L^2/9 = 2*R*L -> L = R*9/5
for k = 1:app.ns
    len = app.Rs(k)*9/5;              % distance units
    xt = [0 1  1 0]*len - app.Rs(k);  % = [-5 4 4 -5] when len = 9
    yt = [0 1 -1 0]*len/3;            % = [ 0 3 -3 0] when len = 9
    x = app.ps(1,k) + xt*sign(app.ps(1,k));  % point towards x = 0
    y = app.ps(2,k) + yt;
    patch(app.UIAxes,x,y,app.cs(k,:),"EdgeColor",[.5 .5 .5]);
end

% x-y points to plot a unit circle
ang = 0:5:360;  % degrees
xc = cosd(ang);
yc = sind(ang);
for k = 1:app.nb
    x = app.pb(1,k) + app.Rb(k)*xc;
    y = app.pb(2,k) + app.Rb(k)*yc;
    patch(app.UIAxes,x,y,app.cb(k,:),"EdgeColor",[.5 .5 .5]);
end

end % function

% Copyright 2022-2026 The MathWorks, Inc.