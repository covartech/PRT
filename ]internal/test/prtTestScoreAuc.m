function result = prtTestScoreAuc
% This function tests prtEvalAuc and prtScoreAucKfolds
result = true;
% Basic operation
try
    dataSet = prtDataGenSpiral;
    classifier = prtClassDlrt;
    score = prtEvalAuc(classifier,dataSet);
catch
    disp('error #1, prtEvalAuc failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99) > .01) 
    disp('error #2, prtEvalAuc wrong score')
    result = false;
end


% Basic operation, kfolds
try
    dataSet = prtDataGenSpiral;
    classifier = prtClassDlrt;
    score = prtEvalAuc(classifier,dataSet,10);
catch
    disp('error #2, prtScoreAucKfolds failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99) > .01) 
    disp('error #3, prtScoreAucKfolds wrong score')
    result = false;
end

%% Error checks
error = true;

% try an unlabeld dataSet
dataSet = prtDataSetClass;
dataSet = dataSet.setX(rand(2,2));
classifier = prtClassDlrt;

try
    score = prtEvalAuc(classifier,dataSet);
    error = false;
    disp('Error #4, unlabeled data set')
catch
    % no-op
    prtUtilProgressBar.forceClose();
end
    

% try an unlabeld dataSet
dataSet = prtDataSetClass;
dataSet = dataSet.setX(rand(2,2));
classifier = prtClassDlrt;

try
    score = prtEvalAuc(classifier,dataSet,dataSet.nObservations);
    error = false;
    disp('Error #4a, unlabeled data set')
catch
    % Close waitbar
    prtUtilProgressBar.forceClose();
    % no-op
end

% check k-folds without enough input args
% try
%     dataSet = prtDataGenSpiral;
%     classifier = prtClassDlrt;
%     score = prtEvalAuc(classifier,dataSet,dataSet.nObservations);
%     error = false;
%     disp('prtScoreAucKfolds, not enough input args')
% catch
%     % no-op
% end

result = result & error;
