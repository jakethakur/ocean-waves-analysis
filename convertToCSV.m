% run after load and transform to save the variables to a csv

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

%Ocean_data = [imudata(1:30001,1) accel_ned(1:30001,3)];
Ocean_data = [imudata(1:length(imudata),1) accel_ned(1:length(imudata),3)];

csvwrite('Ocean_data1.csv',Ocean_data);

