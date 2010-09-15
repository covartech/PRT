function X = prtRvUtilMvnDraw(mu,Sigma,N)

% At somepoint make this not call the stats toolbox

X = mvnrnd(mu,Sigma,N);