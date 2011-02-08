function DataSet = prtDataGenUnimodalWithNonFinite(N,mu0,mu1,sigma0,sigma1)
%prtDataGenUnimodalWithNonFinite   Generates unimodal example data with
%   non-finite (nan and inf) elements.  This is intended for internal
%   testing.

% Copyright 2011, New Folder Consulting, L.L.C.

if nargin == 0
    nSamples = 200;
else
    nSamples = N;
end
if nargin < 5
    mu0 = [-1 -1];
    sigma0 = eye(2);
    mu1 = [2 2];
    sigma1 = [1 .5; .5 1];
end
rv(1) = prtRvMvn('mu',mu0,'sigma',sigma0);
rv(2) = prtRvMvn('mu',mu1,'sigma',sigma1);

X = cat(1,draw(rv(1),nSamples),draw(rv(2),nSamples));
Y = prtUtilY(nSamples,nSamples);

DataSet = prtDataSetClass(X,Y,'name',mfilename);

dsNan = prtDataSetClass([nan nan; inf inf; nan inf; nan -inf;],[1;0;1;0]);
DataSet = DataSet.catObservations(dsNan);