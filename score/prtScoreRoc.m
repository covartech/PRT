function [pf,pd,auc,thresholds,classLabels] = prtScoreRoc(ds,y,nRocSamples,nPfSamples,nPdSamples)
% prtScoreRoc   Generate a reciever operator characteristic curve
%
%    prtScoreRoc(DECSTATS,LABELS) plots the receiver operator
%    characteristic curve for the decision statistics DECSTATS and the
%    corresponding labels LABELS. DECSTATS must be a Nx1 vector of decision
%    statistics. LABELS must be a Nx1 vector of binary class labels.
%
%    [PF, PD, AUC] = prtScoreRoc(DECSTATS,LABELS) outputs the probability
%    of false alarm PF, the probability of detection PD, and the area under
%    the ROC curve AUC.
%
%    Example:
%    TestDataSet = prtDataGenSpiral;       % Create some test and
%    TrainingDataSet = prtDataGenSpiral;   % training data
%    classifier = prtClassSvm;             % Create a classifier
%    classifier = classifier.train(TrainingDataSet);    % Train
%    classified = run(classifier, TestDataSet);     
%    %  Plot the ROC
%    prtScoreRoc(classified.getX, TestDataSet.getY);
%
%   See also prtScoreConfusionMatrix, prtScoreRmse,
%   prtScoreRocBayesianBootstrap, prtScoreRocBayesianBootstrapNfa,
%   prtScorePercentCorrect

% Syntax: 
%       [pf,pd,auc,thresholds] = roc(ds,y);
%       [pf,pd,auc,thresholds] = roc(ds,y,nRocSamples)
%
% Inputs:
%   ds - double Vec - A vector of N decisions statistics.
%   y - int Vec - A vector of class labels.
%   nRocSamples - int - The number of linearly spaced samples to use for 
%       the threshold of the ROC curve.  Defaults to length(ds), with
%       non-linear spacing equivalent to sort(ds).  This is the usual
%       expected full ROC curve.
%
% Outputs:
%   pf - double Vec - Probability of falsa alarm as a function of
%       threshold.
%   pd - double Vec - Probability of detection as a function of threshold.
%   auc - double - The area under the ROC curve.
%   thresholds - double Vec - The vector of thresholds used to determine the pf
%       and pd values.
%
% Example:
%   ds = prtDataSetUnimodal;
%   yout = kfolds(prtClassFld,ds);
%   prtScoreRoc(yout.getObservations,ds.getTargets);
%   roc(ds,y)
%
%   [...] = prtScoreRoc(ds,y,nRocSamples,nPfSamples,nPdSamples);
%       Allows the user to specify one of nRocSamples, nPfSamples, or
%       nPdSamples.  nRocSamples guarantees uniform (linear) sampling in
%       the ds space, NPF or NPD samples guarantee uniform (linear)
%       sampling in those respective spaces.  This is important when ds
%       values may be logarithmically spaced.  Note that only one of NROC,
%       NPF or nPdSamples may be non-empty.  So:  
%           roc(ds,y,[],[],100);
%       is a valid call, but:
%           roc(ds,y,[],100,100); 
%       is not valid.  If all N*samples variables are empty, ROC.M defalts
%       to sampling the ROC curve at every point in ds - i.e. the default
%       from above.
%
%       The following illustrates
%       the phenomenon and the resulting linear or non-linearly spaced
%       results:
%
%       close all; clear all; 
%       NrocSamp = 10;      %highly under-sampled ROC curve!
%       NdataSamp = 300;    
%       X = cat(1,randn(NdataSamp,1),randn(NdataSamp,1)+2);
%       X = exp(X);     %highly non-linear ds
%       y = cat(1,zeros(NdataSamp,1), ones(NdataSamp,1));
%       [pffull,pdfull] = prtScoreRoc(X,y,[],[],[]); 
%       [pf1,pd1] = prtScoreRoc(X,y,NrocSamp,[],[]); 
%       [pf2,pd2] = prtScoreRoc(X,y,[],NrocSamp,[]); 
%       [pf3,pd3] = prtScoreRoc(X,y,[],[],NrocSamp);
%       figure(1);
%       h = plot(pffull,pdfull,pf1,pd1,pf2,pd2,pf3,pd3);
%       legend(h,{'Full','Linear ds','Linear pf','Linear pd'},4);
%       xlabel('pf'); ylabel('pd');
%       figure(2);
%       h = plot(1:length(pffull),pffull,1:length(pf1),pf1,1:length(pf2),pf2,1:length(pf3),pf3);
%       legend(h,{'pf Full','pf Linear ds','pf Linear pf','pf Linear pd'});
%       xlabel('Nsamples'); ylabel('pf');
%       figure(3);
%       h = plot(1:length(pdfull),pdfull,1:length(pd1),pd1,1:length(pd2),pd2,1:length(pd3),pd3);
%       legend(h,{'pd Full','pd Linear ds','pd Linear pf','pd Linear pd'});
%       xlabel('Nsamples'); ylabel('pd');

