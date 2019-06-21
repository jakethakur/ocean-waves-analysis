% Saving data as CSV:
% First run raw vertigo file on load and transform data
% Then run Convert_ocean_data.m to get this saved as a csv

% Loading data from CSV:
% Home -> import data -> select the csv file
% -> output type column vectors -> import selection
% then run this program (which will use the VarName1 and VarName2 vars)

samplingFrequency = 200;

prompt = 'What time do you wish to start analysis from? ';
Time_window1 = input(prompt);
prompt = 'What time do you wish to end the analysis? ';
Time_window2 = input(prompt);

time = VarName1(samplingFrequency*Time_window1:samplingFrequency*Time_window2);
rawDownData = VarName2(samplingFrequency*Time_window1:samplingFrequency*Time_window2);

% Alternatively the following code can be run instead to use ocean data
% variables straight after load and transform data

% time = imudata(samplingFrequency*Time_window1:samplingFrequency*Time_window2, 1);
% rawDownData = accel_ned(samplingFrequency*Time_window1:samplingFrequency*Time_window2, 3);

% uses variables down (down accel) and time


% Convert to accel from Gs
downAccel = (rawDownData - 1) * 9.81;

% Plot raw down accel
figure;
plot(time, downAccel);
xlabel('Time (s)');
ylabel('Raw Down Acceleration (m/s^2)');

cadence = 100;

% Cut down data to cadence (smaller sampling rate)
% moving mean
aveRawDownData = movmean(downAccel,cadence);
%aveRawDownData = decimate(aveRawDownData,cadence);
%time = decimate(time,cadence);
% decimation (alternate method)
%aveRawDownData = decimate(rawDownData,cadence);
%time = decimate(time,cadence);

% Integrate raw data into velocity
downVelData = cumtrapz(aveRawDownData)*0.00005;


% Since velocity has a linear drift, detrend can be applied to remove the
% main body of this drift
%downVelData = detrend(downVelData);
pvalue = 1;
pcd = polyfit(time, downVelData, pvalue);
pvd = polyval(pcd, time);
downVelDataCorrected = downVelData - pvd;

% Plot raw down velocity
figure;
hold on;
plot(time, downVelData);
plot(time, pvd);
plot(time, downVelDataCorrected);
legend("initial data", "polyfit", "corrected data");
xlabel('Time (s)');
ylabel('Down Velocity (m/s)');

% % Plot down velocity data with a linear drift trend removed
% figure;
% plot(time, downVelDataCorrected);
% xlabel('Time (s)');
% ylabel('Detrended Down Velocity (m/s)');


% Integrate again to find down displacement data
downDispData = cumtrapz(downVelDataCorrected);
figure;
plot(time, downDispData);
xlabel('Time (s)');
ylabel('Raw Down Displacement (m/s)');


% Attempt to curve fit all of the data after linear drift has been removed
pvalue = 3;
pcd = polyfit(time, downDispData, pvalue);
pvd = polyval(pcd, time);
downDispDataCorrected = downDispData - pvd;
downDispDataCorrected = movmean(downDispDataCorrected, 50);

% Down velocity data corrected polyfit-corrected to attain a shape which
% resembles what we expect from a wave, as well as the polyfitted values
figure;
hold on;
plot(time, downDispData);
plot(time, pvd);
plot(time, downDispDataCorrected);
legend("initial data", "polyfit", "corrected data");
xlabel('Time (s)');
ylabel('Down Displacement (m)');

% Graph of the polyfit that was subtracted
figure;
plot(time, pvd);
xlabel('Time (s)');
ylabel('pcd');

% Now perform turning point analysis on the wave...

% turning point analysis
downDispDataTurningPoints = removeDriftTurningPoints(time, downDispDataCorrected);
