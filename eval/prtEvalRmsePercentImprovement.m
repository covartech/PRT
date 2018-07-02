function rmseImprovement = prtEvalRmsePercentImprovement(regressor,dataSet,nFolds, varargin)
% prtEvalRmsePercentImprovement Calculate the percent RMSE improvement from
% training the regressor on the data set (vs. using the mean of the
% dataSet.targets)
% 
% rmseImprovement = prtEvalRmsePercentImprovement(regressor,dataSet,nFolds)


assert(nargin >= 2,'prt:prtEvalRmse:BadInputs','prtEvalPercentCorrect requires two input arguments');
assert(isa(regressor,'prtAction') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalMse:BadInputs','prtEvalMse inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(regressor),class(dataSet));

if nargin < 3 || isempty(nFolds)
    nFolds = 1;
end
results = prtUtilEvalParseAndRun(regressor,dataSet,nFolds, varargin{:});

rmseImprovement = prtScoreRmsePercentImprovement( results.getX, dataSet.getY);



