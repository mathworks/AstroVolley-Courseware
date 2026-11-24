function setComponentStatus( app, flag )

% flag = indices of components to turn "on"
comp = ["NewCampaignButton" "RandomMissionButton" "LeaderButton" ...
    "VelocitySlider1" "AngleSlider1" "LaunchButton1" ...
    "VelocitySlider2" "AngleSlider2" "LaunchButton2"];

n = numel(comp);
if any(flag == 0)  % all off
    status = false(1,n);

elseif any(flag == Inf)  % all on
    status = true(1,n);

else  % use flags for on/off
    status = false(1,n);
    status(flag) = true;
end

% Override leader board flag
if isempty(app.scores)
    status(3) = false;
    
elseif any(flag > 0)
    status(3) = true;
end

% Apply status to components
for k = 1:n
    app.(comp(k)).Enable = status(k);
end

end % function

% Copyright 2022-2026 The MathWorks, Inc.