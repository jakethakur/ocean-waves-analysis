prompt = 'What time do you wish to start analysis from? ';
Time_window1 = input(prompt);
prompt = 'What time do you wish to end the analysis? ';
Time_window2 = input(prompt);

% uses variables down (down accel) and time

figure;
% subplot (2,1,1);
downVel = cumtrapz(time(220*Time_window1:220*Time_window2), (9.81 * (down(220*Time_window1:220*Time_window2) - 1)));
downDisp = cumtrapz(time(220*Time_window1:220*Time_window2), downVel);
% plot raw displacement positions
plot (time(220*Time_window1:220*Time_window2), downDisp);

xlabel('Time (s)');
ylabel('D Position (m) ')
legend('D');


%find polyfit coefficient Values for each of North, East Down (PCN, PCE,
%PCD) with polynomial of order 10- which may well be excessive.
% Create a polyfit values (PVN, PVE, PVD) for all times (imudata (:,1) -all times from
% column 1)
pcd = polyfit(time(220*Time_window1:220*Time_window2),downDisp,4);
pvd = polyval(pcd,time(220*Time_window1:220*Time_window2));

% subplot (2,1,2);
figure;
plot (time(220*Time_window1:220*Time_window2), downDisp - pvd);
xlabel('Time (s)');
ylabel('Down Position(m) ')
% xlim([Time_window1 Time_window2]);


