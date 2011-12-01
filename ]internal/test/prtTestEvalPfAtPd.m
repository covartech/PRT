function result = prtTestEvalPfAtPd
% This function tests prtEvalPfAtPd
result = true;
% Basic operation
try
    dataSet = prtDataGenSpiral;
    classifier = prtClassDlrt;
    score = prtEvalPfAtPd(classifier,dataSet,.9);
catch
    disp('error #1, prtEvalPfAtPd failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99)< .01) 
    disp('error #2, prtEvalPfAtPd wrong score')
    result = false;
end


% Basic operation, kfolds
try
    dataSet = prtDataGenSpiral;
    classifier = prtClassDlrt;
    score = prtEvalPfAtPd(classifier,dataSet,.9 ,10);
catch
    disp('error #2, prtScorePfAtPdKfolds failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99) < .01) 
    disp('error #3, prtScorePfAtPdKfolds wrong score')
    result = false;
end

%% Error checks
error = true;

% try an unlabeld dataSet
dataSet = prtDataSetClass;
dataSet = dataSet.setX(rand(2,2));
classifier = prtClassDlrt;

try
    score = prtEvalPfAtPd(classifier,dataSet,.9);
    error = false;
    disp('Error #4, unlabeled data set')
catch
    % no-op
    prtUtilProgressBar.forceClose();
end
    

% try wrong order input args

try
     pf = prtEvalPdAtPf(dataSet,classifier,.01); 
     error = false;
     disp('Error #5, input arg check')
catch
    % no0op
    prtUtilProgressBar.forceClose();
end
result = result & error;
