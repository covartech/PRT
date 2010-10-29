function varargout = prtScoreRoc(ds,y)
% prtScoreRoc   Generate a reciever operator characteristic curve
%
%    prtScoreRoc(DECSTATS,LABELS) plots the receiver operator
%    characteristic curve for the decision statistics DECSTATS and the
%    corresponding labels LABELS. DECSTATS must be a Nx1 vector of decision
%    statistics. LABELS must be a Nx1 vector of binary class labels.
%
%    [PF, PD, THRESHOLDS, AUC] = prtScoreRoc(DECSTATS,LABELS) outputs the
%    probability of false alarm PF, the probability of detection PD, the
%    THREHSOLDS required to achieved each PF and PD, and the area under the
%    ROC curve AUC.
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

% Copyright 2010, New Folder Consulting, L.L.C.

if nargin == 1 && isa(ds,'prtDataSetClass')
    y = ds;
end

[ds,y] = prtUtilScoreParseFirstTwoInputs(ds,y);


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

[sortedDS, sortingInds] = sort(ds,'descend');

nanSpots = isnan(sortedDS);

% Sort y
sortedY = y(sortingInds);

% Start making 
pFa = double(~sortedY); % number of false alarms as a function of threshold
pD = double(sortedY); % number of detections as a function of threshold

% Detect and handle ties
if length(sortedDS) > 1
    isTiedWithNext = cat(1,sortedDS(1:(end-1)) == sortedDS(2:end),false);
else
    isTiedWithNext = false;
end

% If there are any ties we need to figure out the tied regions and set each
% of the ranks to the average of the tied ranks.
if any(isTiedWithNext)
    diffIsTiedWithNext = diff(isTiedWithNext);
    
    if isTiedWithNext(1) % First one is tied
        diffIsTiedWithNext = cat(1,1,diffIsTiedWithNext);
    else
        diffIsTiedWithNext = cat(1,0,diffIsTiedWithNext);
    end

    % Start and stop regions of the ties
    tieRegions = cat(2,find(diffIsTiedWithNext==1),find(diffIsTiedWithNext==-1));

    % For each tied region 
    % We set the first value of PD (or PF) in the tied region equal to the
    % number of hits (or non-hits) in the range and we set the rest to zero
    % This makes sure that when we cumsum (integrate) we get all of the
    % tied values at the same time.
    for iRegion = 1:size(tieRegions,1);
        pD(tieRegions(iRegion,1)) = sum(pD(tieRegions(iRegion,1):tieRegions(iRegion,2)));
        pD((tieRegions(iRegion,1)+1):(tieRegions(iRegion,2))) = 0;
        pFa(tieRegions(iRegion,1)) = sum(pFa(tieRegions(iRegion,1):tieRegions(iRegion,2)));
        pFa((tieRegions(iRegion,1)+1):(tieRegions(iRegion,2))) = 0;
    end
end
nH1 = sum(sortedY);
nH0 = length(sortedY)-nH1;

pD(nanSpots & ~~sortedY) = 0; % NaNs are not counted as detections
pFa(nanSpots & ~sortedY) = 0; % or false alarms

pD = cumsum(pD)/nH1;
pFa = cumsum(pFa)/nH0;

pD = cat(1,0,pD);
pFa = cat(1,0,pFa);

if nargout > 3
    %this is faster than prtScoreRoc if we've already calculated pd and pf,
    %which we have:
    auc = trapz(pFa,pD);
else
    auc = [];
end

if nargout == 0
    plot(pFa,pD);
    xlabel('Pf');
    ylabel('Pd');
    
    varargout = {};
else
    varargout = {pFa, pD, cat(1,inf,sortedDS(:)), auc};
end