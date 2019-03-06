function correctedY = removeDriftTurningPoints(time,yVals)
    turningPoints = findTurningPoints(yVals); % locations of turning points in yVals
    
    % find inflection points
    inflectionPoints = zeros(length(turningPoints) - 1, 2);
    for i = 1:length(inflectionPoints)
        % index of analysed turning points
        t1Index = i;
        t2Index = i + 1;
        
        % avg time
        t = (time(turningPoints(t1Index)) + time(turningPoints(t2Index))) / 2;
        
        % avg y value
        y = (yVals(turningPoints(t1Index)) + yVals(turningPoints(t2Index))) / 2;
        
        inflectionPoints(i, 1) = t;
        inflectionPoints(i, 2) = y;
    end
    
    % take polyfit of inflection points
    pcd = polyfit(inflectionPoints(:, 1),inflectionPoints(:, 2),3);
    pvd = polyval(pcd,time);
    
    % subtract this polyfit
    correctedY = yVals - pvd;
    
    % visuals
    figure;
    hold on;
    plot(time, yVals); % initial curve
    plot(time(turningPoints), yVals(turningPoints), 'O'); % turning points
    plot(inflectionPoints(:, 1), inflectionPoints(:, 2), 'O'); % inflection points
    plot(time, pvd); % polyfit
    legend("initial data", "turning points", "inflection points", "polyfit");
    xlabel('Time (s)');
    ylabel('Down Position (m)');
    
    figure;
    plot(time, correctedY); % new curve
    xlabel('Time (s)');
    ylabel('Down Position (m)');

    % still not perfect
    % https://uk.mathworks.com/matlabcentral/fileexchange/54207-polyfix-x-y-n-xfix-yfix-xder-dydx
end

