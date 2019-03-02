function amplitudes = findPeakToPeakAmplitudes(yVals)
    a = yVals(1:end-2);
    b = yVals(2:end-1);
    c = yVals(3:end);
    turningPoints = find((b<a & b<c) | (b>a & b>c))+1; % locations of turning points in yVals
    
    numberOfWaves = floor(length(turningPoints) / 2);
    
    amplitudes = zeros(numberOfWaves, 1);
    
    for i = 1:numberOfWaves
        amplitudes(i) = yVals(turningPoints((i*2)-1)) - yVals(turningPoints(i*2));
    end
end

