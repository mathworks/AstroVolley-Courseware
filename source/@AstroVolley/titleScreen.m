function titleScreen( app )

cla(app.UIAxes)
grid(app.UIAxes,"off")

% Plot background star field
n = 100;
axlim = [app.UIAxes.XLim app.UIAxes.YLim];
x = axlim(1) + diff(axlim(1:2))*rand(1,n);
y = axlim(3) + diff(axlim(3:4))*rand(1,n);
s = 10*rand(1,n);  % random marker size
j = randi(n,[1 round(n/4)]);  % add twinkle to some stars
scatter(app.UIAxes,x(j),y(j),2*s(j),[1 1 1],"*")
scatter(app.UIAxes,x,y,s,[1 1 1],"filled")

% Setup "AV" logo size for animation 
h = axlim(end)*1.25;  % "AV" height
w = h/3;  % "A" and "V" half-width (full width = (2/3)*height)
R = h/9;  % radius of rounded top of "A" (starts at h-w)

% x-y points for half a circle
ang = 180:-10:0;
xc = R*cosd(ang);
yc = R*sind(ang);

% Plot body inside "A" (radius of body = 2/3 radius of rounded top of "A")
x = [xc flip(xc)]*2/3 - w/2;
y = [yc -yc]*2/3 - (h/2 - w)/2;
patch(app.UIAxes,x,y,app.cs(2,:),"EdgeColor",[.5 .5 .5]);

% Add points to legs of "AV" for animation (based # of points in rounded top of "A")
L = sqrt((h-w)^2 + (w-R)^2);  % length of "legs" = hypotenuse of triangle
n = round(L*numel(ang)/(pi*R)/4);  % points to use in legs (1/4 to speed-up animation)
k = find(ang == 170);  % use a little less than half-circle 
x = [linspace(-h/2,-w/2-R,n) (-w/2+xc(k:end-k+1)) ...        % "A" leg up, rounded top
    linspace(-w/2 + R,w/2,n) linspace(w/2,h/2,n/2)];         % "V" leg down, leg up
y = [linspace(-h/2,h/2-w,n)  (h/2-w+yc(k:end-k+1)-yc(k)) ... % "A" leg up, rounded top
    linspace(h/2-w,-h/2,n)   linspace(-h/2,h/2,n/2)];        % "V" leg down, leg up
n = numel(x);  % number of points in full "AV" animation

% Animate "AV" line
hLine = animatedline(app.UIAxes,"Color",app.cs(1,:),"LineWidth",10);
for k = 1:n
    addpoints(hLine,x(k),y(k));
    drawnow % limitrate
end

% Plot ship at end of "V", triangle with length = (3/2)*width
xt = [0 1  1 0]*R - (5/9)*R;  % see setupField for details
yt = [0 1 -1 0]*R/3;
ang = 180 + atan2d(h,w);  % rotate ship to align with angle of "V" leg
x = x(end) + xt*cosd(ang) - yt*sind(ang);
y = y(end) + xt*sind(ang) + yt*cosd(ang);
patch(app.UIAxes,x,y,app.cs(2,:),"EdgeColor",[.5 .5 .5]);

% Add game title and instructional text
text(app.UIAxes,0.5,0.9,"AstroVolley","Color",app.cs(2,:),"Units","normalized", ...
    "FontName","Consolas","FontUnits","normalized","FontSize",0.075,"HorizontalAlignment","center")
text(app.UIAxes,0.5,0.1,"Press [New Campaign] to Start","Color",app.cs(2,:),"Units","normalized", ...
    "FontName","Consolas","FontUnits","normalized","FontSize",0.0375,"HorizontalAlignment","center")

% xt = 0.9*[-w 0 w -w];
% yt = 0.9*[0 h 0 0];
% patch(app.UIAxes,xt-w/2, yt-h/2,app.cs(1,:),"EdgeColor",[.5 .5 .5]);
% patch(app.UIAxes,xt+w/2,-yt+h/2,app.cs(2,:),"EdgeColor",[.5 .5 .5]);

end % function

% Copyright 2022-2026 The MathWorks, Inc.