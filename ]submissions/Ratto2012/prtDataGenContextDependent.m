function [contextDataSet,classificationDataSet] = prtDataGenContextDependent

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


contextDataSet = prtDataGenBimodal(400);
kmeans = prtClusterKmeans('nClusters',4);
kmeans = train(kmeans,contextDataSet);

yOut = kmeans.run(contextDataSet);

labels = yOut.getObservations;
for i = 1:size(labels,2)
    currDataInd = find(yOut.getObservations(:,i));
    
    i1 = randn < 0;
    if i1 == 0
        i1 = -1;
    end
    
    mu1 = [1 1] * i1;
    mu0 = -mu1;
    
    rvH1 = prtRvMvn('mu',mu1,'sigma',eye(2));
    rvH0 = prtRvMvn('mu',mu0,'sigma',eye(2));
    nSamples1 = floor(length(currDataInd)/2);
    nSamples0 = ceil(length(currDataInd)/2);
    
    x(currDataInd,:) = cat(1,rvH0.draw(nSamples0),rvH1.draw(nSamples1));
    y(currDataInd,1) = prtUtilY(nSamples0,nSamples1);
end
classificationDataSet = prtDataSetClass(x,y);

end
