function tallyVolley( app )

k = app.ship;
app.volleys(k) = app.volleys(k) + 1; % volleys for current mission only
app.("AttemptedField"+k).Value = app.("AttemptedField"+k).Value + 1;

selection = "Continue";
if ~isempty(app.iEvent)
    if (app.iEvent ~= app.ship) && any(app.iEvent == 1:app.ns)
        if app.SoundButton.Value
            try
                sound(app.target.y,app.target.Fs)

            catch % "Audio device access is not supported"
                app.SoundButton.Value = false;
                app.SoundButton.Enable = false;
            end
        end

        app.("DeliveredField"+k).Value = app.("DeliveredField"+k).Value + 1;
        deliv = [app.DeliveredField1.Value app.DeliveredField2.Value];
        app.volUsed(k) = app.volUsed(k) + app.volleys(k);  % volleys for completed missions
        app.velUsed(k) = app.velUsed(k) + app.("VelocitySlider"+k).Value;
        callSign = erase(app.("CallSignField"+k).Value,"Call Sign: ");

        if ((app.mode == "campaign") && (app.("DeliveredField"+k).Value == app.nWins))
            % Campaign Complete
            msg = "Congratulations " + callSign + "!  You have " ...
                + "successfully completed the campaign." + newline + newline ...
                + "Nav. Call Sign:    " + callSign + newline ...
                + "Payload Status:   All " + app.nWins + " Delivered!" + newline ...
                + "Total Volleys:      " + app.volUsed(k) + newline ...
                + "Mean Velocity:    " + app.velUsed(k)/app.nWins + "%" ...
                + newline + newline + "Your performance metrics have " ...
                + "been recorded in the Navigator's Campaign Logbook.";
            selection = uiconfirm(app.UIFigure,msg,"Campaign Complete","Icon","success", ...
                "Options",["View Leader Board" "Return to Console"]);

            % Save metrics to leader board scores .mat file
            app.scores(end+1,:) = {callSign app.volUsed(k) app.velUsed(k)/app.nWins datetime("now")};
            app.scores = sortrows(app.scores,[2 3],"ascend");
            data.scores = app.scores;
            save(app.logBook,"-struct","data","scores")
            app.LeaderButton.Enable = "on";

        else
            % Mission Complete
            msg = "Well done " + callSign + "!  Your volley has " ...
                + "successfully intercepted the target." + newline + newline ...
                + "Nav. Call Sign:      " + callSign + newline ...
                + "Payload Status:    Delivered!" + newline ...
                + "Volley Attempts:   " + app.volleys(k) + newline ...
                + "Initial Velocity:      " + app.("VelocitySlider"+k).Value + "%";
            if (app.mode == "campaign")
                opts = "Next Mission";
            else
                opts = ["Next Mission","Cancel"];
            end
            selection = uiconfirm(app.UIFigure,msg,"Mission Complete", ...
                "Icon","success","Options",opts);
        end

        if (selection == "Next Mission")
            app.volleys = [0 0];
            if (app.mode == "campaign")
                app.nb = app.levels(max(deliv),sum(deliv));
            else
                bmax = max(app.levels,[],"all");  % max # of bodies
                app.nb = randi(bmax);  % number bodies
            end
            app.setupMission();
            app.plotMission();
        end

    else
        if app.SoundButton.Value
            try
                sound(app.crash.y,app.crash.Fs)
                
            catch % "Audio device access is not supported"
                app.SoundButton.Value = false;
                app.SoundButton.Enable = false;
            end
        end
    end
end

if (selection == "View Leader Board")
    app.mode = "complete";
    setComponentStatus(app,1:2)
    app.LeaderButton.Value = true;
    LeaderButtonValueChanged(app);
    
elseif (selection == "Return to Console")
    app.mode = "complete";
    setComponentStatus(app,1:2)
else
    setComponentStatus(app,Inf) % all on
end

end % function

% Copyright 2022-2026 The MathWorks, Inc.