function [largePeakTimes, largePeakYVals] = findLargePeaks(time, yVals)
    turningPoints = findTurningPoints(time, yVals);

    % vector of y value positions and times of turning points
    positions = zeros(length(turningPoints), 1);
    times = zeros(length(turningPoints), 1);
    for i = 1:length(turningPoints)-1
        positions(i) = yVals(turningPoints(i));
        times(i) = time(turningPoints(i));
    end
    
    meanAmplitude = mean(positions);
    stdAmplitude = std(positions);
    
    largePeakPositions = []; % index of used turning points in turningPoints
    expected = null; % max or min point
    % null because either max or min point can be first
    
    for i = 1:length(turningPoints)-1
        if positions(i) > meanAmplitude + stdAmplitude*1.5 &&...
            expected ~= "min"
            % maximum point
            expected = "min"; % next point should be minimum
            largePeakPositions(end) = i;
            
        elseif positions(i) < -meanAmplitude - stdAmplitude*1.5 &&...
            expected ~= "max"
            % minimum point
            expected = "max"; % next point should be minimum
            largePeakPositions(end) = i;
            
        end
    end
    
    % output variables
    largePeakTimes = zeros(length(largePeakPositions), 1);
    largePeakYVals = zeros(length(largePeakPositions), 1);
    for i = 1:length(largePeakPositions)
        largePeakTimes(i) = times(largePeakPositions(i));
        largePeakYVals(i) = yVals(largePeakPositions(i));
    end
end

