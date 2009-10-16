function [ClassifierResults,Etc] = prtClassRunKnn(PrtClassKnn,PrtDataSet)
% [ClassifierResults,Etc] = prtClassRunKnn(PrtClassKnn,PrtDataSet)

x = getObservations(PrtDataSet);
n = PrtDataSet.nObservations;
k = PrtClassKnn.PrtOptions.k;

nClasses = PrtClassKnn.PrtDataSet.nClasses;
uClasses = PrtClassKnn.PrtDataSet.uniqueClasses;
labels = getLabels(PrtClassKnn.PrtDataSet);
y = zeros(n,nClasses);

xTrain = getObservations(PrtClassKnn.PrtDataSet);
memBlock = 1000;

if n > memBlock
    for start = 1:memBlock:n
        indices = start:min(start+memBlock-1,n);
        
        distanceMat = feval(PrtClassKnn.PrtOptions.distanceFunction,xTrain,x(indices,:));
        
        [D,I] = sort(distanceMat,1,'ascend');
        I = I(1:k,:);
        L = labels(I)';
        
        for class = 1:nClasses
            y(indices,class) = sum(L == uClasses(class),2);
        end
    end
else
    distanceMat = feval(PrtClassKnn.PrtOptions.distanceFunction,xTrain,x);
    
    [D,I] = sort(distanceMat,1,'ascend');
    I = I(1:k,:);
    L = labels(I)';
    
    for class = 1:nClasses
        y(:,class) = sum(L == uClasses(class),2);
    end
end

[Etc.nVotes,Etc.MapGuessInd] = max(y,[],2);
Etc.MapGuess = uClasses(PrtResultsKnn.MapGuessInd);
ClassifierResults = prtDataSet(y);
