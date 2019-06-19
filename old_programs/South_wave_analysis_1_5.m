prompt = 'What time do you wish to start analysis from? ';
Time_window1 = input(prompt);
prompt = 'What time do you wish to end the analysis? ';
Time_window2 = input(prompt);

% uses variables down (down accel) and time

time = time(220*Time_window1:220*Time_window2);
figure;
% subplot (2,1,1);
downVel = cumtrapz(time, (9.81 * (down(220*Time_window1:220*Time_window2) - 1)));
downDisp = cumtrapz(time, downVel);
% plot raw displacement positions
plot (time, downDisp);

xlabel('Time (s)');
ylabel('D Position (m) ')
legend('D');


%find polyfit coefficient Values for each of North, East Down (PCN, PCE,
%PCD) with polynomial of order 10- which may well be excessive.
% Create a polyfit values (PVN, PVE, PVD) for all times (imudata (:,1) -all times from
% column 1)
pcd = polyfit(time,downDisp,4);
pvd = polyval(pcd,time);
% subplot (2,1,2);
figure;
plot (time, downDisp - pvd);
xlabel('Time (s)');
ylabel('Down Position(m) ')
% xlim([Time_window1 Time_window2]);


