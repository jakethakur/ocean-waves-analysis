% 
% t = VarName1;
% New_time = zeros(length(t),3);
% DateString = zeros(length(t), 3);
% 
% 
% for x = 1:length(t)
% formatOut = 'MM SS FFF';
% DateString = datestr(datenum(t(x,1), 'yyyy-mm-dd HH:MM:SS.FFF'),formatOut);
% New_time(x,:) = str2num(DateString);
% end
% 
% for x = 1:length(t)
%     final_time(x,1) = 60000*New_time(x,1)+1000*New_time(x,2)+1*New_time(x,3); 
% end
% 
% 
% 
% for x = 2:length(t)
%     final_time(x,1) = final_time(x,1)- 19860; 
% end
% 
% 
% csvdata = [final_time VarName2 VarName3 VarName4 VarName5 VarName6 VarName7 VarName8 VarName9 VarName10];
% 
% 
% 
% 
% % all_times = csvdata(:,1);
% 
% % Split into GPS and IMU data
% imuidx = find(csvdata(:,2) == 2);
% quatidx = find(csvdata(:,2) == 3);
% imudata = csvdata(imuidx, :);
% quatdata = csvdata(quatidx, :);
% 
% % Adjust all times
% 
% imudata(:,1) = (imudata(:,1) - imudata(1,1)) / 1000;
% quatdata(:,1) = (quatdata(:,1) - quatdata(1,1)) / 1000;
% 
% % Do quaternion->Euler conversion
% euldata = zeros(length(quatdata), 3);
% for i = 1:length(quatdata)
%     euldata(i,:) = vtg_quat2eul(quatdata(i,3:6));
% end
% 
% t = imudata(:,1); % Time Variable
% accel_ned = zeros(length(imudata), 3);
% gyro_ned  = zeros(length(imudata), 3);
% 
% % Create NED frame data by using pqp'
% for i = 1:length(imudata)
%     quat_int = interp1(quatdata(:,1), quatdata(:, 3:6), imudata(i,1));
%     a = [0 imudata(i, 3:5)];
%     g = [0 imudata(i, 6:8)];
%     aa = quatmultiply(quatmultiply(quat_int, a), quatconj(quat_int));
%     accel_ned(i, :) = aa(2:4);
%     gg= quatmultiply(quatmultiply(quat_int, g), quatconj(quat_int));
%     gyro_ned(i, :) = gg(2:4);
% end

% figure;
% plot(imudata(:,1), accel_ned);
% xlabel('Time (s)');
% ylabel('NED accel (g)');
% legend('N', 'E', 'D');


prompt = 'What time do you wish to start analysis from? ';
Time_window1 = input(prompt);
prompt = 'What time do you wish to end the analysis? ';
Time_window2 = input(prompt);

accel_ned(end,:) = accel_ned(end-1,:);
figure;
% subplot (2,1,1);
time = [diff(imudata(:,1)); 10];
North = cumtrapz(imudata(220*Time_window1:220*Time_window2,1), 9.81 * accel_ned(220*Time_window1:220*Time_window2,1));
North = cumtrapz(imudata(220*Time_window1:220*Time_window2,1), North);
East = cumtrapz(imudata(220*Time_window1:220*Time_window2,1),  9.81 * accel_ned(220*Time_window1:220*Time_window2,2));
East = cumtrapz(imudata(220*Time_window1:220*Time_window2,1), East);
Down = cumtrapz(imudata(220*Time_window1:220*Time_window2,1), (9.81 * (accel_ned(220*Time_window1:220*Time_window2,3) - 1)));
Down = cumtrapz(imudata(220*Time_window1:220*Time_window2,1), Down);
%plot raw positions
plot (imudata(220*Time_window1:220*Time_window2,1), North, imudata(220*Time_window1:220*Time_window2,1), East,imudata(220*Time_window1:220*Time_window2,1), Down);

xlabel('Time (s)');
ylabel('NED Position(m) ')
legend('N', 'E', 'D');


%find polyfit coefficient Values for each of North, East Down (PCN, PCE,
%PCD) with polynomial of order 10- which may well be excessive.
% Create a polyfit values (PVN, PVE, PVD) for all times (imudata (:,1) -all times from
% column 1)
pcn = polyfit(imudata(220*Time_window1:220*Time_window2,1),North,4);
pvn = polyval(pcn,imudata(220*Time_window1:220*Time_window2,1));
pce = polyfit(imudata(220*Time_window1:220*Time_window2,1),East,4);
pve = polyval(pce,imudata(220*Time_window1:220*Time_window2,1));
pcd = polyfit(imudata(220*Time_window1:220*Time_window2,1),Down(:),4);
pvd = polyval(pcd,imudata(220*Time_window1:220*Time_window2,1));

% subplot (2,1,2);
figure;
plot (imudata(220*Time_window1:220*Time_window2,1), Down - pvd);
%, imudata(:,1), East- pve,imudata(:,1), Down(:)- pvd
xlabel('Time (s)');
ylabel('Down Position(m) ')
% xlim([Time_window1 Time_window2]);





%---------------------------------------------------------------
% the next section zoom in on a particular time-window chosen by the user


% Corrected_North = North; 
% Corrected_East = East; 
% Down =;
Time = imudata(220*Time_window1:220*Time_window2,1);


