function [gramm,nBasis] = prtKernelRbfParamNeighbors(x1,x2,n,c)
%[gramm,nBasis] = prtKernelRbfParamNeighbors(x1,x2,n,c)

%distance to n'th nearest neighbor
dMat = prtDistance(x2,x2);
dMat = sort(dMat,2,'ascend');
d = dMat(:,n+1); %ignore self-distances

%scale parameter c
c = sqrt(d(:)'.^2)*c;
[gramm,nBasis] = prtKernelRbf(x1,x2,c);