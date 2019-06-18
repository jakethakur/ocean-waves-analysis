function [sigWaveHeight] = waveStatistics(yVals)

    meanElevation = mean(yVals); %% should be ~ 0 
    rmsElevation = rms(yVals); %% root mean square of values
    sigWaveHeight = 4 * std(yVals); %% significant wave height
    
    
    disp([...
        'Significant wave height = ',num2str(sigWaveHeight), 'm', newline...
        'Mean elevation = ',num2str(meanElevation),'m    RMS elevation = ',num2str(rmsElevation),'m', newline, newline]); 
    
end
