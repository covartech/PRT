function h = prtPlotUtilScatter(cX)
% Internal function PRT function

nPlotDimensions = size(cX,2);
if nPlotDimensions < 1
    warning('prt:prtPlotUtilScatter:NoPlotDimensionality','No plot dimensions requested.');
    return
end
if nPlotDimensions > 3
    error('prt:prtPlotUtilScatter:plotDimensionality','The number of requested plot dimensions (%d) is greater than 3.',nPlotDimensions);
end

switch nPlotDimensions
    case 1
        h = scatter(cX, ones(size(cX)));
    case 2
        h = scatter(cX(:,1), cX(:,2));
    case 3
        h = scatter3(cX(:,1), cX(:,2), cX(:,3));        
end