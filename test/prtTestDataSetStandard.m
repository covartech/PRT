function result = prtTestDataSetStandard
result = true;

% Check that we can instantiate a data set
try
    dataSet = prtDataSetStandard;
    result = true;
catch
    result = false;
end

% Check that we can set the observations and targets.
try
    dataSet = prtDataSetStandard;
    dataSet =  dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
    result = true;
catch
    result = false;
end


try
    dataSet = prtDataSetStandard;
    dataSet = dataSet.setX([1 2; 3 4; 5 6]);
    dataSet = dataSet.setY([1 2 3]');
    result = true;
catch
    result = false;
end


dataSet = prtDataSetStandard('Observations',[1 2; 3 4; 5 6],'Targets', [1;2;3]);
if ( ~isequal(dataSet.getX() ,[1 2; 3 4; 5 6]) ||( ~isequal(dataSet.getY(),[1;2;3])))
    result = false;
end




dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
% Check features and dims
if (dataSet.nFeatures ~=2) || (dataSet.nObservations ~=3)
    result = false;
end


dataSet =  dataSet.setFeatureNames({'Sam';'Man'});
if ( ~isequal(dataSet.getFeatureNames(), {'Sam';'Man'}))
    result = false;
end

% XXX
% dataSet = dataSet.setTargetNames({'Sam';'The';'Man'});
% if ( ~isequal(dataSet.getTargetNames(),{'Sam';'The';'Man'}))
%     result = false;
% end

% 
dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
dataSet1 = dataSet.catFeatures([ 7 8 9 ]');
if ~isequal(dataSet1.getX, [ 1 2 7; 3 4 8; 5 6 9]) 
    result = false;
end

dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
dataSet1 = dataSet.catObservations([7 8]);
if( ~isequal(dataSet1.getX, [1 2;3 4; 5 6; 7 8 ]))
    result = false;
end

dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
dataSet = dataSet.removeObservations(2);
if ~isequal(dataSet.getX(), [1 2; 5 6])
    result = false;
end


dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
dataSet = dataSet.removeFeatures(2);
if ~isequal(dataSet.getX(), [1;3;5])
    result = false;
end

dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1 2; 2 3; 3 4]);
dataSet = dataSet.retainTargets(1);
if ~isequal(dataSet.getY(), [1 2 3]')
    result = false;
end


dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
dataSet = dataSet.retainFeatures(1);
if ~isequal(dataSet.getX(), [ 1 3 5]');
    result = false;
end

dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
data = dataSet.getFeatures(2);
if  ~isequal(data,[2 4 6]')
    result = false;
end

dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
dataSet = dataSet.setFeatures([7 8 9]', 2);
if  ~isequal(dataSet.getFeatures(2),[7 8 9]')
    result = false;
end


dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
dataSet = dataSet.retainObservations(1);
if ~isequal(dataSet.getX(), [ 1 2]);
    result = false;
end

dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1 2; 2 3; 3 4]);
dataSet1 = dataSet.retainTargets(1);
if ~isequal(dataSet1.getY(), [ 1 2 3]');
    result = false;
end

% Check setting higher dimension target data
dataSet = prtDataSetStandard;
dataSet = dataSet.setX([ 1 2]');
dataSet = dataSet.setY([1 2; 3 4]);
if (~isequal(dataSet.getY(), [1 2;3 4]) || ~isequal(dataSet.nTargetDimensions, 2))
    result = false;
end

% XXX
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setX([ 1 2]');
% dataSet = dataSet.setY([1 2; 3 4]);
% % Not sure what the desired behavior here is?
% %dataSet = dataSet.setY([8; 8], [1 2])
% 

% Check indexing into X
dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
if( dataSet.getX(3,2) ~= 6)
    result = false;
end
dataSet = dataSet.setObservations(8, 3,2);
if( dataSet.getX(3,2) ~= 8)
    result = false;
end

% XXX
% % cat targets
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; ], [1; 2; ]);
% dataSet = dataSet.catTargets([3;4]);
% if ~isequal(dataSet.getTargets, [1 2;3 4]);
%     result = false;
% end

% Test boostrap 
dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
dataSet = dataSet.bootstrap(2);
if (dataSet.nObservations ~=2)
    result = false;
end


% Check user data
s = struct('Sam',{'Rules', 'Man'}, 'Man', 'Hot damn');
dataSet = prtDataSetStandard;
dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; ], [1; 2; ]);
try
    dataSet.ObservationDependentUserData = s;
    if ~isequal(dataSet.ObservationDependentUserData, s)
        result = false;
    end
catch
    result = false;
end
        
 
%%
%% Error checks

error = true;  % We will want all these things to error


try  % Make sure we can't instantiate base class
    dataSet = prtDataSet;
    error = false;  % Set it to false if the preceding operation succeeded
catch
    % do nothing
    % We can potentially catch and check the error string here
    % For now, just be happy it is erroring out.
end

dataSet = prtDataSetStandard;
try
    dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; ]);
    error = false;
catch
    
end

dataSet = prtDataSetStandard;
dataSet = dataSet.setX([1 2; 3 4; 5 6]);
try
    dataSet = dataSet.setY([1; 2]);
    error = false;
catch
    
end


result = result & error;% & noerror;