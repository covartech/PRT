function imageHandle = prtPlotUtilImageEvaledClassifier(DS,linGrid,gridSize,PlotOptions)

cMap = feval(PlotOptions.twoClassColorMapFunction);
nDims = size(linGrid,2);

switch nDims
    case 1
        imageHandle = feval(PlotOptions.displayFunction{nDims},linGrid(:,1),linGrid(:,2),DS);
        set(gca,'YTickLabel',[])
        colormap(cMap)
    case 2
        xx = reshape(linGrid(:,1),gridSize);
        yy = reshape(linGrid(:,2),gridSize);
        imageHandle = feval(PlotOptions.displayFunction{nDims},xx(1,:),yy(:,1),DS);
        colormap(cMap)
    case 3
        xx = reshape(linGrid(:,1),gridSize);
        yy = reshape(linGrid(:,2),gridSize);
        zz = reshape(linGrid(:,3),gridSize);
        imageHandle = feval(PlotOptions.displayFunction{nDims},xx,yy,zz,DS,max(xx(:)),max(yy(:)),[min(zz(:)),mean(zz(:))]);
        view(3)
        colormap(cMap)
end
axis tight;
axis xy;

