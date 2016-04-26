function imageHandle = prtPlotUtilImageEvaledClassifier(DS,linGrid,gridSize,cMap)
% Internal function, 
% xxx Need Help xxx







nDims = size(linGrid,2);

switch nDims
    case 1
        imageHandle = imagesc(linGrid(:,1),linGrid(:,2),DS);
        set(gca,'YTickLabel',[])
        colormap(cMap)
    case 2
        xx = reshape(linGrid(:,1),gridSize);
        yy = reshape(linGrid(:,2),gridSize);
        imageHandle = imagesc(xx(1,:),yy(:,1),DS);
        colormap(cMap)
    case 3
        xx = reshape(linGrid(:,1),gridSize);
        yy = reshape(linGrid(:,2),gridSize);
        zz = reshape(linGrid(:,3),gridSize);
        imageHandle = slice(xx,yy,zz,DS,max(xx(:)),max(yy(:)),[min(zz(:)),mean(zz(:))]);
        view(3)
        colormap(cMap)
end
axis tight;
axis xy;

