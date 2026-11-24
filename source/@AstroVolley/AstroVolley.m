classdef AstroVolley < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './AstroVolley.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        MainGridLayout                  matlab.ui.container.GridLayout
        TopGridLayout                   matlab.ui.container.GridLayout
        LeaderButton                    matlab.ui.control.StateButton
        NewCampaignButton               matlab.ui.control.Button
        CallSignField1                  matlab.ui.control.EditField
        DeliveredField1                 matlab.ui.control.NumericEditField
        ofLabel1                        matlab.ui.control.Label
        AttemptedField1                 matlab.ui.control.NumericEditField
        VolleysLabel                    matlab.ui.control.Label
        CallSignField2                  matlab.ui.control.EditField
        DeliveredField2                 matlab.ui.control.NumericEditField
        ofLabel2                        matlab.ui.control.Label
        AttemptedField2                 matlab.ui.control.NumericEditField
        RandomMissionButton             matlab.ui.control.Button
        SoundButton                     matlab.ui.control.StateButton
        SideGridLayout1                 matlab.ui.container.GridLayout
        LaunchButton1                   matlab.ui.control.Button
        VelocitySlider1                 matlab.ui.control.Slider
        AngleSlider1                    matlab.ui.control.Slider
        VelocityLabel1                  matlab.ui.control.Label
        AngleLabel1                     matlab.ui.control.Label
        SideGridLayout2                 matlab.ui.container.GridLayout
        LaunchButton2                   matlab.ui.control.Button
        VelocitySlider2                 matlab.ui.control.Slider
        AngleSlider2                    matlab.ui.control.Slider
        VelocityLabel2                  matlab.ui.control.Label
        AngleLabel2                     matlab.ui.control.Label
        UIAxes                          matlab.ui.control.UIAxes
    end

    
    % Copyright 2022-2026 The MathWorks, Inc.
    
    properties (Access = private)
        mode = "start";  % start, campaign, mission, or complete
        volleys % volley attempts for the current mission
        volUsed % total volleys  used during completed missions
        velUsed % total velocity used during completed missions
        mu      % normalized gravitational constant
        ns      % number spaceships (2)
        ps      % x-y position of spaceships
        Rs      % radius of circle encompassing ship
        cs      % RGB colors of spaceships
        nb      % number gravitational bodies
        pb      % x-y position of bodies
        Rb      % radius of bodies
        cb      % RGB colors of bodies        
        Tmax    % maximum trajectory time
        vmax    % maximum allowable velocity
        hQuiver % quiver handle
        qscale  % scale factor used by quiver
        ship    % ship number
        p0      % initial position vector
        v0      % initial velocity vector
        iEvent  % collision event identifier [ship number; body number]
        crash   % sound effect when crashing into body or own ship
        target  % sound effect for successful deliver
        logBook % file path/name of logbook .mat file containing "scores"
        scores  % campaign leader board scores
        nWins = 4; % number of games to win, levels below assumes 4 (or less)
        levels = [2 2 0 0 0 0; 0 3 3 4 0 0; 0 0 4 4 5 5]; % progression of bodies
        % for campaign levels based on max delivered (row) vs sum delivered (col)
    end
    
    % Methods in external files
    methods (Access = private)
        initialize( app )
        setComponentStatus( app, flag )
        titleScreen( app )
        setupMission( app )
        plotMission( app )
        demoVolley( app )
        launchVolley( app )
        tallyVolley( app )
        leaderBoard( app )
        onNewCampaignPushed( app )
        onRandomMissionPushed( app )
    end
    

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app)
            app.initialize();
        end

        % Button pushed function: NewCampaignButton
        function NewCampaignButtonPushed(app, event)
            app.onNewCampaignPushed();
        end

        % Button pushed function: RandomMissionButton
        function RandomMissionButtonPushed(app, event)
            app.onRandomMissionPushed();
        end

        % Value changing function: AngleSlider1
        function AngleSlider1ValueChanging(app, event)
            ang = event.Value;
            vel = app.vmax(1)*app.VelocitySlider1.Value/100;
            app.p0 = app.ps(:,1);
            app.v0 = vel*[cosd(ang); sind(ang)];
            delete(app.hQuiver)
            app.hQuiver = quiver(app.UIAxes,app.p0(1),app.p0(2), ...
                app.v0(1),app.v0(2),app.qscale(1),"Color","red");
        end

        % Value changing function: VelocitySlider1
        function VelocitySlider1ValueChanging(app, event)
            ang = app.AngleSlider1.Value;
            vel = app.vmax(1)*event.Value/100;
            app.p0 = app.ps(:,1);
            app.v0 = vel*[cosd(ang); sind(ang)];
            delete(app.hQuiver)
            app.hQuiver = quiver(app.UIAxes,app.p0(1),app.p0(2), ...
                app.v0(1),app.v0(2),app.qscale(1),"Color","red");
        end

        % Value changing function: AngleSlider2
        function AngleSlider2ValueChanging(app, event)
            ang = 180 - event.Value;
            vel = app.vmax(2)*app.VelocitySlider2.Value/100;
            app.p0 = app.ps(:,2);
            app.v0 = vel*[cosd(ang); sind(ang)];
            delete(app.hQuiver)
            app.hQuiver = quiver(app.UIAxes,app.p0(1),app.p0(2), ...
                app.v0(1),app.v0(2),app.qscale(2),"Color","red");
        end

        % Value changing function: VelocitySlider2
        function VelocitySlider2ValueChanging(app, event)
            ang = 180 - app.AngleSlider2.Value;
            vel = app.vmax(2)*event.Value/100;
            app.p0 = app.ps(:,2);
            app.v0 = vel*[cosd(ang); sind(ang)];
            delete(app.hQuiver)
            app.hQuiver = quiver(app.UIAxes,app.p0(1),app.p0(2), ...
                app.v0(1),app.v0(2),app.qscale(2),"Color","red");
        end

        % Button pushed function: LaunchButton1
        function LaunchButton1Pushed(app, event)
            app.setComponentStatus(0); % all off
            app.ship = 1;
            ang = app.AngleSlider1.Value;
            vel = app.vmax(1)*app.VelocitySlider1.Value/100;
            app.p0 = app.ps(:,app.ship);
            app.v0 = vel*[cosd(ang); sind(ang)];
            app.launchVolley();
            app.tallyVolley();
        end

        % Button pushed function: LaunchButton2
        function LaunchButton2Pushed(app, event)
            app.setComponentStatus(0); % all off
            app.ship = 2;
            ang = 180 - app.AngleSlider2.Value;
            vel = app.vmax(2)*app.VelocitySlider2.Value/100;
            app.p0 = app.ps(:,app.ship);
            app.v0 = vel*[cosd(ang); sind(ang)];
            app.launchVolley();
            app.tallyVolley();
        end

        % Value changed function: LeaderButton
        function LeaderButtonValueChanged(app, event)
            if app.LeaderButton.Value
                app.leaderBoard();
            else
                if (app.mode == "start")
                    app.setComponentStatus(0); % all off
                    app.titleScreen();
                    app.setComponentStatus(1:2);
                else
                    app.plotMission();
                end
            end
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = AstroVolley(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end