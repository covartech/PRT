function [eigValues, eigVectors] = prtUtilSpectralDimensionalityReduction(data, nEigVectors,varargin)

% Copyright (c) 2014 CoVar Applied Technologies
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


%   [eigValues, eigVectors] = prtUtilSpectralDimensionalityReduction(data, nEigVectors,param1,value1,...)
%   Perform a spectral dimensionality reduction on data using nEigVectors
%   to determine the number of eigenVectors to choose, and the sigma used
%   in the radial basis function (RBF)
%
%   [eigValues, eigVectors] = prtUtilSpectralDimensionalityReduction(data, nEigVectors,param1,value1,...)
%   Enables inputs of parameter/value pairs as described below:
%
%   Parameters:
%       
%   sigma - Variance of the Radial Basis Function (RBF)
%
%   Example usage:
%
%   ds=rt(prtPreProcZmuv,prtDataGenMoon);       %Generate Moon data
% 
%   imagesc(ds)                          %Plot Moon data in feature space
%   title('prtDataGenMoon in Feature Space') 
% 
%   [~,eigVectors]=prtUtilSpectralDimensionalityReduction(ds,2,'sigma',.2);   %Apply spectral dimensionality reduction to Moon Ddata
%   dsNew=prtDataSetClass(eigVectors,ds.Y);
%
%   figure;
%   imagesc(dsNew)                      %Plot Moon data in spectral space
%   title('prtDataGenMoon in Spectral Space')

p = inputParser;

p.addParamValue('sigma',.2)

p.parse(varargin{:});
inputStruct = p.Results;
sigma=inputStruct.sigma;


DataSet=prtDataSetClass(data);
Gram = rt(prtKernelRbf('sigma',sigma),DataSet);   %%Should make the distance metric a variable.. for now it's not
D=diag(sum(Gram.X,2));
L=D^(-1/2)*Gram.X*D^(-1/2);

try
    [X,eigValues]=eigs(L,nEigVectors);
catch  %#ok<CTCH>
    opts.tol = 1e-3;
    [X,eigValues]=eigs(L,nEigVectors,'lr', opts);
    
end

% Remove the means and normalize the variance
eigVectors=bsxfun(@rdivide,X,sqrt(sum(X.^2,2)));
eigValues=diag(eigValues);
end
