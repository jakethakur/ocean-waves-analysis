% Saving data as CSV:
% First run raw vertigo file on load and transform data
% Then run Convert_ocean_data.m to get this saved as a csv

% Loading data from CSV:
% Home -> import data -> select the csv file
% -> output type column vectors -> import selection
% then run this program (which will use the VarName1 and VarName2 vars)

time = VarName1;
rawDownData = VarName2;

% Alternatively the following code can be run instead to use ocean data
% variables straight after load and transform data

% time = imudata(:, 1);
% rawDownData = accel_ned(:, 3);


% Convert to accel from Gs
downAccel = (rawDownData - 1) * 9.81;

% Plot raw down accel
figure;
plot(time, downAccel);
xlabel('Time (s)');
ylabel('Raw Down Acceleration (m/s^2)');

cadence = 5;

% Cut down data to cadence (smaller sampling rate)
% moving mean
aveRawDownData = movmean(downAccel,cadence);
aveRawDownData = decimate(aveRawDownData,cadence);
time = decimate(time,cadence);
% decimation (alternate method)
%aveRawDownData = decimate(rawDownData,cadence);
%time = decimate(time,cadence);

% Integrate raw data into velocity
downVelData = cumtrapz(aveRawDownData)*0.00005;


% Plot raw down velocity
figure;
plot(time, downVelData);
xlabel('Time (s)');
ylabel('Raw Down Velocity (m/s)');

% Since velocity has a linear drift, detrend can be applied to remove the
% main body of this drift
% downVelData = detrend(downVelData);
% 
% % Plot down velocity data with a linear drift trend removed
% figure;
% plot(time, downVelData);
% xlabel('Time (s)');
% ylabel('Detrended Down Velocity (m/s)');


% Attempt to curve fit all of the data after linear drift has been removed
pvalue = 3;
pcd = polyfit(time, downVelData, pvalue);
pvd = polyval(pcd, time);
downVelDataCorrected = downVelData - pvd;

% Down velocity data corrected polyfit-corrected to attain a shape which
% resembles what we expect from a wave, as well as the polyfitted values
figure;
plot(time, downVelDataCorrected);
xlabel('Time (s)');
ylabel('Down Velocity Corrected (m/s)');

% Graph of the polyfit that was subtracted
figure;
plot(time, pvd);
xlabel('Time (s)');
ylabel('pcd');


% Integrate again to find down displacement data
downDispData = cumtrapz(downVelDataCorrected);

% Plot final displacement wave graph
figure;
plot(time, downDispData);
xlabel('Time (s)');
ylabel('Down Displacement (m)');

% Now perform turning point analysis on the wave...

% turning point analysis
downDispDataTurningPoints = removeDriftTurningPoints(time, downDispData);
