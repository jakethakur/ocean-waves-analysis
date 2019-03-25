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

% Sampling rate of IMU in Hz
sampleRate = 200;

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

% Integrate velocity into displacement
downDispData = cumtrapz(downVelData);

% Plot raw down displacement
figure;
plot(time, downDispData);
xlabel('Time (s)');
ylabel('Raw Down Displacement (m)');


% Iterate through subsections of the data

% lengths in seconds
lengthOfRemoval = 30; % length of proportion of interval that drift removal
% is applied to
numberOfIntervals = round(length(time) / (sampleRate*lengthOfRemoval));

downDispDataCorrected = zeros(length(downDispData), 1);

for i = 1:numberOfIntervals
    
    % Positions of data analysis
    startPos = (i-1)*sampleRate*lengthOfRemoval + 1;
    endPos = i*sampleRate*lengthOfRemoval;
    
    % Init subplot for this interval
    figure;
    % Raw data plot
    subplot(2,2,1);
    plot(time(startPos:endPos), downDispData(startPos:endPos));
    title('1: Raw Data');
    xlabel('Time (s)');
    ylabel('Down Displacement (m)');

    % Attempt to curve fit all of the data after linear drift has
    % been removed
    pvalue = 2; % TBD decide which is best
    pcd = polyfit...
        (time(startPos:endPos), downDispData(startPos:endPos), pvalue);
    pvd = polyval(pcd, time(startPos:endPos));
    downDispDataCorrected(startPos:endPos) = ...
        downDispData(startPos:endPos) - pvd;
    
    % Plot data with polyfit subtracted
    subplot(2,2,2);
    plot(time(startPos:endPos), downDispDataCorrected(startPos:endPos));
    title('2: Polyfit subtracted from data');
    xlabel('Time (s)');
    ylabel('Down Displacement (m)');
    
    % Plot polyfit
    subplot(2,2,3);
    plot(time(startPos:endPos), pvd);
    title('Polyfit');
    xlabel('Time (s)');
    ylabel('pvd');
    
end

% Plot displacement wave graph (each individual section different colour):
figure;
hold on;

for i = 1:numberOfIntervals
    
    startPos = (i-1)*sampleRate*lengthOfRemoval + 1;
    endPos = i*sampleRate*lengthOfRemoval;
    
    plot(time(startPos:endPos), downDispDataCorrected(startPos:endPos));
    
end

% Labels for final displacement wave graph
xlabel('Time (s)');
ylabel('Down Displacement (m)');

% Now perform turning point analysis on the wave...
