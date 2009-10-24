function imageHandle = prtPlotNativeMary(PrtClassifier,PrtDataSet) 

if ~isfield(PrtClassifier.PrtOptions,'PlotOptions')
    PrtClassifier.PrtOptions.PlotOptions = optionsDprtPlot;
end

nDims = PrtClassifier.PrtDataSet.nFeatures;
if nDims > 3
    error('PrtClassifier.PrtDataSet.nFeatures (%d) must be less than or equal to 3',PrtClassifier.PrtDataSet.nFeatures);
end

% % Now we remove the PreProcess field so when we run the grid we don't
% % pre process it.
% if isfield(PrtClassifier.PrtOptions,'PreProcess')
%     PrtClassifier.PrtOptions = rmfield(PrtClassifier.PrtOptions,'PreProcess');
% end

% Make the Meshgrid
[linGrid,gridSize,xx,yy,zz] = prtPlotUtilGenerateGrid(PrtClassifier,PrtDataSet);

% Now we remove the PreProcess field so when we run the grid we don't
% pre process it.
if isfield(PrtClassifier.PrtOptions,'PreProcess')
    PrtClassifier.PrtOptions = rmfield(PrtClassifier.PrtOptions,'PreProcess');
end

Results = prtRun(PrtClassifier,linGrid);
data = Results.y;

PlotOptions = PrtClassifier.PrtOptions.PlotOptions;
if isfield(PlotOptions,'mappingFunction') && ~isempty(PlotOptions.mappingFunction)
    data = feval(PlotOptions.mappingFunction,data);
end

% So now we got this huge linear grid of data values.

[M,N] = getSubplotDimensions(size(data,2));

classColors = feval(PlotOptions.colorsFunction,size(data,2));

hf = cell([size(data,2) 1]);
ha = cell([size(data,2) 1]);
hp = cell([size(data,2) 1]);

for i = 1:size(data,2);
    if M > 1 || N > 1
        subplot(M,N,i);
    end
    
    % imageHandle(i) = prtPlotUtilImageEvaledClassifier(data(:,i),linGrid,gridSize,PlotOptions);
    wasHold = ishold;
    
    cDS = reshape(data(:,i),size(xx));
    
    % Plot the grid
    switch nDims
        case 1
            imageHandle(i) = imagesc(xx(:),yy(:),ind2rgb(gray2ind(mat2gray(cDS,[min(data(:)) max(data(:))]),256),linspaceColormap([1 1 1], classColors(i,:)*0.8,256)));
            set(gca,'YTickLabel',[])
        case 2
            imageHandle(i) = imagesc(xx(1,:),yy(:,1),ind2rgb(gray2ind(mat2gray(cDS,[min(data(:)) max(data(:))]),256),linspaceColormap([1 1 1], classColors(i,:)*0.8,256)));
        case 3
            imageHandle(i) = feval(PlotOptions.displayFunction{NDIM},xx,yy,zz,cDS,max(xx(:)),max(yy(:)),[min(zz(:)),mean(zz(:))]);
            view(3)
    end
    axis tight;
    axis xy;
    hold on;
    
    ha{i} = gca;
    if ~wasHold
        hold off
    end
end

% Ready the output
if nargout > 0
    varargout{1} = hf;
    varargout{2} = ha;
    varargout{3} = hp;
end