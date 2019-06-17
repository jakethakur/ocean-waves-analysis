function [largePeakTimes, largePeakYVals] = findLargePeaks(time, yVals, stdTolerance)
    turningPoints = findTurningPoints(yVals);

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
    expected = "0"; % max or min point
    % null because either max or min point can be first
    
    for i = 1:length(turningPoints)-1
        if positions(i) > meanAmplitude + stdAmplitude*stdTolerance &&...
            expected ~= "min"
            % maximum point
            expected = "min"; % next point should be minimum
            largePeakPositions = [largePeakPositions i];
            
        elseif positions(i) < -meanAmplitude - stdAmplitude*stdTolerance &&...
            expected ~= "max"
            % minimum point
            expected = "max"; % next point should be minimum
            largePeakPositions = [largePeakPositions i];
            
        end
    end
    
    % output variables
    largePeakTimes = zeros(length(largePeakPositions), 1);
    largePeakYVals = zeros(length(largePeakPositions), 1);
    for i = 1:length(largePeakPositions)
        largePeakTimes(i) = times(largePeakPositions(i));
        largePeakYVals(i) = positions(largePeakPositions(i));
    end
    
    figure;
    hold on;
    plot(time, yVals);
    scatter(largePeakTimes, largePeakYVals);
    
     % means/STD/RM of *every* point
    meanElevation = mean(yVals); 
    rmsElevation = rms(yVals); 
    stdElevation = std(yVals);
    sigWaveHeight = 4 * stdElevation;
    
    disp(['Standard dev. of wave elevation = ',num2str(stdElevation),'.'])
    disp(['Significant wave height = ',num2str(sigWaveHeight),'.'])
    disp(['Mean elevation = ',num2str(meanElevation),'.'])
    disp(['RMS elevation = ',num2str(rmsElevation),'.'])
end

