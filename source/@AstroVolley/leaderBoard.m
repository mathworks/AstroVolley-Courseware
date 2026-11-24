function leaderBoard( app )

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

text(app.UIAxes,0.5,0.9,"Campaign Leader Board","Color",app.cs(2,:),"Units","normalized", ...
    "FontName","Consolas","FontUnits","normalized","FontSize",0.075,"HorizontalAlignment","center")

varNames = app.scores.Properties.VariableNames;
n = numel(varNames);
m = min(10,size(app.scores,1));
for k = 1:n
    col = [varNames{k}; string(app.scores{1:m,k})];
    text(app.UIAxes,0.125+0.25*(k-1),0.5,col,"Color",app.cs(2,:),"Units","normalized", ...
        "FontName","Consolas","FontUnits","normalized","FontSize",0.0375,"HorizontalAlignment","center");
end

text(app.UIAxes,0.5,0.1,"Press [New Campaign] to Start","Color",app.cs(2,:),"Units","normalized", ...
    "FontName","Consolas","FontUnits","normalized","FontSize",0.0375,"HorizontalAlignment","center")

end % function

% Copyright 2022-2026 The MathWorks, Inc.