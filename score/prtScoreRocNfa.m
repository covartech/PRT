function varargout = prtScoreRocNfa(ds,varargin)
% prtScoreRocNfa   Generate a operator characteristic curve and output the number of false alarms
%
%    prtScoreRocNfa(DECSTATS,LABELS) plots the receiver operator
%    characteristic curve for the decision statistics DECSTATS and the
%    corresponding labels LABELS. DECSTATS must be a Nx1 vector of decision
%    statistics. LABELS must be a Nx1 vector of binary class labels. This
%    behavior is the same as prtScoreRoc.
%
%    [NF,PD,THRESHOLDS,AUC] = prtScoreRocNfa(DECSTATS,LABELS) outputs the
%    number of false alarms NF, the probability of detection PD, the
%    thresholds used to obtain each PD and NF pair, and the area under the
%    ROC scurve AUC.
%
%    Example:     
%    TestDataSet = prtDataGenSpiral;       % Create some test and
%    TrainingDataSet = prtDataGenSpiral;   % training data
%    classifier = prtClassSvm;             % Create a classifier
%    classifier = classifier.train(TrainingDataSet);    % Train
%    classified = run(classifier, TestDataSet);     
%    % Find the number of false alarms at the corresponding PD.
%    [nf, pd ]= prtScoreRocNfa(classified.getX, TestDataSet.getY);
%
%   Additional parameter/value pairs:
%       See prtScoreRoc.
% 
%   See also prtScoreConfusionMatrix, prtScoreRmse,
%   prtScoreRocBayesianBootstrap, prtScoreRocBayesianBootstrapNfa,
%   prtScorePercentCorrect

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

p = inputParser;
p.addOptional('y',[]);
p.addParameter('outputStructure',false); %this gets handled in this M-file, at the end
p.addParameter('uniquelabels',[]);       %this gets passed through to ROC
p.parse(varargin{:});
inputs = p.Results;

if isempty(inputs.y);
    [nf,pd,thresholds,auc] = prtScoreRoc(ds,'uniquelabels',inputs.uniquelabels);
    y = ds.getTargets;
else
    [nf,pd,thresholds,auc] = prtScoreRoc(ds,inputs.y,'uniquelabels',inputs.uniquelabels);
end

nMiss = length(find(y == 0));
if iscell(nf)
    for iCell = 1:length(nf)
        nf{iCell} = nf{iCell}*nMiss;
    end
else
    nf = nf*nMiss;
end

if nargout == 0
    plot(nf,pd);
    xlabel('#FA');
    ylabel('Pd');
    
    varargout = {};
else
    varargout = {nf,pd,thresholds,auc};
    if inputs.outputStructure
        varargout{1} = struct('nfa',nf,'pd',pd,'tau',thresholds,'auc',auc);
    end
end
