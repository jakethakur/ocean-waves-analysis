function correctedY = removeDriftTurningPoints(time,yVals)
    % locations of turning points
    [turningPointTimes,turningPointYVals] = returnTurningPoints(time, yVals);
    
    % find equilibrium points
    equilibriumPoints = zeros(length(turningPointTimes) - 1, 2);
    for i = 1:length(equilibriumPoints)
        % index of analysed turning points
        t1Index = i;
        t2Index = i + 1;
        
        % avg time
        t = (turningPointTimes(t1Index) + turningPointTimes(t2Index)) / 2;
        
        % avg y value
        y = (turningPointYVals(t1Index) + turningPointYVals(t2Index)) / 2;
        
        equilibriumPoints(i, 1) = t;
        equilibriumPoints(i, 2) = y;
    end
    
    % take polyfit of equilibrium points
    pvalue = 4;
    pcd = polyfit(equilibriumPoints(:, 1),equilibriumPoints(:, 2),pvalue);
    pvd = polyval(pcd,time);
    
    % subtract this polyfit
    correctedY = yVals - pvd;
    
    % visuals
    figure;
    hold on;
    plot(time, yVals); % initial curve
    plot(turningPointTimes, turningPointYVals, 'O'); % turning points
    plot(equilibriumPoints(:, 1), equilibriumPoints(:, 2), 'O'); % equilibrium points
    plot(time, pvd); % polyfit
    legend("initial data", "turning points", "equilibrium points", "polyfit");
    xlabel('Time (s)');
    ylabel('Down Position (m)');
    
    figure;
    plot(time, correctedY); % new curve
    xlabel('Time (s)');
    ylabel('Down Position (m)');

    % still not perfect
    % https://uk.mathworks.com/matlabcentral/fileexchange/54207-polyfix-x-y-n-xfix-yfix-xder-dydx
end

