function [projectionMat, globalMean] = prtUtilLinearDiscriminantAnalysis(PrtDataSetLabeled,nComponents)
% xxx Need Help xxx







% Linear discriminant analysis, m-ary capable
X = PrtDataSetLabeled.getObservations;
globalMean = mean(X,1);

Y = PrtDataSetLabeled.getTargets;
uY = PrtDataSetLabeled.uniqueClasses;

%Sw = X'*X - globalMean'*globalMean*size(X,1); % Within-Class Scatter

% Calculate global between-class scatter
Sb = zeros(size(X,2));
Sw = zeros(size(X,2));
for i = 1:length(uY)
    nI = length(find(Y == uY(i)));
    currX = X(Y == uY(i),:);
    currMean = mean(currX);
    
    Sw = Sw + currX'*currX - currMean'*currMean*size(X,1);
    Sb = Sb + nI*(currMean - globalMean)'*(currMean - globalMean);  % Single-class, between-class scatter
end

% Find projection matrix via eigenvalue method
% B = Sw^(-1)*Sb;  %NIPS, 2004, Two-Dimensional Linear Discriminant Analysis
% eigOpts.issym = 1;
% eigOpts.isreal = 1;
% eigOpts.disp = 0;
% [projectionMat,e] = eigs(B,nComponents,'LM',eigOpts);

% Code suggested by rittersport3, 2011.09.14, this is cleaner, and avoids
% the Sw^-1 issue above
St = Sw + Sb;
[V, D] = eig(St, Sw);
[notUsed, sortedIndices] = sort(diag(D));
projectionMat = V(:, sortedIndices(1:nComponents));



