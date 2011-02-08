function result = prtTestEvalMinCost
% This function tests prtEvalMinCost
result = true;
% Basic operation
try
    dataSet = prtDataGenSpiral;
    classifier = prtClassDlrt;
    cost = [0 1;1 0];
    score = prtEvalMinCost(classifier,dataSet,cost);
catch
    disp('error #1, prtEvalMinCost failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99)< .01) 
    disp('error #2, prtEvalMinCost wrong score')
    result = false;
end


% Basic operation, kfolds
try
    dataSet = prtDataGenSpiral;
    classifier = prtClassDlrt;
    cost = [0 1;1 0];
    score = prtEvalMinCost(classifier,dataSet,cost, 10);
catch
    disp('error #2, prtScoreMinCostKfolds failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99) < .05) 
    disp('error #3, prtScoreMinCostKfolds wrong score')
    result = false;
end


dataSet = prtDataGenSpiral;
classifier = prtClassDlrt;
cost = [0 1;1 0];
[score, pf, pd] = prtEvalMinCost(classifier,dataSet,cost, 10);

if( abs(pf - .05) > .05)
    disp('error #3, prtScoreMinCostPf wrong score')
    result = false;
end

if( abs(pd - .965) > .05)
    disp('error #3, prtScoreMinCostPd wrong score')
    result = false;
end

%% Error checks
error = true;

% try an unlabeld dataSet
dataSet = prtDataSetClass;
dataSet = dataSet.setX(rand(2,2));
classifier = prtClassDlrt;

try
    score = prtEvalMinCost(classifier,dataSet, cost);
    error = false;
    disp('Error #4, unlabeled data set')
catch
    % no-op
end
    

% try wrong order input args

try
     pf = prtEvalPdAtPf(dataSet,classifier, cost); 
     error = false;
     disp('Error #5, input arg check')
catch
    % no0op
end
result = result & error;
