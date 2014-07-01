function varargout = prtScoreRoc(ds,y,varargin)
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
%    [PF, PD, THRESHOLDS, AUC] = prtScoreRoc(DECSTATSMAT,LABELS) outputs
%    the roc outputs for each column of DECSTATSMAT using. The output
%    values are now cell arrays containing the outputs as if prtScoreRoc
%    were called on each column of DECSTATSMAT individually.
%
%    [...] = prtScoreRoc(PRTDATASETCLASS) use a prtDataSetClass as input
%    DECSTATS is PRTDATASETCLASS.getObservations() and LABELS is
%    PRTDATASETCLASS.getTargets(). If PRTDATASETCLASS.nFeatures > 1 cell
%    arrays are provided as outputs.
%
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
%   See also prtScoreConfusionMatrix, prtScoreRmse, prtScoreRocNfa,
%            prtScorePercentCorrect, prtScoreAuc

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



if (nargin == 1 || isempty(y)) && isa(ds,'prtDataSetClass')
	y = ds;
end

dsOrig = ds;
[ds,y] = prtUtilScoreParseFirstTwoInputs(ds,y,mfilename);

%Handle multi-dimensional input DS (numeric or prtDataSetClass)
if size(ds,2) > 1
	for iRoc = 1:size(ds,2)
		[pf{iRoc},pd{iRoc},thresholds{iRoc},auc{iRoc}] = prtScoreRoc(ds(:,iRoc),y,varargin{:}); %#ok<AGROW>
	end
	if nargout == 0
		colors = prtPlotUtilClassColors(size(ds,2));
		holdState = get(gca,'nextPlot');
		lineHandles = zeros(size(ds,2),1);
		for iRoc = 1:size(ds,2)
			lineHandles(iRoc) = plot(pf{iRoc},pd{iRoc},'color',colors(iRoc,:));
			hold on
		end
		xlabel('P_F');
		ylabel('P_D');
		grid on;
		set(gca,'nextPlot',holdState);
		
        if ~isempty(dsOrig.getFeatureNames) && (length(dsOrig.getFeatureNames) == length(lineHandles))
            legend(lineHandles, dsOrig.getFeatureNames,'Location','SouthEast')
        end
        varargout = {};
        
	else
		varargout = {pf, pd, thresholds, auc};
	end
	return;
end


uY  = prtScoreRocVararginParse(ds,y,varargin{:});

if ~isreal(ds(:))
	error('ROC requires input ds to be real');
end
if any(isnan(ds(:)))
	warning('PRT:roc:dsContainsNans',['ds input to ROC function contains NaNs; these are interpreted as "missing data".  \n',...
		' The resulting ROC curve may not acheive Pd or Pfa = 1'])
end

if length(uY) ~= 2
	error('prt:prtUtilScoreRoc:wrongNumberClasses','ROC requires input labels to have 2 unique classes; unique(y(:)) = %s\n',mat2str(unique(y(:))));
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


function uY  = prtScoreRocVararginParse(ds,y,varargin) %#ok<INUSL>

uY = [];

if nargin > 1 && mod(nargin,2)~=0
	error('prt:prtScoreRoc','Additional inputs to prtScoreRoc must be parameter string value pairs');
end

strPairs = varargin(1:2:end);
valPairs = varargin(2:2:end);

for iStr = 1:length(strPairs)
	switch lower(strPairs{iStr})
		case 'uniquelabels'
			uY = valPairs{iStr}(:);
		otherwise
			error('prt:prtScoreRoc','Unknown parameter name %s, for prtScoreRoc',strPairs{iStr});
	end
end

if isempty(uY)
	uY = unique(y(:));
end
