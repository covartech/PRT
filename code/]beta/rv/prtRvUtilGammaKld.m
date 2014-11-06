function KLD = prtRvUtilGammaKld(bQ,cQ,bP,cP)
% GAMMAKLD  Kulback Liebler Divergence between two gamma densities
%       KLD(Q||P)
%   Here are gamma distributions are parameterized by b the shape parameter
%   and c the inverse scale parameter. The mean is then given by b/c and
%   the variances is b/(c^2)
%
%   KL-Divergence of Normal, Gamma, Dirichlet and Wishart densities
%      Penny, 2001
%
% Syntax: KLD = prtRvUtilGammaKld(bQ,cQ,bP,cP)
%
% Inputs:
%   bQ - shape parameter of distribution Q
%   cQ - inverse scale parameter of distribution Q
%   bP - shape parameter of distribution P
%   cP - inverse scale parameter of distribution P
%
% Outputs:
%   KLD - The KLD for the gamma distributions

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


KLD = gammaln(bP)-gammaln(bQ) + bP*log(cQ) - bP*log(cP) + (bQ-bP)*psi(bQ) + bQ*(cP-cQ)/cQ;
