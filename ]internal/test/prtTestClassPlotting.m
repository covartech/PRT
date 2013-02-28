function result = prtTestClassPlotting

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


result = true;
try
    dsbinary = prtDataGenBimodal;
    dsmary = prtDataGenIris;
    dsmary = dsmary.retainFeatures(1:2);
    
    %% test binary plot classifier; no decision
    binaryclassifier = prtClassAdaBoost;
    binaryclassifier = binaryclassifier.train(dsbinary);
    binaryclassifier.plot; drawnow; pause(0.1);
    
    %% test binary plot classifier; with decision
    
    binaryclassifier = prtClassAdaBoost;
    binaryclassifier.internalDecider = prtDecisionBinaryMinPe;
    binaryclassifier = binaryclassifier.train(dsbinary);
    binaryclassifier.plot; drawnow; pause(0.1);
    
    %% m-ary classifier; no decision
    maryclassifier = prtClassKnn;
    maryclassifier = maryclassifier.train(dsmary);
    maryclassifier.plot; drawnow; pause(0.1);
    
    %% m-ary classifier; with decision
    
    close all;
    maryclassifier = prtClassKnn;
    maryclassifier.internalDecider = prtDecisionMap;
    maryclassifier = maryclassifier.train(dsmary);
    maryclassifier.plot; drawnow; pause(0.1);
    
    %% m-ary-binary classifier; no decision
    close all;
    marybinaryclassifier = prtClassBinaryToMaryOneVsAll('baseClassifier',prtClassLogisticDiscriminant);
    marybinaryclassifier = marybinaryclassifier.train(dsmary);
    marybinaryclassifier.plot; drawnow; pause(0.1);
    
    %% m-ary-binary classifier; with decision
    close all;
    marybinaryclassifier = prtClassBinaryToMaryOneVsAll('baseClassifier',prtClassLogisticDiscriminant);
    marybinaryclassifier.internalDecider = prtDecisionMap;
    marybinaryclassifier = marybinaryclassifier.train(dsmary);
    marybinaryclassifier.plot; drawnow; pause(0.1);
    
    %% clustering - m-ary data
    close all;
    clusterer = prtClusterKmeans;
    clusterer = clusterer.train(dsmary);
    clusterer.plot; drawnow; pause(0.1);
    
    %% clustering with decision
    close all;
    clusterer = prtClusterKmeans;
    clusterer.internalDecider = prtDecisionMap;
    clusterer = clusterer.train(dsmary);
    clusterer.plot; drawnow; pause(0.1);
    
    %% clustering - m-ary data
    close all;
    clusterer = prtClusterKmeans;
    clusterer.nClusters = 2;
    clusterer = clusterer.train(dsbinary);
    clusterer.plot; drawnow; pause(0.1);
    
    %% clustering with decision
    close all;
    clusterer = prtClusterKmeans;
    clusterer.nClusters = 2;
    clusterer.internalDecider = prtDecisionMap;
    clusterer = clusterer.train(dsbinary);
    clusterer.plot; drawnow; pause(0.1);
catch
    result = false;
end
