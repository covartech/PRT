function D = prtDistanceLNorm(dataSet1,dataSet2,Lnorm)
% prtDistanceLNorm   L Norm distance function.
%   
%   DIST = prtDistanceCityBlock(DS1,DS2) calculates the LNorm distance
%   from all the observations in datasets DS1 to DS2, and ouputs a distance
%   matrix of size DS1.nObservations x DS2.nObservations. DS1 and DS2
%   should have the same number of features. DS1 and DS2 should be
%   prtDataSet objects.
%   
%   For more information, see:
%   
%   http://en.wikipedia.org/wiki/Norm_(mathematics)#p-norm
%
% Example:
%
%   % Create 2 data sets
%   dsx = prtDataSetStandard('Observations', [0 0; 1 1]);
%   dsy = prtDataSetStandard('Observations', [1 0;2 2; 3 3]);
%   % Compute distance
%   distance = prtDistanceLnorm(dsx,dsy)
%
% See also: prtDistanceCityBlock, prtDistanceChebychev
% prtDistanceMahalanobis, prtDistanceSquare, prtDistanceEuclidean

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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A portion of IPDM from MATLAB Central is used in this function see
% prtExternal.IPDM.ipdm(). The license information from that file is below.
%
% Copyright (c) 2009, John D'Errico
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);

% Used to handle memory efficiency paths see IPDM
chunkSize = 2^25;

[nSamples1, nDim1] = size(data1);
[nSamples2, nDim2] = size(data2);

if nDim1 ~= nDim2
    error('Dimensionality of data1 and data2 must be equal')
end

if (nDim1>1) && ((nSamples1*nSamples2*nDim1)<=chunkSize)
    switch Lnorm
        case 1
            D = sum(abs(bsxfun(@minus,reshape(data1,[nSamples1,1,nDim1]),reshape(data2,[1,nSamples2,nDim1]))),3);
        case inf
            D = max(abs(bsxfun(@minus,reshape(data1,[nSamples1,1,nDim1]),reshape(data2,[1,nSamples2,nDim1]))),[],3);
        case 0
            D = min(abs(bsxfun(@minus,reshape(data1,[nSamples1,1,nDim1]),reshape(data2,[1,nSamples2,nDim1]))),[],3);
            
            % This code has overflow problems for large data1 and data2
            %         case 2
            %             %un-rolled((x-y)^2)) - sqrt below; this takes less time than
            %             %the generic code below for the most common L-norm (2)
            %
            %             %D = repmat(sum((data1.^2), 2), [1 nSamples2]) + repmat(sum((data2.^2),2), [1 nSamples1]).' - 2*data1*(data2.');
            %
            %             %             %Handle overflow issues for large data2
            %             %             muData2 = prtUtilNanMean(data2);
            %             %             data2 = bsxfun(@minus,data2,muData2);
            %             %             data1 = bsxfun(@minus,data1,muData2);
            %
            %             D = bsxfun(@minus,bsxfun(@plus,sum((data1.^2), 2),sum((data2.^2),2).'),2*data1*(data2.'));
        otherwise
            D = sum(bsxfun(@minus,reshape(data1,[nSamples1,1,nDim1]),reshape(data2,[1,nSamples2,nDim1])).^Lnorm,3);
    end
else
    % too big, so that the ChunkSize will have been exceeded, or just 1-d
    if isfinite(Lnorm) && Lnorm ~= 1
        D = bsxfun(@minus,data1(:,1),data2(:,1)').^Lnorm;
    else
        D = abs(bsxfun(@minus,data1(:,1),data2(:,1)'));
    end
    for i=2:nDim1
        switch Lnorm
            case 1
                D = D + abs(bsxfun(@minus,data1(:,i),data2(:,i)'));
            case inf
                D = max(D,abs(bsxfun(@minus,data1(:,i),data2(:,i)')));
            case 0
                D = min(D,abs(bsxfun(@minus,data1(:,i),data2(:,i)')));
            otherwise
                D = D + bsxfun(@minus,data1(:,i),data2(:,i)').^Lnorm;
        end
    end
end

if isfinite(Lnorm) && Lnorm ~= 1
    if Lnorm == 2
        D = sqrt(D);
        if isreal(data1) && isreal(data2)
            D = real(D);
        end
    else
        D = D.^(1./Lnorm);
    end
end

