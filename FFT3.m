
FFTinput = (accel_ned(:,1));


xdft = fft(FFTinput(:,1));
% uses the Nth FFTinput(:,N) colum of the imu data 


     % sampling interval -- assuming equal sampling
%      DT = imudata(2,1)-imudata(1,1);
DT = 0.01
     % sampling frequency
     Fs = 1/DT;
     DF = Fs/length(FFTinput);
     freq = 0:DF:Fs/2;
    Freq = freq'
     xdft = xdft(1:round(length(xdft)/2,1));
     figure;
     z= abs(xdft);
     plot(Freq(1:50,1),z(1:50,1));
     xlim([0.2 1]);
     title('Accel')
xlabel('f /Hz')
ylabel('Relative Amplitude')