% Run after ocean waves analysis or after importing data

FFTinput = VarName2(1:end); % input variable

%
% Fourier transform
%

xdft = fft(FFTinput(:,1));
% uses the Nth FFTinput(:,N) colum of the imu data 

z = abs(xdft);

z = movmean(z(:,1),50); % moving mean

% 
% X axis (frequency)
%

% sampling interval -- assuming equal sampling
% samplingInterval = imudata(2,1)-imudata(1,1);
samplingInterval = 0.005;
samplingFrequency = 1/samplingInterval;

DF = samplingFrequency/length(FFTinput); % 1/seconds
freq = 0:DF:samplingFrequency; % length = seconds * sampling frequency
Freq = freq'; % transpose to column vector

%
% Graph
%

figure;
plot(Freq(1:end-1,1),z);

% limit the x values shown on the graph
% (play around with these values to get a useful graph)
xlim([0.0 1.5]); 

title('Accel')
xlabel('f /Hz')
ylabel('Relative Amplitude')
