function result = prtTestEvalPercentCorrect
% This function tests prtEvalPercentCorrect
result = true;
% Basic operation
try
    dataSet = prtDataGenSpiral;
    classifier = prtClassDlrt;
    score = prtEvalPercentCorrect(classifier,dataSet);
catch
    disp('error #1, prtEvalPercentCorrect failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99)> .01) 
    disp('error #2, prtEvalPercentCorrect wrong score')
    result = false;
end


% Basic operation, kfolds
try
    dataSet = prtDataGenSpiral;
    classifier = prtClassDlrt;
    score = prtEvalPercentCorrect(classifier,dataSet,10);
catch
    disp('error #2, prtScorePercentCorrectKfolds failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99) > .05) 
    disp('error #3, prtScorePercentCorrectKfolds wrong score')
    result = false;
end

%% Error checks
error = true;

% try an unlabeld dataSet
dataSet = prtDataSetClass;
dataSet = dataSet.setX(rand(2,2));
classifier = prtClassDlrt;

try
    score = prtEvalPercentCorrect(classifier,dataSet);
    error = false;
    disp('Error #4, unlabeled data set')
catch
    % no-op
    prtUtilProgressBar.forceClose();
end
    

% try wrong order input args

try
     pf = prtEvalPdAtPf(dataSet,classifier); 
     error = false;
     disp('Error #5, input arg check')
catch
    prtUtilProgressBar.forceClose();
    % no0op
end
result = result & error;
