% Vertigo
%
% Jon Sowman 2017
% jon+vertigo@jonsowman.com
% Luke Gonsalves 2017
% Get raw data
[csvfile, csvpath] = uigetfile('*.csv');
csvdata = csvread([csvpath csvfile]);

% for greater gps resolution use command below
%csvdata = dlmread([csvpath csvfile]);

csvdata(:,1) = formatLongData(csvdata(:,1)); % for long data

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
    euldata(i,:) = quat2eul(quatdata(i,3:6),'ZYZ');
end
euldata = vtg_quat2eul(quatdata);


t = imudata(:,1); %Time Variable





accel_ned = zeros(length(imudata), 3);
gyro_ned  = zeros(length(imudata), 3);

for i = 1:length(imudata)
    quat_int = interp1(quatdata(:,1), quatdata(:, 3:6), imudata(i,1));
    a = [0 imudata(i, 3:5)];
    g = [0 imudata(i, 6:8)];
    aa = quatmultiply(quatmultiply(quat_int, a), quatconj(quat_int));
    accel_ned(i, :) = aa(2:4);
    gg= quatmultiply(quatmultiply(quat_int, g), quatconj(quat_int));
    gyro_ned(i, :) = gg(2:4);
end

gyro_ned = [imudata(:,1) gyro_ned];


figure
% Plot
subplot(2,1,1);
plot(imudata(:,1), imudata(:, 3:5));
xlabel('Time (s)');
ylabel('Raw accel (g)');
legend('x', 'y', 'z');

subplot(2,1,2);
plot(imudata(:,1), accel_ned);
xlabel('Time (s)');
ylabel('NED accel (g)');
legend('N', 'E', 'D');


figure
subplot(2,1,1);
plot(imudata(:,1), imudata(:, 6:8));
xlabel('Time (s)');
ylabel('Raw gyro (deg/s)');
legend('x', 'y', 'z');

subplot(2,1,2);
plot(imudata(:,1), gyro_ned(:,2:4));
xlabel('Time (s)');
ylabel('NED gyro (deg/s)');
legend('N', 'E', 'D');




z= 2.*((quatdata(:,3).*quatdata(:,6))+(quatdata(:,4).*quatdata(:,5)))
x = 1 - 2.*(((quatdata(:,3).^2)+(quatdata(:,4).^2)))

Phi_radians = atan2(2.*((quatdata(:,3).*quatdata(:,6))+(quatdata(:,4).*quatdata(:,5))),1 - 2.*(((quatdata(:,3).^2)+(quatdata(:,4).^2))))
Phi = (Phi_radians)*180./pi
Theta_radians = asin (2.*(quatdata(:,4).*quatdata(:,6) -   quatdata(:,3).*quatdata(:,5)));
Theta = (Theta_radians).*180./pi
Psi_radians = atan2(2.*((quatdata(:,5).*quatdata(:,6))+(quatdata(:,3).*quatdata(:,4))),1 - 2.*(((quatdata(:,4).^2)+(quatdata(:,5).^2))))
Psi = (Psi_radians).*180./pi
figure;
plot (quatdata(:,1), Phi, quatdata(:,1), Theta, quatdata(:,1), Psi);

xlabel('Time (s)');
ylabel('Rotation/degrees ');
legend('Roll','Pitch', 'Yaw');
