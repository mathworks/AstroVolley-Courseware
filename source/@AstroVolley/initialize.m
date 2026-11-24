function initialize( app )

% Set button icons
filePath = fileparts( mfilename( "fullpath" ) ); % remove file name
iconPath = fullfile( fileparts( filePath ), "icons" ); % up one folder
app.UIFigure.Icon     = fullfile( iconPath, "AstroVolleyIcon.png" );
app.LeaderButton.Icon = fullfile( iconPath, "favorite.svg" );
app.SoundButton.Icon  = fullfile( iconPath, "speaker.svg" );

% Resize app for screen size
app.UIFigure.Units = "normalize";
app.UIFigure.Position = [0.02, 0.06, 0.96, 0.88];

% Setup axes
axis( app.UIAxes, "equal" )
hold( app.UIAxes, "on" )
app.UIAxes.Toolbar.Visible = "off";
disableDefaultInteractivity( app.UIAxes )

% Launch title screen
rng( "shuffle" )
app.cs = [0, 0.73, 0.96; 1, 1, .4]; % used by titleScreen
app.titleScreen();

% Load sound effects
app.crash = load( "splat.mat" );
app.target = load( "gong.mat" );

app.logBook = fullfile( filePath, "NavigatorsCampaignLogbook.mat" );
if exist( app.logBook, "file" )
    data = load( app.logBook, "scores" );
    app.scores = sortrows( data.scores, [2,3], "ascend" );

else
    varTypes = ["string","double","double","datetime"];
    varNames = ["Call Sign","Volleys Used","Velocity Used (%)","Date"];
    app.scores = table( Size=[0 4], VariableTypes=varTypes, ...
        VariableNames=varNames );
    app.scores.Date.Format = "dd-MMM-yyyy";
end

% Only enable New Campaign and Random Mission
app.setComponentStatus(1:2);

end % function

% Copyright 2022-2026 The MathWorks, Inc.