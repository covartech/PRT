function [gramm,nBasis] = prtKernelRbfParamNeighbors(x1,x2,n,sigma)
%[gramm,nBasis] = prtKernelRbfParamNeighbors(x1,x2,n,c)

%distance to n'th nearest neighbor
dMat = prtDistanceEuclidean(x2,x2);
dMat = sort(dMat,2,'ascend');
d = dMat(:,n+1); %ignore self-distances

%scale parameter c
sigma = sqrt(d(:)'.^2)*sigma;
[gramm,nBasis] = prtKernelRbf(x1,x2,sigma);