% Copyright 2010, New Folder Consulting, L.L.C.

%handle the different possible input combinations:
if nargin == 2
    nRocSamples = [];
    nPfSamples = [];
    nPdSamples = [];
elseif nargin == 3
    nPfSamples = [];
    nPdSamples = [];
elseif nargin == 4
    nPdSamples = [];
end

%Handle multi-dimensional input DS (numeric or prtDataSetClass)
if (isnumeric(ds) && size(ds,2) > 1)
    for j = 1:size(ds,2)
        [pf{j},pd{j},auc{j},thresholds{j},classLabels{j}] = prtScoreRoc(ds(:,j),y,nRocSamples,nPfSamples,nPdSamples); %#ok<NASGU,AGROW>
    end
    if nargout == 0
        hold all;
        for j = 1:size(ds,2)
            lineHandles(j) = plot(pf{j},pd{j}); %#ok<AGROW,NASGU>
            xlabel('Pf');
            ylabel('Pd');
        end
        clear pf pd auc thresholds classLabels
    end
    return;
elseif isa(ds,'prtDataSetClass') && ds.nFeatures > 1
    for j = 1:ds.nFeatures
        tempDs = ds.retainFeatures(j);
        [pf{j},pd{j},auc{j},thresholds{j},classLabels{j}] = prtScoreRoc(tempDs,y,nRocSamples,nPfSamples,nPdSamples); %#ok<NASGU,AGROW>
    end
    if nargout == 0
        for j = 1:ds.nFeatures
            lineHandles(j) = plot(pf{j},pd{j}); %#ok<AGROW,NASGU>
            hold all;
        end
        xlabel('Pf');
        ylabel('Pd');
        hold off;
        clear pf pd auc thresholds classLabels
    end
    return;
end

%Regular processing
[ds,y,classLabels] = prtUtilScoreParseFirstTwoInputs(ds,y);

if ~isreal(ds(:))
    error('ROC requires input ds to be real');
end
if any(isnan(ds(:)))
    warning('PRT:roc:dsContainsNans',['ds input to ROC function contains NaNs; these are interpreted as "missing data".  \n',...
        ' The resulting ROC curve may not acheive Pd or Pfa = 1'])
end
uY = unique(y(:));
if length(uY) ~= 2  
    error('ROC requires only 2 unique classes; unique(y(:)) = %s\n',mat2str(unique(y(:))));
end
if length(ds) ~= length(y);
    error('length(ds) (%d) must equal length(y) (%d)',length(ds),length(y));
