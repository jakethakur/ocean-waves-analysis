
addpath(genpath('vtg_utils'));

% Get raw data
[csvfile, csvpath] = uigetfile('*.csv');
csvdata = csvread([csvpath csvfile]);

% Fix timer rollover
rollover = 2^32/1e4; % todo: import from config
all_times = csvdata(:,1);
% delta_times = find(diff(all_times) < 0);
delta_times = find(diff(all_times) < -100000);
for i = 1:length(delta_times)
    all_times(delta_times(i)+1:end) = all_times(delta_times(i)+1:end) ...
        + rollover;
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

figure;
plot(imudata(:,1), accel_ned);
xlabel('Time (s)');
ylabel('NED accel (g)');
legend('N', 'E', 'D');

prompt = 'Which orientation looks best - North (1) or East (2)?';

Direction = input(prompt);


prompt = 'What time do you wish to start analysis from? ';
Time_window1 = input(prompt);
% input error checking
if Time_window1 == 0
    disp("Start index cannot be 0. It has been set to 1.");
    Time_window1 = 1;
end

prompt = 'What time do you wish to end the analysis? ';
Time_window2 = input(prompt);

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




accel_ned(end,:) = accel_ned(end-1,:);


time = [diff(imudata(:,1)); 10];
North = cumtrapz(imudata(100*Time_window1:100*Time_window2,1), 9.81 * accel_ned(100*Time_window1:100*Time_window2,1));
North = cumtrapz(imudata(100*Time_window1:100*Time_window2,1), North);
East = cumtrapz(imudata(100*Time_window1:100*Time_window2,1),  9.81 * accel_ned(100*Time_window1:100*Time_window2,2));
East = cumtrapz(imudata(100*Time_window1:100*Time_window2,1), East);
Down = cumtrapz(imudata(100*Time_window1:100*Time_window2,1), (9.81 * (accel_ned(100*Time_window1:100*Time_window2,3) - 1)));
Down = cumtrapz(imudata(100*Time_window1:100*Time_window2,1), Down);
%plot raw positions



%find polyfit coefficient Values for each of North, East Down (PCN, PCE,
%PCD) with polynomial of order 10- which may well be excessive.
% Create a polyfit values (PVN, PVE, PVD) for all times (imudata (:,1) -all times from
% column 1)
pcn = polyfit(imudata(100*Time_window1:100*Time_window2,1),North,4);
pvn = polyval(pcn,imudata(100*Time_window1:100*Time_window2,1));
pce = polyfit(imudata(100*Time_window1:100*Time_window2,1),East,4);
pve = polyval(pce,imudata(100*Time_window1:100*Time_window2,1));
pcd = polyfit(imudata(100*Time_window1:100*Time_window2,1),Down(:),4);
pvd = polyval(pcd,imudata(100*Time_window1:100*Time_window2,1));



if Direction == 1
%     
%    figure;
%     plot (imudata(100*Time_window1:100*Time_window2,1), North - pvn);
%     
% xlabel('Time (s)');
% ylabel('North Position(m) ')
% xlim([Time_window1 (Time_window2-1)]);

Time = imudata(100*Time_window1:100*Time_window2,1);

north = North - pvn;
% 
% 
figure;
subplot(3,1,1);
    plot (Time, north)
    xlabel('Time (s)');
    ylabel('Corrected North Position(m)');
    xlim([Time_window1 (Time_window2-1)]);
    subplot(3,1,2);
    plot (Time(1:end-1), 100*diff(north));
  xlabel('Time (s)');
    ylabel('North Velocity/ m/s');
     xlim([Time_window1 (Time_window2-1)]);
    subplot(3,1,3);
    plot (Time(1:end-2), movmean(100*diff(diff(north)),20));
  xlabel('Time (s)');
    ylabel('North Acceleration / m/s2');
     xlim([Time_window1 (Time_window2-1)]);
end
    
 if Direction == 2

Time = imudata(100*Time_window1:100*Time_window2,1);

east = East - pve;
figure;
subplot(3,1,1);
    plot (Time, east)
    xlabel('Time (s)');
    ylabel('East Position(m)');
    xlim([Time_window1 (Time_window2-1)]);
    subplot(3,1,2);
    plot (Time(1:end-1), 200*diff(east));
  xlabel('Time (s)');
    ylabel('East Velocity/ m/s');
     xlim([Time_window1 (Time_window2-1)]);
    subplot(3,1,3);
    plot (Time(1:end-2), movmean(100*diff(diff(east)),20));
  xlabel('Time (s)');
    ylabel('North Acceleration / m/s2');
     xlim([Time_window1 (Time_window2-1)]);
     
 end

 if Direction == 3

Time = imudata(100*Time_window1:100*Time_window2,1);

down = Down - pvd;
figure;
subplot(3,1,1);
    plot (Time, down)
    xlabel('Time (s)');
    ylabel('Down Position(m)');
    xlim([Time_window1 (Time_window2-1)]);
    subplot(3,1,2);
    plot (Time(1:end-1), 100*diff(down));
  xlabel('Time (s)');
    ylabel('Down Velocity/ m/s');
     xlim([Time_window1 (Time_window2-1)]);
    subplot(3,1,3);
    plot (Time(1:end-2), movmean(100*diff(diff(down)),20));
  xlabel('Time (s)');
    ylabel('Down Acceleration / m/s2');
     xlim([Time_window1 (Time_window2-1)]);
     
 end






