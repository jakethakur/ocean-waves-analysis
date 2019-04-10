% 
% This file is part of the VertigoIMU project
%
% Jon Sowman 2017
% jon+vertigo@jonsowman.com
%
% Luke Gonsalves 2017
%

sampleRate = 200; % imu sample rate in Hz

% Add utilities to path
addpath(genpath('vtg_utils'));

% Get raw data
[csvfile, csvpath] = uigetfile('*.csv');
csvdata = readtable([csvpath csvfile], 'Delimiter',',','ReadVariableNames',false);
% convert date to ms
times = seconds(datetime(table2cell(csvdata(:,1)), 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSS') - datetime(2018,1,1))*1000;
csvdata.Var1 = times;
csvdata = table2array(csvdata);

% Fix timer rollover
all_times = csvdata(:,1);
rollover = 0;
for i = 2:length(all_times)
    all_times(i) = all_times(i) + rollover;
    
    if all_times(i) < all_times(i-1)
       % rollover has occured, add to rollover variable
       extraRollover = (all_times(i-1) - all_times(i)) + (1000/sampleRate);
       rollover = rollover + extraRollover;
       
       all_times(i) = all_times(i) + extraRollover;
    end
end
csvdata(:,1) = all_times;

% Split into GPS and IMU data
gpsidx = find(csvdata(:,2) == 1);
imuidx = find(csvdata(:,2) == 2);
quatidx = find(csvdata(:,2) == 3);
gpsdata = csvdata(gpsidx, :);
imudata = csvdata(imuidx, :);
quatdata = csvdata(quatidx, :);

% Adjust all times
gpsdata(:,1) = (gpsdata(:,1) - gpsdata(1,1)) / 1000;
imudata(:,1) = (imudata(:,1) - imudata(1,1)) / 1000;
quatdata(:,1) = (quatdata(:,1) - quatdata(1,1)) / 1000;

% Do quaternion->Euler conversion
euldata = zeros(length(quatdata), 3);
for i = 1:length(quatdata)
    euldata(i,:) = vtg_quat2eul(quatdata(i,3:6));
end

t = imudata(:,1); % Time Variable

plot(quatdata(:,1), euldata);
xlabel('Time (s)');
ylabel('Orientation (deg)');
legend('roll', 'pitch', 'yaw');

accel_ned = zeros(length(imudata), 3);
gyro_ned  = zeros(length(imudata), 3);

% Create NED frame data by using pqp'
for i = 1:length(imudata)
    quat_int = interp1(quatdata(:,1), quatdata(:, 3:6), imudata(i,1));
    a = [0 imudata(i, 3:5)];
    g = [0 imudata(i, 6:8)];
    aa = quatmultiply(quatmultiply(quat_int, a), quatconj(quat_int));
    accel_ned(i, :) = aa(2:4);
    gg= quatmultiply(quatmultiply(quat_int, g), quatconj(quat_int));
    gyro_ned(i, :) = gg(2:4);
end

% Plot results
figure
subplot(4,1,1);
plot(imudata(:,1), imudata(:, 3:5));
xlabel('Time (s)');
ylabel('Raw accel (g)');
legend('x', 'y', 'z');

subplot(4,1,2);
plot(imudata(:,1), accel_ned);
xlabel('Time (s)');
ylabel('NED accel (g)');
legend('N', 'E', 'D');

subplot(4,1,3);
plot(imudata(:,1), imudata(:, 6:8));
xlabel('Time (s)');
ylabel('Raw gyro (deg/s)');
legend('x', 'y', 'z');

subplot(4,1,4);
plot(imudata(:,1), gyro_ned);
xlabel('Time (s)');
ylabel('NED gyro (deg/s)');
legend('N', 'E', 'D');

% end
