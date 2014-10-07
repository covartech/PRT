function KLD = prtRvUtilWishartKld(q,Q,p,P)
% WISHARTKLD  Kulback Liebler Divergence between two Wishart densities
%       KLD(Q||P)
%
%   KL-Divergence of Normal, Gamma, Dirichlet and Wishart densities
%      Penny, 2001
%
% Syntax: KLD = wishartKLD(aQ,BQ,aP,BP)
%
% Inputs:
%   aQ - The strength parameter of the Q distribution
%   BQ - The mean parameter of the Q distribution
%   aP - The strength parameter of the P distribution
%   BP - The mean parameter of the P distribution
%
% Outputs:
%   KLD - The KLD for the Wishart distributions

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
d = size(Q,1);

dims = 1:d;

KLD = p/2*(prtUtilLogDet(Q) - prtUtilLogDet(P)) + q/2*(trace(inv(Q)*P) - d) + prtRvUtilGeneralizedGammaLn(p/2,d) - prtRvUtilGeneralizedGammaLn(q/2,d) + (q/2 - p/2)*sum(psi((q+1-dims)/2));

if KLD < 0
    KLD = 0; % This only happens in the range of 0;
end
