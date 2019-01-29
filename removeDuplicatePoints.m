% removes duplicate data points in the 'colCheck'th column, and also removes these
% data points from other columns
% Jake Thakur 2019

function newData = removeDuplicatePoints(data, colCheck)
    duplicatePoints = [];
    
    dataSize = size(data);
    
    newData = [];
    
    % find all unique datapoints from column
    for i = 1:dataSize(2)
        if ~ismember(data(colCheck, i), duplicatePoints)
            % unique
        else
            % not unique
            duplicatePoints(end+1) = i;
        end
    end
    
    % add all datapoints that are not duplicated in 'colCheck'th column
    for x = 2:dataSize(1)
        for i = 1:dataSize(2)
            if ismember(i, duplicatePoints)
                % unique
                newData(x, end+1) = data(x, i);
            end
        end
    end
end
