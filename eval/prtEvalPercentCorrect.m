function percentCorrect = prtEvalPercentCorrect(classifier,dataSet,nFolds)
% PERCENTCORRECT    Calculate percent correct of two classifications guess, truth
% 
% Syntax: pC = percentCorrect(guess,truth,alpha = 0.05)
%
% Inputs:
%   guess - Guess classification
%   truth - True classification
%   alpha - Confidence region (default 0.05)
%
% Outputs:
%   pC - Percent correct
%   pCConf - Confidence Bounds on percent correct
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Copyright 2010, New Folder Consulting, L.L.C.

assert(nargin >= 2,'prt:prtEvalPercentCorrect:BadInputs','prtEvalPercentCorrect requires two input arguments');
assert(isa(classifier,'prtClass') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalPercentCorrect:BadInputs','prtEvalPercentCorrect inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(classifier),class(dataSet));

if nargin < 3 || isempty(nFolds)
    nFolds = 1;
end
results = classifier.kfolds(dataSet,nFolds);

if results.nFeatures == 1 %binary classifier
    [pf,pd] = prtUtilScoreRoc(results.getObservations,dataSet.getTargets);
    pe = prtUtilPfPd2Pe(pf,pd);
    minPe = min(pe);
    percentCorrect = 1-minPe;
else
    [~,guess] = max(results.getObservations,[],2);
    confusionMatrix = prtScoreConfusionMatrix(guess,dataSet.getTargets);
    percentCorrect = prtUtilConfusion2PercentCorrect(confusionMatrix);
end
  