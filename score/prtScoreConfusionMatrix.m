function varargout = prtScoreConfusionMatrix(guess,truth,nClasses,labelsIn)
%[confMat,occurances,labels] = prtScoreConfusionMatrix(guess,truth,nClasses)
%
%   guess and truth should be either n x 1 doubles, or dataSets with proper
%   observations and targets

[guess,truth,labels] = prtUtilScoreParseFirstTwoInputs(guess,truth);
if nargin > 3
    labels = labelsIn;
end

guess = guess(:);
if nargin == 2
    nClasses = length(unique(cat(1,truth(:),guess(:))));
end

if length(truth) ~= length(guess)
    error('Truth and response inputs must be the same length')
end

confusionMat = zeros(nClasses);
occurances = zeros(nClasses);
classes = sort(unique(cat(1,truth(:),guess(:))));

for iTruthNum = 1:length(classes)
    iTruth = classes(iTruthNum);
    iTruthLocs = truth == iTruth;
    for jRespNum = 1:length(classes)
        jResp = classes(jRespNum);
        confusionMat(iTruthNum,jRespNum) = sum(guess(iTruthLocs) == jResp);
    end
    occurances(iTruthNum,:) = repmat(sum(iTruthLocs),nClasses,1);
end

varargout = {};
if nargout 
    varargout = {confusionMat, occurances, labels};
else
    prtUtilPlotConfusionMatrix(confusionMat./occurances,labels);
end