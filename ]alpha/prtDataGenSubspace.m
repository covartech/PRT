function DataSet = prtDataGenSubspace(subspaceH1,subspaceH0,N)
%[X,Y] = prtDataGenSubspace(subspaceH1,subspaceH0,N)
%   Generate X data spanned by the subspace defined by the *columns* of
%   subspaceH1 and subspaceH0.  Each row of X is defined via
%       X(i,:) = subspace * \theta
%   Where each element of \theta is uniformly distributed.


if nargin < 3
    N = 400;
end

subspaceH1 = subspaceH1';
subspaceH0 = subspaceH0';

X1 = zeros(N,size(subspaceH1,2));
X0 = zeros(N,size(subspaceH0,2));
for i = 1:N;
    X1(i,:) = subspaceH1*rand(size(subspaceH1,1),1);
    X0(i,:) = subspaceH0*rand(size(subspaceH0,1),1);
end
X = cat(1,X0,X1);
Y = prtUtilY(N,N);

DataSet = prtDataSetClass(X,Y,'dataSetName','prtDataGenSubspace');