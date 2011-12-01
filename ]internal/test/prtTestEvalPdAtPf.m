function result = prtTestEvalPdAtPf
% This function tests prtEvalPdAtPf
result = true;
% Basic operation
try
    dataSet = prtDataGenSpiral;
    classifier = prtClassDlrt;
    score = prtEvalPdAtPf(classifier,dataSet,.9);
catch
    disp('error #1, prtEvalPdAtPf failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99)< .01) 
    disp('error #2, prtEvalPdAtPf wrong score')
    result = false;
end


% Basic operation, kfolds
try
    dataSet = prtDataGenSpiral;
    classifier = prtClassDlrt;
    score = prtEvalPdAtPf(classifier,dataSet,.9 ,10);
catch
    disp('error #2, prtScorePdAtPfKfolds failed basic operation')
    result = false;
end

% check score
% Should be around .99 for the above run
if( abs(score - .99) < .01) 
    disp('error #3, prtScorePdAtPfKfolds wrong score')
    result = false;
end

%% Error checks
error = true;

% try an unlabeld dataSet
dataSet = prtDataSetClass;
dataSet = dataSet.setX(rand(2,2));
classifier = prtClassDlrt;

try
    score = prtEvalPdAtPf(classifier,dataSet,.9);
    error = false;
    disp('Error #4, unlabeled data set')
catch
    % no-op
    prtUtilProgressBar.forceClose();
end
    


result = result & error;
