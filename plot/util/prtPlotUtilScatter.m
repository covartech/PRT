function h = prtPlotUtilScatter(cX, featureNames, classSymbols, classColors, classEdgeColor, linewidth, markerSize)
% Internal function PRT function







nPlotDimensions = size(cX,2);
if nPlotDimensions < 1
    warning('prt:prtPlotUtilScatter:NoPlotDimensionality','No plot dimensions requested.');
    return
end
if nPlotDimensions > 3
    error('prt:prtPlotUtilScatter:plotDimensionality','The number of requested plot dimensions (%d) is greater than 3. You may want to use explore() to select and visualize a subset of the features.',nPlotDimensions);
end

switch nPlotDimensions
    case 1
        h = plot(cX,ones(size(cX)),classSymbols,'MarkerFaceColor',classColors,'MarkerEdgeColor',classEdgeColor,'linewidth',linewidth,'MarkerSize',markerSize);
        if ~isempty(featureNames)
            xlabel(featureNames{1});
        end
        set(gca,'YTick',[]);
        grid on
    case 2
        h = plot(cX(:,1),cX(:,2),classSymbols,'MarkerFaceColor',classColors,'MarkerEdgeColor',classEdgeColor,'linewidth',linewidth,'MarkerSize',markerSize);
        if ~isempty(featureNames)
            xlabel(featureNames{1});
            ylabel(featureNames{2});
        end
        grid on
    case 3
        h = plot3(cX(:,1),cX(:,2),cX(:,3),classSymbols,'MarkerFaceColor',classColors,'MarkerEdgeColor',classEdgeColor,'linewidth',linewidth,'MarkerSize',markerSize);
        if ~isempty(featureNames)
            xlabel(featureNames{1});
            ylabel(featureNames{2});
            zlabel(featureNames{3});
        end
        grid on;
end
