function dataOut=prtUtilSpectralOutOfSampleExtension(dataOld,dataNew,eigVectors,eigValues,sigma)

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


%   dataOut=prtUtilSpectralOutOfSampleExtension(dataOld,dataNew,eigVectors,eigValues,sigma)
%   Performs an out of sample spectral dimensionality reduction.
%
%   Parameters:
%
%   dataOld - Features of in-sample data
% 
%   dataNew - Features of out of sample data
% 
%   eigVectors - Spectral features of in-sample data
% 
%   eigValues - eigen values corresponding to eigen vectors of in-sample data
% 
%   sigma - sigma used for radial basis function (RBF)
%
%       
%       Example usage:
%       ds=rt(prtPreProcZmuv,prtDataGenMoon);
%       nEigs=2;
%       sigma=.2;
%     
%       imagesc(ds)                          %Plot Moon data in feature space
%       title('prtDataGenMoon in Feature Space') 
%      
%       nPicked=30;
%       picked=randi(size(ds.X,1),[nPicked,1]);
%       
%       dsNew=ds.retainObservations(picked);
%       [eigValues, eigVectors] = prtUtilSpectralDimensionalityReduction(ds.X, nEigs,'sigma',sigma);      %transform Data to Spectral Space
%       dsNew.X=prtUtilSpectralOutOfSampleExtension(ds.X,dsNew.X,eigVectors,eigValues,sigma);             %transform out of sample data to spectral space
%       
% 
%       figure;
%       imagesc(dsNew)                      %Plot Moon data in spectral space
%       title('prtDataGenMoon out of sample in Spectral Space')


%Reference: Bengio, Y., Paiement, J. F., Vincent, P., Delalleau, O., Le Roux, N., & Ouimet, M. (2004).
%           Out-of-sample extensions for lle, isomap, mds, eigenmaps, and spectral clustering.
%           Advances in neural information processing systems, 16, 177-184.
            
            n=size(dataOld,1);
            k=prtUtilRbfDist(dataNew,dataOld,'sigma',sigma);
            kNorm1=sqrt(mean(prtUtilRbfDist(dataNew,dataOld,'sigma',sigma),2));
            kNorm2=sqrt(mean(prtUtilRbfDist(dataOld,dataOld,'sigma',sigma),2));
            
            
            
            normKern = k./(bsxfun(@times,kNorm1,kNorm2'));
            
            normKernTransformed=repmat(normKern,[1,1,length(eigValues)]);
            eigTransformed=permute(repmat(eigVectors,[1,1,size(dataNew,1)]),[3,1,2]);
            
            sumOut=squeeze(sum(normKernTransformed.*eigTransformed,2));
            
            dataOut=bsxfun(@rdivide,sumOut,(n*eigValues)');

end
