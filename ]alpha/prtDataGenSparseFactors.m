function [DataSet,A,S] = prtDataGenSparseFactors(dimensionality,nSamples,nFactors,nFeatures)
%   prtDataGenSparseFactors Generate data with sparse underlying factors
%
%[DataSet,A,S] = prtDataGenSparseFactors(dimensionality = 1000,nSamples = 100,nFactors = 3,nFeatures = 5) 
%   generates unlabeled data X of size nSamples x nFeatures, where each 
%   column of X is generated from a linear combination of the nFactors 
%   columns of A.  A constitutes the factor loadings, and S is the factor 
%   scores.  i.e. 
%       X = A*S + E
%   where E is normal white noise with unit standard deviation. S is also 
%   drawn N(0,1).
%
%   Each of the nFactors columns of A has nFeatures elements which are
%   non-zero.  The magnitude of these elements are drawn N(0,5).
%
%   Output Y is always [].
%
%   %Example usage:
%       [X,Y,A,S] = prtDataGenSparseFactors(1000,150,3);
%       subplot(2,1,1); plot(A); title('Loadings A');
%       subplot(2,1,2); plot(X'); title('Data X');


Y = [];
if nargin < 1
    dimensionality = 1000;
end
if nargin < 2
    nSamples = 100;
    nFactors = 3;
end
if nargin < 3
    nFeatures = 5;
end
A = zeros(dimensionality,nFactors);

for fact = 1:nFactors
    importantFeatures = ceil(rand(1,nFeatures)*dimensionality);
    A(importantFeatures,fact) = randn(nFeatures,1) * 5;
end
S = randn(nFactors,nSamples);

X = A*S + normrnd(0,ones(dimensionality,nSamples));
X = X';

DataSet = prtDataSetClass(X);
