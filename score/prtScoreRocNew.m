function varargout = prtScoreRocNew(dsObs,dsTargs)
% sortedDS is thresholds

ds = dsObs.getObservations(:,1);
if nargin < 2
    y = dsObs.getTargetsAsBinaryMatrix;
    y = y(:,end);
else
    y = dsTargs.getTargetsAsBinaryMatrix;
    y = y(:,end);
end

[sortedDS, sortingInds] = sort(ds,'descend');

% Move nans to the bottom
nanSpots = isnan(sortedDS);
sortedDS = cat(1,sortedDS(~nanSpots),sortedDS(nanSpots));
sortingInds = cat(1,sortingInds(~nanSpots),sortingInds(nanSpots));

nanSpots = isnan(sortedDS);

% Sort y
sortedY = y(sortingInds);

% Start making 
pFa = double(~sortedY); % number of false alarms as a function of threshold
pD = sortedY; % number of detections as a function of threshold


% Detect and handle ties

if length(sortedDS) > 1
    isTiedWithNext = cat(1,sortedDS(1:(end-1)) == sortedDS(2:end),false);
else
    isTiedWithNext = false;
end

% If there are any ties we need to figure out the tied regions and set each
% of the ranks to the average of the tied ranks.
tieRegions = [];
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
    % For PD we set the first value in the tied region equal to the length
    % of the tied region, and set the rest to zero
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

if nargout == 0
    plot(pf,pd);
    xlabel('Pf');
    ylabel('Pd');
    
    varargout = {};
else
    varargout = {pFa,pD};
end
