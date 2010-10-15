function prtPlotUtilDataSetExplore(theObject)
% Internal function, 
% xxx Need Help xxx - see prtDataSetClass.explore

featureNames = theObject.getFeatureNames;
nFeatures = theObject.nFeatures;
if nFeatures >= 2
    plotDims = [1 2 0];
elseif nFeatures >= 1
    plotDims = [1 1 0];
else
    error('prt:prtPlotUtilDataSetExplore','explore() is only for data sets with features.')
end

updatePlot();

axesMenu = uicontextmenu;
axesMenuItem2D = uimenu(axesMenu, 'Label', '2D Plot', 'Callback', @switchTo2D); 
axesMenuItem3D = uimenu(axesMenu, 'Label', '3D Plot', 'Callback', @switchTo3D); 
set(gca,'UIContextMenu',axesMenu);

    function switchTo3D(h,E) %#ok<INUSD>
        set(axesMenuItem2D,'Checked','off');
        set(axesMenuItem3D,'Checked','on');
        
        otherFeatures = setdiff(1:nFeatures,plotDims);
        plotDims(3) = otherFeatures(1);
        
        updatePlot();
    end

    function switchTo2D(h,E) %#ok<INUSD>
        set(axesMenuItem2D,'Checked','on')
        set(axesMenuItem3D,'Checked','off')
        plotDims(3) = 0;
        updatePlot();
    end
    
    function updatePlot
        actualPlotDims = plotDims(plotDims>=1);
        plot(theObject,actualPlotDims)
        
        xContext = uicontextmenu;
        xItems = zeros(nFeatures,1);
        
        yContext = uicontextmenu;
        
        useZ = length(actualPlotDims) == 3;
        if useZ
            zContext = uicontextmenu;
            zItems = zeros(nFeatures,1);
        end
        
        yItems = zeros(nFeatures,1);
        for iFeature = 1:nFeatures
            xItems(iFeature) = uimenu(xContext,'Label',featureNames{iFeature},'CallBack',@(h,e)setPlotDim(1,iFeature));
            yItems(iFeature) = uimenu(yContext,'Label',featureNames{iFeature},'CallBack',@(h,e)setPlotDim(2,iFeature));
            if useZ
                zItems(iFeature) = uimenu(zContext,'Label',featureNames{iFeature},'CallBack',@(h,e)setPlotDim(3,iFeature));
            end
        end
        set(get(gca,'XLabel'),'UIContextMenu',xContext);
        set(get(gca,'YLabel'),'UIContextMenu',yContext);
        if useZ
            set(get(gca,'ZLabel'),'UIContextMenu',zContext);
        end
           
        set(xItems(actualPlotDims(1)),'Checked','on');
        set(yItems(actualPlotDims(2)),'Checked','on');
        if useZ
            set(zItems(actualPlotDims(3)),'Checked','on');
        end
        
    end

    function setPlotDim(axesIndex, featureIndex)
        plotDims(axesIndex) = featureIndex;
        updatePlot();
    end
end