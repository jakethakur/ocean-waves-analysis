% Jon Sowman 2017
% Jamie Costello
% jon+vertigo@jonsowman.com
%
% This file is part of the Vertigo project
%
% Rotate the IMU data into the NED frame using the AHRS data

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
figure;
plot(imudata(:,1), accel_ned);
xlabel('Time (s)');
ylabel('NED accel (g)');
legend('N', 'E', 'D');

% just down position
%plot (imudata(:,1), accel_ned(3, :));
%xlabel('Time (s)');
%ylabel('Down accel (g) ');

prompt = 'What time do you wish to start analysis from? ';
Time_window1 = input(prompt);
prompt = 'What time do you wish to end the analysis? ';
Time_window2 = input(prompt);


figure;
% subplot (2,1,1);
time = [diff(imudata(:,1)); 10];
NorthVel = cumtrapz(imudata(:,1), 9.81 * accel_ned(:,1));
North = cumtrapz(imudata(:,1), NorthVel);
EastVel = cumtrapz(imudata(:,1),  9.81 * accel_ned(:,2));
East = cumtrapz(imudata(:,1), EastVel);
DownVel = cumtrapz(imudata(:,1), (9.81 * (accel_ned(:,3) - 1))); % integrate to velocity
Down = cumtrapz(imudata(:,1), DownVel); % integrate to position
% plot raw positions

%plot (imudata(:,1), North, imudata(:,1), East,imudata(:,1), Down);

%xlabel('Time (s)');
%ylabel('NED Position (m) ')
%legend('N', 'E', 'D');

% raw down vel
plot (imudata(:,1), DownVel);

xlabel('Time (s)');
ylabel('Down Velocity (m) ');

% just down raw position
figure;

plot (imudata(:,1), Down);

xlabel('Time (s)');
ylabel('Down Position (m) ');


%find polyfit coefficient Values for each of North, East Down (PCN, PCE,
%PCD) with polynomial of order 10- which may well be excessive.
% Create a polyfit values (PVN, PVE, PVD) for all times (imudata (:,1) -all times from
% column 1)
pcn = polyfit(imudata(1:end-1,1),North(1:end-1,1),3);
pvn = polyval(pcn,imudata(1:end-1,1));
pce = polyfit(imudata(1:end-1,1),East(1:end-1,1),3);
pve = polyval(pce,imudata(1:end-1,1));
pcd = polyfit(imudata(1:end-1,1),Down(1:end-1,1),3);
pvd = polyval(pcd,imudata(1:end-1,1));

%figure;
% subplot (2,1,2);

%plot (imudata(1:end-1,1), Down(1:end-1,1) - pvd);
%, imudata(:,1), East- pve,imudata(:,1), Down(:)- pvd
%xlabel('Time (s)');
%ylabel('Down Position (m) ');


% 
% 
% %---------------------------------------------------------------

Corrected_North = North (200*Time_window1:200*Time_window2)- pvn(200*Time_window1:200*Time_window2);
Corrected_East = East (200*Time_window1:200*Time_window2)-pve(200*Time_window1:200*Time_window2);
Corrected_Down = Down (200*Time_window1:200*Time_window2)-pvd(200*Time_window1:200*Time_window2);
Time = imudata(200*Time_window1:200*Time_window2,1);

% - imudata(200*Time_window2,1)

% subplot (3,1,3);
% figure;
% plot ( Time, Corrected_Down);
figure;
plot ( Time, Corrected_Down);
%Time, Corrected_North, Time, Corrected_East,
%Not bad.... but there's more to do...
xlabel('Time (s)');
ylabel('Corrected Down Position (m) ');


% turning point analysis
new_Corrected_Down = removeDriftTurningPoints(Time, Corrected_Down);

% find amplitude of waves (peak to peak)
amplitudes = findPeakToPeakAmplitudes(new_Corrected_Down);

% display amplitudes
disp("Amplitudes:");
disp(amplitudes);

% error analysis (Sam)
discrepancy = amplitudes * 0.5 - 0.47;
disp("Discrepancy:");
disp(discrepancy);
