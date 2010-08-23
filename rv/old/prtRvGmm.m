function GmmObj = prtRvGmm(nComponents,X)
% PRTRVGMM Gaussian Mixture Model
%
%   Syntax: GmmObj = prtRvGmm(nComponents,X)
%
%   This is an intermediary function for user ease. 
%   Maybe it should be a subclass of rv.mixture. Since there are no
%   method overloads other than the constructor. I decided to go with a
%   simple helper function. 

GmmObj = prtRvMixture(nComponents,prtRvMvn);

if nargin > 1
    GmmObj = mle(GmmObj,X);
end

end