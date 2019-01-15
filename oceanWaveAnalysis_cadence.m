% first run vertigo raw csv file on autowave.m
% then import this data from home -> import data -> select the csv file
% -> output type column vectors -> import selection
% then run this program (which will use the varName1 and varName2 vars)

time = VarName1;
rawDownData = VarName2;

cadenceStart = 1;
cadenceIncrement = 200;
cadenceFinish = 5001;

close all; % close all previous figure windows

for cadence = cadenceStart:cadenceIncrement:cadenceFinish % iterate cadence

    % Cut down data to cadence (smaller sampling rate
    % moving mean
    aveRawDownData = movmean(rawDownData,cadence)-1;
    % decimation (alternate method)
    %aveRawDownData = decimate(rawDownData,cadence);
    %time = decimate(time,cadence);

    % Integrating raw data into velocity and displacement
    downVelData = cumtrapz(9.81*aveRawDownData)*0.00005;
    downVelDataDrift = detrend(downVelData);

    % Attempt to curve fit all of the data after linear drift has been removed.
    pvalue = 4;
    pcd = polyfit(time, downVelData, pvalue);
    pvd = polyval(pcd, time);
    downVelDataCorrected = downVelData - pvd;

    % Down displacement data shown after finding cumulative trapeziums of the
    % velocity data
    downDispData = cumtrapz(downVelDataCorrected);

    figure;
    plot(time, downDispData);
    xlabel('time');
    ylabel('downDispData');

end