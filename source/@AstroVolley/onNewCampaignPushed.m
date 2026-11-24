function onNewCampaignPushed( app )

app.LeaderButton.Value = false;
if (app.mode == "start")
    msg = "Each campaign consists of " + (2*app.nWins-1) + " progressive missions. " ...
        + "The first navigator to complete " + app.nWins + " missions wins!" ...
        + newline + newline + "Missions are completed by navigating payloads " ...
        + "around gravitational bodies (○) to deliver them from your star " ...
        + "cruiser (▷) to the other star cruiser (◁)." + newline + newline ...
        + "To attempt a payload transfer, use your side of the console to set the " ...
        + "initial angle and velocity, and then press 'LAUNCH'. Navigators " ...
        + "should alternate turns launching payloads." + newline + newline ...
        + "You can change your 'Call Sign' by editing the field above your " ...
        + "score. Good luck navigators!";
    selection = uiconfirm(app.UIFigure,msg,"Welcome to AstroVolley!", ...
        "Icon","","Options",["Begin","Show Demo","Cancel"]);

    switch selection
        case "Begin"
            app.mode = "campaign";
        case "Show Demo"
            app.setComponentStatus(0); % all off
            app.nb = 1;  % number bodies
            app.setupMission();
            app.plotMission();
            app.demoVolley();
            app.mode = "campaign";
        case "Cancel"
            return
    end

elseif (app.mode == "campaign")
    msg = "There is already a campaign in progress. If you 'Continue' a " ...
        + "new campaign will be launched and all previous progress will be lost.";
    selection = uiconfirm(app.UIFigure,msg,"Warning","Icon","warning", ...
        "Options",["Continue","View Rules","Cancel"],"DefaultOption","Cancel");

    if (selection == "View Rules")
        app.mode = "start";
        NewCampaignButtonPushed(app);
        app.mode = "campaign";
        return

    elseif (selection == "Cancel")
        return
    end

else
    app.mode = "campaign";
end

app.setComponentStatus(0); % all off
app.volleys = [0 0];
app.volUsed = [0 0];
app.velUsed = [0 0];

for k = 1:2
    app.("DeliveredField"+k).Value = 0;
    app.("AttemptedField"+k).Value = 0;
end

app.nb = 1;  % number bodies
app.setupMission();
app.plotMission();
app.setComponentStatus(Inf); % all on

end % function

% Copyright 2022-2026 The MathWorks, Inc.