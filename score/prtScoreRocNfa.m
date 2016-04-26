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
    y = inputs.y;
end
pf = nf;

nMiss = length(find(y == 0));
if iscell(nf)
    for iCell = 1:length(nf)
        nf{iCell} = nf{iCell}*nMiss;
    end
else
    nf = nf*nMiss;
end

if nargout == 0
	plot(pFa,pD);
	xlabel('Pf');
	ylabel('Pd');
	
	varargout = {};
else
    varargout = {nf,pd,thresholds,auc};
    if nargout == 1
        varargout{1} = prtMetricRoc('pf',pf,'pd',pd,'nfa',nf,'tau',thresholds,'auc',auc);
    end
    if inputs.outputStructure
        varargout{1} = struct('pf',pf,'pd',pd,'nfa',nf,'tau',thresholds,'auc',auc);
    end
end