end
newY = y;
newY(y==uY(1)) = 0;
newY(y==uY(2)) = 1;
y = newY;
% if ~isequal(unique(y(:)),[0,1]') && ~isequal(unique(y(:)),[0]') && ~isequal(unique(y(:)),[1]')
%     error('ROC requires unique classes to be 0 and 1; unique(y(:)) = %s\n',mat2str(unique(y(:))));
% end
if (length(unique(y)) == length(y)) && length(y) > 2
    warning('PRT:roc:invalidY','Attempt to call ROC with y ~ DS0; New ROC code requires roc(ds,y) - not roc(DS1,DS0)...');
    DS_H1 = ds;
    DS_H0 = y;
else
    % Input check
    if numel(ds) ~= length(ds)
        error('ROCs can only be realized in a 2 class case')
    end
    y = y(:);
    if ~isempty(setdiff(unique(y),[0; 1]))
        warning('PRT:roc:multiClassY',['ROCs can only be realized in a 2 class case. ' ...
            'Samples with y~=0 will assumed to be members H1.'])
        y(y~=0) = 1;
    end
    
    DS_H1 = ds(y==1);
    DS_H0 = ds(y==0);
end

mtVec = [~isempty(nRocSamples),~isempty(nPfSamples),~isempty(nPdSamples)];
if length(find(mtVec)) > 1
    error('Only one of nRocSamples (%s), nPfSamples (%s), nPdSamples (%s) can be non-empty',mat2str(size(nRocSamples)),...
        mat2str(size(nPfSamples)),mat2str(size(nPdSamples)));
end
%if the user has not specified the number of ROC samples, default to -1
if isempty(find(mtVec,1))
    nRocSamples = -1;
end

%initialize pf and pd
pf = zeros(nRocSamples+1,1);
pd = zeros(nRocSamples+1,1);

%make the DS_H* matrices into vectors
DS_H1 = DS_H1(:);  %reshape vectors to be Nx1
DS_H0 = DS_H0(:);

%count the total number of possible hits and misses
Nhit = length(DS_H1);
Nmiss = length(DS_H0);

%let the threshold range over the total range of ds values
if nRocSamples == -1
    %use length ds samples:
    thresholds = sort(ds);
    pf = zeros(length(ds)+1,1);
    pd = zeros(length(ds)+1,1);
    nRocSamples = length(ds);
elseif ~isempty(nRocSamples)
    %use nRocSamples:
    thresholds = linspace(min(ds),max(ds),nRocSamples);
elseif ~isempty(nPfSamples);
    %NPF code samples pf uniformly by sampling sorted DS_H0 uniformly
    DS_H0_sort = sort(DS_H0);
    pfvalsIndices = linspace(1,length(DS_H0_sort),nPfSamples);
    thresholds = DS_H0_sort(round(pfvalsIndices));
    thresholds = [min(ds);thresholds;max(ds)];
    nRocSamples = length(thresholds);
elseif ~isempty(nPdSamples);
    %NPD code samples pd uniformly by sampling sorted DS_H1 uniformly:
    DS_H1_sort = sort(DS_H1);
    pdvalsIndices = linspace(1,length(DS_H1_sort),nPdSamples);
    thresholds = DS_H1_sort(round(pdvalsIndices));
    thresholds = [min(ds);thresholds;max(ds)];
    nRocSamples = length(thresholds);
end

%for each possible threshold (thresholds determines spacing in ds/pd/pf space,
%see above)
for COUNT = 1:nRocSamples
    thresh = thresholds(COUNT);
    %DS_H0(DS_H0 >= thresh) are false alarms;
    pf(COUNT) = length(find(DS_H0 >= thresh));
    %DS_H1(DS_H1 >= thresh) are targets; 
    pd(COUNT) = length(find(DS_H1 >= thresh));
end

%normalize the number of false alarms and detections
if Nmiss == 0
    pf = nan(size(pf));
    pf = zeros(size(pf));
else
    pf = pf./Nmiss;
end
if Nhit == 0
    pd = nan(size(pd));
else
    pd = pd./Nhit;
end

if nargout > 2
    auc = trapz(flipud(pf(:)),flipud(pd(:)));
    % [redhed, sortInd] = sort(ds);
    % auc = (sum(find(y(sortInd))) - Nhit*(Nhit + 1)/2) / (Nmiss*Nhit); % eq. 1 of Hand and Till, 2001
end

%if there are no outputs; plot the ROC;
if nargout == 0
    plot(pf,pd);
    xlabel('Pf');
    ylabel('Pd');
    clear pf pd auc
end
