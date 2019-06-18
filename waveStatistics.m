function [rmsElevation, sigWaveHeight, meanElevation] = waveStatistics(yVals)

    meanElevation = mean(yVals); 
    rmsElevation = rms(yVals); 
    stdElevation = std(yVals);
    sigWaveHeight = 4 * stdElevation;
    
    disp(['Standard dev. of wave elevation = ',num2str(stdElevation),'.']);
    disp(['Significant wave height = ',num2str(sigWaveHeight),'.']);
    disp(['Mean elevation = ',num2str(meanElevation),'.']);
    disp(['RMS elevation = ',num2str(rmsElevation),'.']);
end
