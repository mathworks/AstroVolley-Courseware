function onRandomMissionPushed( app )

app.LeaderButton.Value = false;
if (app.mode == "campaign")
    msg = "There is currently a campaign in progress. If you 'Continue' a " ...
        + "random mission will be generated and all campaign progress will be lost.";
    selection = uiconfirm(app.UIFigure,msg,"Warning","Icon","warning", ...
        "Options",["Continue","Cancel"],"DefaultOption","Cancel");
    if (selection == "Cancel")
        return
    end
end
app.mode = "mission";

for k = 1:2
    app.("DeliveredField"+k).Value = 0;
    app.("AttemptedField"+k).Value = 0;
end

app.volleys = [0 0];  % mission volleys
app.volUsed = [0 0];  % only used by campaign
app.velUsed = [0 0];  % only used by campaign
bmax = max(app.levels,[],"all");  % max # of bodies
app.nb = randi(bmax); % number bodies

app.setupMission();
app.plotMission();
app.setComponentStatus(Inf); % all on

end % function

% Copyright 2022-2026 The MathWorks, Inc.