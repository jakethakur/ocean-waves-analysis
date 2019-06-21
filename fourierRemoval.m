% Drift removal using fourier transformed wave
% Run after fourierTransform.m

% Thanks to https://dsp.stackexchange.com/a/9056

maxFreq = 1;
xdftNew = zeros(length(xdft), 1);
for i = 1:length(xdft)
    if Freq(i,1) > maxFreq
        xdftNew(i) = 0;
    else
        xdftNew(i) = xdft(i);
    end
end
zNew = abs(xdftNew);
%zNew = movmean(zNew(:,1),50); % moving mean

figure;

plot(Freq(1:end-1,1),zNew);

% limit the x values shown on the graph
% (play around with these values to get a useful graph)
axisMin = 0.0;
axisMax = 2.5;
xlim([axisMin axisMax]);

title('Displacement')
xlabel('f/Hz')
ylabel('Relative Amplitude')

% Convert back...

filtered_samples = ifft(xdft);
figure;
plot(time1, filtered_samples);

xlabel('Time (s)')
ylabel('Down displacement (m)')
