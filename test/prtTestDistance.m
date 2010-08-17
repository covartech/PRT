function result = prtTestDistance
% This function will test all of the distance functions
result = true;
% Test prtDistanceChebychev

try 
      X = [0 0; 1 1];
    Y = [1 0; 2 2; 3 3;];
    DIST = prtDistanceChebychev(X,Y);
catch
    result = false;
    disp('error in prtDistanceChebychev')
end

if ~isequal(DIST, [1 2 3; 1 1 2])
    result = false;
    disp('chebychev distacne not equal to baseline')
end