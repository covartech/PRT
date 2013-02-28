function [projectionMat, globalMean] = prtUtilLinearDiscriminantAnalysis(PrtDataSetLabeled,nComponents)
% xxx Need Help xxx

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



