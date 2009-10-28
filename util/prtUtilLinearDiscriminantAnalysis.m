function [projectionMat, globalMean] = prtUtilLinearDiscriminantAnalysis(PrtDataSetLabeled,nComponents)

% Linear discriminant analysis, m-ary capable
X = PrtDataSetLabeled.getObservations;
globalMean = mean(X,1);

Y = PrtDataSetLabeled.getTargets;
uY = PrtDataSetLabeled.uniqueClasses;

Sw = X'*X - globalMean'*globalMean*size(X,1); % Within-Class Scatter

% Calculate global between-class scatter
Sb = zeros(size(X,2));
for i = 1:length(uY)
    nI = length(find(Y == uY(i)));
    currX = X(Y == uY(i),:);
    currMean = mean(currX);
    
    Sb = Sb + nI*(currMean - globalMean)'*(currMean - globalMean);  % Single-class, between-class scatter
end

% Find projection matrix via eigenvalue method
B = Sw^(-1)*Sb;  %NIPS, 2004, Two-Dimensional Linear Discriminant Analysis
[projectionMat,e] = eig(B);
[val,ind] = sort(diag(e),'descend');
projectionMat = projectionMat(:,ind(1:nComponents));
projectionMat = real(projectionMat);


