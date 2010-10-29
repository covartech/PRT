function tree = recursiveCapTree(Obj,tree,x,y,index)

uniqueY = [0;1];
if index == 1
    if ~isequal(unique(y(:)),uniqueY)
        error('prt:recursiveCapTree','Requires input y to only have classes 0 and 1');
    end
end

nFeatures = size(x,2);

if index > tree.maxReservedLen
    tree.W = memorySaverAppendNulls(tree.W,Obj.Memory.nAppend,Obj.nFeatures);
    tree.threshold = memorySaverAppendNulls(tree.threshold,Obj.Memory.nAppend,1);
    tree.featureIndices = memorySaverAppendNulls(tree.featureIndices,Obj.Memory.nAppend,Obj.nFeatures);
    tree.treeIndices = memorySaverAppendNulls(tree.treeIndices,Obj.Memory.nAppend,1);
    tree.terminalVote = memorySaverAppendNulls(tree.terminalVote,Obj.Memory.nAppend,1);
    tree.maxReservedLen = tree.maxReservedLen + Obj.Memory.nAppend;
end

%Base cases; if there is only one class left, we must return
% if length(unique(y)) == 1;
if all(y == 1) || all(y == 0)
    tree.W(:,index) = inf;  %place holder for completed processing
    tree.treeIndices(index) = tree.father;
    tree.terminalVote(index) = unique(y);
    return;
end

%Choose random subspace projection:
if Obj.featureSelectWithReplacement  %allow redundant features
    tree.featureIndices(:,index) = ceil(rand([1,Obj.nFeatures])*nFeatures)';
    tree.treeIndices(index) = tree.father;
else
    locInd = randperm(nFeatures)'; %do NOT allow redundant features
    tree.featureIndices(:,index) = locInd(1:Obj.nFeatures);
    tree.treeIndices(index) = tree.father;
end

if Obj.bootStrapDataAtNodes
    xTrain = zeros(size(x));
    yTrain = zeros(size(y));
    start = 1;
    for j = 1:length(uniqueY)
        currX = x(y == uniqueY(j),:);
        nj = sum(y == uniqueY(j));
        c = ceil(rand(nj,1)*nj);
        currX = currX(c,:);
        
        if j == 1
            start = 1;
        else
            start = start + nj;
        end
        stop = start + nj - 1;
        xTrain(start:stop,:) = currX;
        yTrain(start:stop,1) = uniqueY(j);
    end
else
    xTrain = x;
    yTrain = y;
end
xTrain = xTrain(:,tree.featureIndices(:,index));

% Generate a CAP classifier (internal code, don't use prtClassCap for
% speed issues)
[w,thresholdValue,yOut] = recursiveCapTreeGenerateCap(xTrain,yTrain,uniqueY);
tree.W(:,index) = w(:);
tree.threshold(:,index) = thresholdValue;
%yOut = double(yOut >= tree.threshold(:,index));
yOut = double(yOut >= tree.threshold(:,index));
ind0 = find(yOut == 0);
ind1 = find(yOut == 1);

if isempty(ind0) || isempty(ind1)
    error('Classifier output unique labels');
end

tree.father = index;
xLeft = x(ind0,:);
yLeft = y(ind0,:);
tree = recursiveCapTree(Obj,tree,xLeft,yLeft,index + 1);
tree.father = index;

xRight = x(ind1,:);
yRight = y(ind1,:);

maxLen = length(find(~isnan(tree.W(1,:))));
tree = recursiveCapTree(Obj,tree,xRight,yRight,maxLen + 1);

    function M = memorySaverAppendNulls(M,nAppend,nFeats)
        M = cat(2,M,nan(nFeats,nAppend));
    end
end


function [w,thresholdValue,yOut] = recursiveCapTreeGenerateCap(x,y,uniqueY)
%[w,thresholdValue,yOut] = recursiveCapGenerateCap(x,y,uniqueY,nRocEvals)
% Internal function to quicly generate a CAP classifier without prt
% overhead

mean0 = mean(x(y == uniqueY(1),:),1);
mean1 = mean(x(y == uniqueY(2),:),1);
w = mean1 - mean0;
w = w./norm(w);
yOut = (w*x')';

% figure out the threshold:
[pf,pd,thresh] = prtScoreRoc(yOut,y);
pE = prtUtilPfPd2Pe(pf,pd);
[minPe,I] = min(pE);
if numel(I) > 1
    I = unique(I);
end
thresholdValue = thresh(I);
if minPe >= 0.5
    w = -w;
    yOut = (w*x')';
    % % figure out the threshold:
    [pf,pd,thresh] = prtScoreRoc(yOut,y);
    pE = prtUtilPfPd2Pe(pf,pd);
    [minPe,I] = min(pE);
    if numel(I) > 1
        I = unique(I);
    end
    thresholdValue = thresh(I);

    if minPe >= 0.5
        warning('prt:recursiveCapTree:badTraining','Min PE from CAP.trainAction is >= 0.5');
    end
end
end