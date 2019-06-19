% Saving data as CSV:
% First run raw vertigo file on load and transform data
% Then run Convert_ocean_data.m to get this saved as a csv

% Loading data from CSV:
% Home -> import data -> select the csv file
% -> output type column vectors -> import selection
% then run this program (which will use the VarName1 and VarName2 vars)

time = VarName1;
rawDownData = VarName2;

smallestRange = 100;
idealSubsection = 1;

% Alternatively the following code can be run instead to use ocean data
% variables straight after load and transform data

% time = imudata(:, 1);
% rawDownData = accel_ned(:, 3);

prompt = 'What time do you wish to start analysis from? ';
Time_window1 = input(prompt);
prompt = 'What time do you wish to end the analysis? ';
Time_window2 = input(prompt);

% Sampling rate of IMU in Hz
sampleRate = 200;

% cut down to time window
time1 = time(sampleRate*Time_window1:sampleRate*Time_window2);
rawDownData1 = rawDownData(sampleRate*Time_window1:sampleRate*Time_window2);

% Convert to accel from Gs
downAccel = (rawDownData1 - 1) * 9.81;

cadence = 5;


% Cut down data to cadence (smaller sampling rate)
% moving mean
aveRawDownData = movmean(downAccel,cadence);
% decimation (alternate method)
%aveRawDownData = decimate(rawDownData,cadence);
%time = decimate(time,cadence);

% Integrate raw data into velocity
downVelData = cumtrapz(aveRawDownData)*0.00005;


% Integrate velocity into displacement
downDispData = cumtrapz(downVelData);

% figure that subsections and their significant wave heights are drawn on
f1 = figure;
hold on;


% Iterate across a range of subsection lengths in order to find the one...
% that is "best" (best concordance of significantWaveHeights)

% subsectionLength = length of subsections that drift removal is applied to

subsectionLengthMin = 1;
subsectionLengthInterval = 1;
subsectionLengthMax = 20;

lengths = subsectionLengthMin:subsectionLengthInterval:subsectionLengthMax;

sigWaveHeights = []; % simply an empty matrix for later

for subsectionLength = subsectionLengthMin:subsectionLengthInterval:subsectionLengthMax
    
    % number of subsections at this subsectionLength
    numberOfSubsections = floor(length(time1) / (sampleRate*subsectionLength));
    
    % where corrected down displacement data is stored
    downDispDataCorrected = zeros(length(downDispData), 1);
    
    % iterate through each subsection, removing drift from each individually
    for i = 1:numberOfSubsections

        % Positions of data analysis
        startPos = (i-1)*sampleRate*subsectionLength+ 1;
        endPos = i*sampleRate*subsectionLength;
        
        % Attempt to curve fit all of the data using a polyfit
        pvalue = 2; % TBD decide which is best
        pcd = polyfit...
            (time1(startPos:endPos), downDispData(startPos:endPos), pvalue);
        pvd = polyval(pcd, time1(startPos:endPos));
        downDispDataCorrected(startPos:endPos) = ...
            downDispData(startPos:endPos) - pvd;

    end

    % Plot displacement wave graph for this subsection length 
    % (each individual section is a different colour):
    figure;
    hold on;

    for i = 1:numberOfSubsections

        startPos = (i-1)*sampleRate*subsectionLength + 1;
        endPos = i*sampleRate*subsectionLength;

        plot(time1(startPos:endPos), downDispDataCorrected(startPos:endPos));

    end

    % Labels for final displacement wave graph for this subsection length
    xlabel('Time (s)');
    ylabel('Down Displacement (m)');
    title(['Sub. Length = ', num2str(subsectionLength)]); 
    
    % output information to console
    disp(num2str(subsectionLength)); 
    sigWaveHeight = waveStatistics(movmean(downDispDataCorrected,100));
    
    % array of sig wave heights for each subsection length
    sigWaveHeights = [sigWaveHeights, sigWaveHeight];
   
    figure(f1);
    
    % add this subsection length to the graph of sig. wave heights vs...
    % subsection length
    scatter(subsectionLength, sigWaveHeight);
    xlabel('Length of subsection /s');
    ylabel('sigWaveHeight /m');
    
end

lengthsHeights = [lengths; sigWaveHeights];

for i = 2:length(lengthsHeights)-1
     adjacents = [lengthsHeights(2,i), lengthsHeights(2,i-1), lengthsHeights(2,i+1)];
     if (std(adjacents) < smallestRange)
         idealSubsection = i;
         smallestRange = std(adjacents);
     end
end 

 disp(['Ideal subsection length: ', num2str(idealSubsection)]);
 disp('Sig wave height at ideal subsection length:');
 disp(sigWaveHeights(idealSubsection));

