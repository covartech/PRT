function imageHandle = prtPlotUtilPlotGriddedEvaledFunction(DS, linGrid, gridSize, cMap, varargin)
% Internal function
% xxx Need Help xxx

p = inputParser;
p.addParameter('slicerLocations',[]);
p.addParameter('edgecolor','none');
p.addParameter('facealpha',1);
p.parse(varargin{:});

nDims = size(linGrid,2);
switch nDims
    case 1
        imageHandle = plot(linGrid, DS);
        
        %imageHandle = imagesc(linGrid,ones(size(linGrid)),DS);
        %set(gca,'YTickLabel',[])
        %colormap(cMap)
    case 2
        
        
        xx = reshape(linGrid(:,1),gridSize);
        yy = reshape(linGrid(:,2),gridSize);
        imageHandle = imagesc(xx(1,:),yy(:,1),reshape(DS,gridSize));
        set(imageHandle,'edgecolor',p.Results.edgecolor)
        set(imageHandle,'facealpha',p.Results.facealpha)
        colormap(cMap)
    case 3
        xx = reshape(linGrid(:,1),gridSize);
        yy = reshape(linGrid(:,2),gridSize);
        zz = reshape(linGrid(:,3),gridSize);
        slicerLocations = p.Results.slicerLocations;
        if isempty(p.Results.slicerLocations);
            slicerLocations = {max(xx(:)),max(yy(:)),[min(zz(:)),mean(zz(:))]};
        end
        imageHandle = slice(xx,yy,zz,reshape(DS,gridSize),slicerLocations{:});
        set(imageHandle,'edgecolor',p.Results.edgecolor)
        set(imageHandle,'facealpha',p.Results.facealpha)
        
        view(3)
        colormap(cMap)
        set(gca,'Layer','top');
        box on;
        imageHandle = imageHandle(1); % Sorry we need to throw the others away
end

if ~all(DS==DS(1))
    axis tight;
end
axis xy;

end
