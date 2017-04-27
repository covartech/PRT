function [permMat,yTruth,xTruth] = prtDataGenBiclusters

avgBlockSize = 20;
blockStdv = 3;
minBlockSize = 5;
nBiclusters = 3;

%% first make an approximate block matrix
blockSize = max(round(randn(nBiclusters,2)*blockStdv+avgBlockSize),minBlockSize);
bigMat = nan(sum(blockSize,1));
starts = [[0,0];cumsum(blockSize,1)];
for iBicluster = 1:nBiclusters
    rowBase = rand(blockSize(iBicluster,1),1)*20;
    colBase = rand(1,blockSize(iBicluster,2))*20;
    block = bsxfun(@plus,rowBase,colBase) + randn(blockSize(iBicluster,:));
    bigMat(starts(iBicluster,1)+(1:blockSize(iBicluster,1)),...
        starts(iBicluster,2)+(1:blockSize(iBicluster,2))) = block;
end
bigMat(isnan(bigMat)) = rand(sum(isnan(bigMat(:))),1)*(max(bigMat(:))-min(bigMat(:)))+min(bigMat(:));
sz = sum(blockSize);

%% then permute the rows and columns
yinds = cell2mat(arrayfun(@(a,b){ones(1,a)*b},blockSize(:,1)',1:nBiclusters));
xinds = cell2mat(arrayfun(@(a,b){ones(1,a)*b},blockSize(:,2)',1:nBiclusters));
yperm = randperm(sz(1));
xperm = randperm(sz(2));
xTruth = xinds(xperm);
yTruth = yinds(yperm);
permMat = bigMat(yperm,xperm);