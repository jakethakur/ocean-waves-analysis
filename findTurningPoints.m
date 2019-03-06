function positions = findTurningPoints(yVals)
    a = yVals(1:end-2);
    b = yVals(2:end-1);
    c = yVals(3:end);
    positions = find((b<a & b<c) | (b>a & b>c)) +1; % locations of turning points in yVals
end
