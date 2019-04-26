% Run after ocean waves analysis

FFTinput = downDispData(1:30000); % input variable


xdft = fft(FFTinput(:,1));
% uses the Nth FFTinput(:,N) colum of the imu data 


     % sampling interval -- assuming equal sampling
%      DT = imudata(2,1)-imudata(1,1);
DT = 0.005;
     % sampling frequency
     Fs = 1/DT;
     DF = Fs/length(FFTinput);
     freq = 0:DF:Fs/2;
     Freq = freq';
     xdft = xdft(1:round(length(xdft)/2,1));
     figure;
     z= abs(xdft);
     plot(Freq(1:end-1,1),movmean(z(:,1),50));
     xlim([0.0 1.5]);
     title('Accel')
xlabel('f /Hz')
ylabel('Relative Amplitude')