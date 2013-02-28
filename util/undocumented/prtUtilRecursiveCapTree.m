function tree = prtUtilRecursiveCapTree(Obj,tree,x,y,index)
%tree = recursiveCapTree(Obj,tree,x,y,index)

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


nFeatures = size(x,2);

uniqueY = find(sum(y,1)>0);

if index > tree.maxReservedLen
    tree.W = memorySaverAppendNulls(tree.W,Obj.Memory.nAppend,Obj.nFeatures);
    tree.threshold = memorySaverAppendNulls(tree.threshold,Obj.Memory.nAppend,1);
    tree.featureIndices = memorySaverAppendNulls(tree.featureIndices,Obj.Memory.nAppend,Obj.nFeatures);
    tree.treeIndices = memorySaverAppendNulls(tree.treeIndices,Obj.Memory.nAppend,1);
    tree.terminalVote = memorySaverAppendNulls(tree.terminalVote,Obj.Memory.nAppend,1);
    tree.maxReservedLen = tree.maxReservedLen + Obj.Memory.nAppend;
end

%Base cases; if there is only one class left, we must return

if length(uniqueY) == 1
    tree.W(:,index) = inf;  %place holder for completed processing
    tree.treeIndices(index) = tree.father;
    tree.terminalVote(index) = uniqueY;
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

xTrain = x(:,tree.featureIndices(:,index));

% Generate a CAP classifier (internal code, don't use prtClassCap for
% speed issues)
[w,thresholdValue,yOut] = recursiveCapTreeGenerateCap(xTrain,y);

if any(~isfinite(w)) || ~isfinite(thresholdValue)
    exitNow = true;
else
    
    yOut = yOut >= thresholdValue;
    
    % True if only one class in the output
    exitNow = ~any(yOut) || all(yOut);
end

if exitNow
    % If we get here we have the same mean under both class labels
    % or have infs in the data
    % So we exit
    
    % Tree params on an exit
    tree.W(:,index) = inf;  %place holder for completed processing
    tree.threshold(:,index) = nan;
    tree.treeIndices(index) = tree.father;
    
    % Figure out the dominant class
    classCounts = sum(y,1);
    [maxClassCounts, maxClassInd] = max(classCounts);
    isGoodClass = classCounts == maxClassCounts;
    
    nGoodInds = sum(isGoodClass);
    
    % If nGoodInds > 1 We have ties and need to decide randomly
    if nGoodInds > 1
        goodInds = find(isGoodClass);
        maxClassInd = goodInds(ceil(rand*nGoodInds));
    end
    
    %tree.terminalVote(index) = uniqueY(maxClassInd);
    tree.terminalVote(index) = maxClassInd;
    return
end

% Continue on...
% Store node info into tree

tree.W(:,index) = w(:);
tree.threshold(:,index) = thresholdValue;
tree.father = index;

% Split the data 

% Left
xLeft = x(~yOut,:);
yLeft = y(~yOut,:);
tree = prtUtilRecursiveCapTree(Obj,tree,xLeft,yLeft,index + 1);
tree.father = index;

% Right
xRight = x(yOut,:);

yRight = y(yOut,:);
maxLen = length(find(~isnan(tree.W(1,:))));
tree = prtUtilRecursiveCapTree(Obj,tree,xRight,yRight,maxLen + 1);

    function M = memorySaverAppendNulls(M,nAppend,nFeats)
        M = cat(2,M,nan(nFeats,nAppend));
    end
end


function [w,thresholdValue,yOut] = recursiveCapTreeGenerateCap(x,y)
%[w,thresholdValue,yOut] = recursiveCapGenerateCap(x,y,uniqueY,nRocEvals)
% Internal function to quicly generate a CAP classifier without prt
% overhead

if size(y,2) > 2
    classCounts = sum(y,1);
    [sortedClassCounts, sortedClassInds] = sort(classCounts,'descend'); %#ok<ASGLU>
else
    sortedClassInds = [1 2];
end
% Ties go to the lower classInds

mean0 = mean(x(y(:,sortedClassInds(1)),:),1);
mean1 = mean(x(y(:,sortedClassInds(2)),:),1);
w = mean1 - mean0;

w = w./norm(w);

if isnan(w)
    w = nan(size(w));
    thresholdValue = nan;
    yOut = nan;
    return
end

selectedClasses = y(:,sortedClassInds(1)) | y(:,sortedClassInds(2));

yOut = (w*x')';
yTest = y(selectedClasses,sortedClassInds(2));

% figure out the threshold: (1)
[pf,pd,thresh] = prtScoreRoc(yOut(selectedClasses,:),yTest,'uniqueLabels',[0 1]);

% figure out the threshold: (2)
% uY = unique(yTest);
% binLabels = yTest ~= uY(1);
% [~,~,pf,pd,thresh] = prtUtilMinPeThreshold(yOut(selectedClasses,:),binLabels);

pE = prtUtilPfPd2Pe(pf,pd);
[minPe,I] = min(pE);
if numel(I) > 1
    I = unique(I);
end

if I < length(thresh)
    %for categorical variables, the threshold should live between the
    %samples we've seen; this is true for continuous variables too.  Makes
    %a big difference when multiple values take the same value
    thresholdValue = mean([thresh(I),thresh(I+1)]);
else
    thresholdValue = thresh(I);
end

if minPe >= 0.5
    w = -w;
    yOut = -yOut;
    % % figure out the threshold:
    [pf,pd,thresh] = prtScoreRoc(yOut(selectedClasses,:),yTest,'uniqueLabels',[0 1]);
    pE = prtUtilPfPd2Pe(pf,pd);
    [minPe,I] = min(pE); %#ok<ASGLU>
    if numel(I) > 1
        I = unique(I);
    end
    if I < length(thresh)
        %for categorical variables, the threshold should live between the
        %samples we've seen; this is true for continuous variables too.  Makes
        %a big difference when multiple values take the same value
        thresholdValue = mean([thresh(I),thresh(I+1)]);
    else
        thresholdValue = thresh(I);
    end

end
end
