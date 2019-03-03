% first run vertigo raw csv file on Convert_ocean_data.m
% then import this data from home -> import data -> select the csv file
% -> output type column vectors -> import selection
% then run this program (which will use the varName1 and varName2 vars)

time = VarName1;
rawDownData = VarName2;

%time = imudata(:, 1);
%rawDownData = (accel_ned(:, 3) - 1) * 9.81;

cadence = 5;
%cadence = 500;

% Cut down data to cadence (smaller sampling rate)
% moving mean
aveRawDownData = movmean(rawDownData,cadence)-1;
% decimation (alternate method)
%aveRawDownData = decimate(rawDownData,cadence);
%time = decimate(time,cadence);

% Integrating raw data into velocity and displacement
downVelData = cumtrapz(9.81*aveRawDownData)*0.00005;
%downVelDataDrift = detrend(downVelData);

% Attempt to curve fit all of the data after linear drift has been removed.
pvalue = 4;
pcd = polyfit(time, downVelData, pvalue);
pvd = polyval(pcd, time);
downVelDataCorrected = downVelData - pvd;

% Raw down accelerometer data without linear drift removed
figure;
plot(time, downVelData);
xlabel('Time (s)');
ylabel('Down Velocity (m/s)');


% Down velocity data with a linear drift trend removed
%figure;
%plot(time, downVelDataDrift);
%xlabel('time');
%ylabel('downVelDataDrift');

% Down velocity data corrected polyfit-corrected to attain a shape which resembles
% what we expect from a wave, as well as the polyfitted values
figure;
plot(time, downVelDataCorrected);
xlabel('Time (s)');
ylabel('Down Velocity Corrected (m/s)');

figure;
plot(time, pvd);
xlabel('Time (s)');
ylabel('pcd');


% Down displacement data shown after finding cumulative trapeziums of the
% velocity data
downDispData = cumtrapz(downVelDataCorrected);

figure;
plot(time, downDispData);
xlabel('Time (s)');
ylabel('Down Displacement (m)');
