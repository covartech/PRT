function result = prtTestDistance
% This function will test all of the distance functions
result = true;
%% prtDistanceCustom

try
       % prtDistanceCustom also accepts prtDataSet inputs:
    dsx = prtDataSetStandard('Observations',[0 0; 1 1]);
    dsy = prtDataSetStandard('Observations',[1 0; 2 2; 3 3;]);
    distance = prtDistanceCustom(dsx,dsy,@(x,y)sqrt(sum((x-y).^2,2)));
catch ME
    disp ME
    result = false;
end
%% Test prtDistanceChebychev

try
    X = [0 0; 1 1];
    Y = [1 0; 2 2; 3 3;];
    DIST = prtDistanceChebychev(X,Y);
catch ME
    disp(ME)
    result = false;
    disp('error in prtDistanceChebychev')
end

if ~isequal(DIST, [1 2 3; 1 1 2])
    result = false;
    disp('chebychev distance not equal to baseline')
end

%% prtDistanceEarthMover  - completely broken at the moment
try
    d = rand(5,3);                    % Generate some random data
    d = bsxfun(@rdivide,d,sum(d,2));   % Normalize
    
    % Store data in prtDataSetStandard
    DS = prtDataSetStandard('Observations',d);
    % Compute distance
    distance = prtDistanceEarthMover(DS,DS);
catch ME
    disp ME
    result = false;
end


d = [.5 .5;1 0 ];
DS =DS.setObservations(d);

distance = prtDistanceEarthMover(DS,DS);
if any(abs(distance-[0 .5; .5 0])> 1e-8)
    disp('prtDistanceEarthMover baseline fail')
    result = false;
end


%% prtDistanceLNorm
try
    X = [0 0; 1 1];
    Y = [1 0; 2 2; 3 3;];
    DIST = prtDistanceLNorm(X,Y,1);
catch ME
    disp(ME)
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
catch ME
    disp(ME)
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

%% prtDistanceMahalanobis 

X = [0 0; 1 1];      % Create some data, store in prtDataSetStandard
Y = [1 0; 2 2; 3 3;];
dsx = prtDataSetStandard(X);
dsy = prtDataSetStandard(Y);
covMat = [1 0; 0 2;];         % Specify the covariance matrix
% Compute the distance
try
    distance = prtDistanceMahalanobis(dsx,dsy,covMat);
catch ME
    disp(ME)
    result = false;
end
if ~isequal(distance,[ 1 6 13.5; .5, 1.5, 6])
    result = false;
    disp('Mahanlonbis distance not equal to baseline')
end



%% prtDistanceCityBlock

try
    X = [0 0; 1 1];
    Y = [1 0; 2 2; 3 3;];
    DIST = prtDistanceCityBlock(X,Y);
catch ME
    disp(ME)
    result = false;
    disp('error in prtDistanceCityBlock')
end


if ~isequal(DIST, [1 4 6; 1 2 4])
    result = false;
    disp('CityBlock distance not equal to baseline')
end
