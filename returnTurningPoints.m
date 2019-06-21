function [turningPointTimes, turningPointYVals] = returnTurningPoints(time, yVals)
    turningPoints = findTurningPoints(yVals);
    
    turningPointTimes = time(turningPoints(1));
    turningPointYVals = yVals(turningPoints(1));
    
    % find range of yVals so it can be ensured that turning points are not
    % too close
    lowest = Inf(1);
    highest = -Inf(1);
    for i = 1:length(yVals)
        if yVals(i) < lowest
            lowest = yVals(i);
        end
        if yVals(i) > highest
            highest = yVals(i);
        end
    end
    range = highest - lowest;
    
    for i = 2:length(turningPoints)
        % ensure points are not within 1/10th of the position range of each
        % other
        if abs(yVals(turningPoints(i)) - yVals(turningPoints(i-1))) > range/10
            turningPointTimes = [turningPointTimes time(turningPoints(i))];
            turningPointYVals = [turningPointYVals yVals(turningPoints(i))];
        end
    end
end

