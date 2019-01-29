% formats long vertigo time data to not loop round into negative values
% Jake Thakur 2019

function newData = formatLongData(data)
    newData = zeros(length(data), 1); % preallocate return variable
    
    increaseValue = 0; % initially data has no loops hence is not increased
    
    for i = 2:length(data)
        if data(i) < data(i-1)
            % data has just looped
            % increaseValue = what data should be increased by
            increaseValue = increaseValue + (data(i-1) - data(i));
        end
        
        % increase the data by the increaseValue
        newData(i) = data(i) + increaseValue;
    end
end
