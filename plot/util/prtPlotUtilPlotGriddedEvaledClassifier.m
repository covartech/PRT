function imageHandle = prtPlotUtilPlotGriddedEvaledClassifier(DS, linGrid, gridSize, cMap, prtActor)
% Internal function
% xxx Need Help xxx

% Check to see if we are plotting a decision
if ~isempty(prtActor.internalDecider)
    % When using a decider DS contains integers and the linear spacing
    % applied using the colormap may not be correct (depending on the 
    % specific integer labels). Therefore we have to change DS to be
    % consecutive integers corresponding to the integer labels that were
    % used.
    if ~isempty(prtActor.internalDecider.dataSetSummary.uniqueClasses)
        [dontNeed, DS] = ismember(DS,prtActor.internalDecider.dataSetSummary.uniqueClasses); %#ok<ASGLU>
    else
        % Have something unsupervised like a clusterer
        % Just roll with it.
    end
end
nDims = size(linGrid,2);

switch nDims
    case 1
        DS = repmat(DS,1,max(prtActor.dataSetSummary.uniqueClasses));
        imageHandle = imagesc(linGrid,[min(prtActor.dataSetSummary.uniqueClasses),max(prtActor.dataSetSummary.uniqueClasses)]',DS');
        set(gca,'YTickLabel',[])
        colormap(cMap)
    case 2
        xx = reshape(linGrid(:,1),gridSize);
        yy = reshape(linGrid(:,2),gridSize);
        imageHandle = imagesc(xx(1,:),yy(:,1),reshape(DS,gridSize));
        colormap(cMap)
    case 3
        xx = reshape(linGrid(:,1),gridSize);
        yy = reshape(linGrid(:,2),gridSize);
        zz = reshape(linGrid(:,3),gridSize);
        imageHandle = slice(xx,yy,zz,reshape(DS,gridSize),max(xx(:)),max(yy(:)),[min(zz(:)),mean(zz(:))]);
        view(3)
        colormap(cMap)
        imageHandle = imageHandle(1); % Sorry we need to throw the others away
end
axis tight;
axis xy;

end