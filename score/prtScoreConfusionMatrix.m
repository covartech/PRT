function varargout = prtScoreConfusionMatrix(guess,truth,nClass)
%[confMat,occurances,labels] = prtScoreConfusionMatrix(guess,truth,nClass)

disp('Note - input arguments in scoreconfusionmatrix have changed');

[guess,truth,labels] = prtUtilScoreParseFirstTwoInputs(guess,truth);
guess = guess(:);
if nargin == 2
    nClass = length(unique(cat(1,truth(:),guess(:))));
end

if length(truth) ~= length(guess)
    error('Truth and response inputs must be the same length')
end

confusionMat = zeros(nClass);
occurances = zeros(nClass);
classes = sort(unique(cat(1,truth(:),guess(:))));

for iTruthNum = 1:length(classes)
    iTruth = classes(iTruthNum);
    iTruthLocs = truth == iTruth;
    for jRespNum = 1:length(classes)
        jResp = classes(jRespNum);
        confusionMat(iTruthNum,jRespNum) = sum(guess(iTruthLocs) == jResp);
    end
    occurances(iTruthNum,:) = repmat(sum(iTruthLocs),nClass,1);
end

varargout = {};
if nargout 
    varargout = {confusionMat, occurances, labels};
else
    plotConfusionMatrix(confusionMat./occurances,labels);
end