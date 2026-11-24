function demoVolley( app )

% Solve Lambert's problem to determine initial velocity (only for nb = 1)
r1 = app.ps(:,1) - app.pb;  % initial position vector (from body)
r2 = app.ps(:,2) - app.pb;  % final position vector
GM = app.mu*app.Rb^3;       % grav constant * body mass (based on body size)
a  = norm(r2-r1)/2;         % hack for trajectory semi-major axis
dt = pi*sqrt(a^3/GM);       % half an orbital period

try
    [v1,v2] = astro.lambertTargeting(GM,r1,r2,dt,1,1e-6);
    ang1 = atan2d(v1(2),v1(1));
    ang2 = atan2d(v2(2),v2(1));

catch % in case it does not converge
    ang1 = 180*rand - 90;
    ang2 = 180*rand + 90;
    v1 = [cosd(ang1); sind(ang1)]*app.vmax(1)*rand;
    v2 = [cosd(ang2); sind(ang2)]*app.vmax(2)*rand;
end

%% Demo Navigator 1
app.ship = 1;
app.AngleSlider1.Value = max(-90,min(90,ang1));
app.VelocitySlider1.Value = 100*min(norm(v1)/app.vmax(1),1);
app.p0 = app.ps(:,1);  % initial position vector (from origin)
app.v0 = v1;           % initial velocity vector

txt = ["<< Navigator 1"; "<< use left sliders"; "<< to set Angle"; "<< and Velocity"];
hText = text(app.UIAxes,0.01,0.55,txt,"Color",app.cs(1,:),"Units","normalized", ...
    "FontName","Consolas","FontUnits","normalized","FontSize",0.03,"HorizontalAlignment","left");
pause(2)
app.hQuiver = quiver(app.UIAxes,app.p0(1),app.p0(2),app.v0(1),app.v0(2),app.qscale(1),"Color","red");
pause(1)

delete(hText)
txt = "<< Then press 'LAUNCH'";
hText = text(app.UIAxes,0.01,0.05,txt,"Color",app.cs(1,:),"Units","normalized", ...
    "FontName","Consolas","FontUnits","normalized","FontSize",0.03,"HorizontalAlignment","left");
pause(1)
delete(hText)

app.launchVolley();

%% Demo Navigator 2
app.ship = 2;
app.AngleSlider2.Value = max(-90,min(90,180 - ang2));
app.VelocitySlider2.Value = 100*min(norm(v2)/app.vmax(2),1);
app.p0 = app.ps(:,2);  % initial position vector (from origin)
app.v0 = v2;           % initial velocity vector

txt = ["Navigator 2 >>"; "use right sliders >>"; "to set Angle >>"; "and Velocity >>"];
hText = text(app.UIAxes,0.99,0.55,txt,"Color",app.cs(2,:),"Units","normalized", ...
    "FontName","Consolas","FontUnits","normalized","FontSize",0.03,"HorizontalAlignment","right");
pause(2)
app.hQuiver = quiver(app.UIAxes,app.p0(1),app.p0(2),app.v0(1),app.v0(2),app.qscale(2),"Color","red");
pause(1)

delete(hText)
txt = "Then press 'LAUNCH' >>";
hText = text(app.UIAxes,0.99,0.05,txt,"Color",app.cs(2,:),"Units","normalized", ...
    "FontName","Consolas","FontUnits","normalized","FontSize",0.03,"HorizontalAlignment","right");
pause(1)
delete(hText)

app.launchVolley();

end % function

% Copyright 2022-2026 The MathWorks, Inc.