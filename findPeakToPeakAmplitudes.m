function amplitudes = findPeakToPeakAmplitudes(time, yVals)
    turningPoints = findTurningPoints(yVals); % locations of turning points in yVals
    
    numberOfWaves = floor(length(turningPoints) / 2);
    
    amplitudes = zeros(numberOfWaves, 2);
    
    for i = 1:numberOfWaves
        amplitudes(i, 1) = time(turningPoints((i*2)-1)) + time(turningPoints(i*2)) / 2;
        amplitudes(i, 2) = yVals(turningPoints((i*2)-1)) - yVals(turningPoints(i*2));
    end
end
