function percentCorrect = prtEvalPercentCorrect(classifier,dataSet,nFolds)
% PERCENTCORRECT    Calculate percent correct of a classification operation
% 
%   PERCENTCORRECT = prtEvalPercentCorrect(CLASSIFIER, DATASET) returns the percentage
%   of correctly classified elements of DATASET when classifier by
%   CLASSIFIER. DATASET must be a labeled, prtDataSetStandard
%   object. CLASSIFIER must be a prtClass object. 
%
%   PF = prtScorePercentCorrect(CLASSIFIER, DATASET, NFOLDS)  returns the
%   percentage of correctly classified elements of DATASET when classifier
%   by CLASSIFIER with K-fold cross-validation. DATASET must be a labeled,
%   prtDataSetStandard object. CLASSIFIER must be a prtClass object.
%   NFOLDS is the number of folds in the K-fold cross-validation.
%
%   Example:
%   dataSet = prtDataGenSpiral;
%   classifier = prtClassDlrt;
%   pc =  prtEvalPercentCorrect(classifier, dataSet)
%
%   See Also: prtEvalPdAtPf, prtEvalPfAtPd, prtEvalAuc,
%   prtEvalMinCost


% Copyright 2010, New Folder Consulting, L.L.C.

assert(nargin >= 2,'prt:prtEvalPercentCorrect:BadInputs','prtEvalPercentCorrect requires two input arguments');
assert(isa(classifier,'prtAction') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalPercentCorrect:BadInputs','prtEvalPercentCorrect inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(classifier),class(dataSet));

if nargin < 3 || isempty(nFolds)
    nFolds = 1;
end
results = classifier.kfolds(dataSet,nFolds);

%(note: can't check results.nFeatures here any more...)
if dataSet.nClasses == 2 %binary classifier 
    [pf,pd] = prtScoreRoc(results.getObservations,dataSet.getTargets);
    pe = prtUtilPfPd2Pe(pf,pd);
    minPe = min(pe);
    percentCorrect = 1-minPe;
else
    %Note, this is a hack; we need to fix this.
    if isa(classifier,'prtAlgorithm')
        guess = results.getObservations;
    else
        if classifier.includesDecision
            guess = results.getObservations;
        else
           %Naive MAP decision:
           % [twiddle,guess] = max(results.getObservations,[],2); %#ok<ASGLU>
           %Naive MAP decision:
           prtMap = prtDecisionMap;
           prtMap = train(prtMap,results);
           results = prtMap.run(results);
           guess = results.getObservations;
        end
    end
    percentCorrect = prtScorePercentCorrect(guess,dataSet.getTargets);
    %confusionMatrix = prtScoreConfusionMatrix(guess,dataSet.getTargets);
    %percentCorrect = prtUtilConfusion2PercentCorrect(confusionMatrix);
end
  