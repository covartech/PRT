function result = prtTestDistance
% This function will test all of the distance functions
result = true;
% prtDistanceCustom not tested, as it is used by all other functions.

%% Test prtDistanceChebychev

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
    disp('chebychev distance not equal to baseline')
end

%% prtDistanceEarthMover  - completely broken at the moment

%% prtDistanceLNorm
try
    X = [0 0; 1 1];
    Y = [1 0; 2 2; 3 3;];
    DIST = prtDistanceLNorm(X,Y,1);
catch
    result = false;
    disp('error in prtDistanceLNorm')
end

if ~isequal(DIST, [1 4 6; 1 2 4])
    result = false;
    disp('LNorm distance not equal to baseline')
end

% Check that X and Y are correct dim
try
    X = [0 ;  1];
    Y = [1 0; 2 2; 3 3;];
    DIST = prtDistanceLNorm(X,Y,1);
    result = false;
catch
    % Do nothing
end

%% prtDistanceEuclidean

try
    X = [0 0; 1 1];
    Y = [0 0; 2 2; 3 3;];
    DIST = prtDistanceEuclidean(X,Y);
catch
    result = false;
    disp('error in prtDistanceEuclideAN')
end

if max(max(abs(DIST - [0  2*sqrt(2) 3*sqrt(2); sqrt(2) sqrt(2) 2*sqrt(2)]))) > 1e-15
    result = false;
    disp('Euclidean distacne not equal to baseline')
end

% Check that X and Y are correct dim
try
    X = [0 ;  1];
    Y = [1 0; 2 2; 3 3;];
    DIST = prtDistanceEuclidean(X,Y);
    result = false;
catch
    % Do nothing
end

%% prtDistanceMahalanobis -- Broken

%% prtDistanceBhattacharrya -- should it take prtDataSet as input?

%% prtDistanceCityBlock

try
    X = [0 0; 1 1];
    Y = [1 0; 2 2; 3 3;];
    DIST = prtDistanceCityBlock(X,Y);
catch
    result = false;
    disp('error in prtDistanceCityBlock')
end


if ~isequal(DIST, [1 4 6; 1 2 4])
    result = false;
    disp('CityBlock distance not equal to baseline')
end
