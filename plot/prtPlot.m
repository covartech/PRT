function HandleStructure = prtPlot(varargin)
%HandleStructure = prtPlot(PrtDataSet)
%HandleStructure = prtPlot(PrtDataSet1,PrtDataSet2)
%HandleStructure = prtPlot(PrtClassifier)
%HandleStructure = prtPlot(PrtClassifier,PrtDataSet)

if nargin == 1 && isa(varargin{1},'prtDataSetBase')
    [handles,legendStrings] = plot(varargin{1});
    
    if nargout > 0
        HandleStructure.Axes(1) = struct('handles',handles,'legendStrings',legendStrings);
    end
    return;
elseif nargin == 2 && isa(varargin{1},'prtDataSetBase') && isa(varargin{2},'prtDataSetBase')    
    [handles1,legendStrings1,handles2,legendStrings2] = multiDataSetPlot(varargin{1},varargin{2});
    
    if nargout > 0
        HandleStructure.Axes(1) = struct('handles1',handles1,'handles2',handles2,'legendStrings1',legendStrings1,'legendStrings2',legendStrings2);
    end
    return;
elseif nargin == 1 && prtUtilIsClassifier(varargin{1})
    imageHandle = prtPlotClassifierConfidence(varargin{1});
    [M,N] = getSubplotDimensions(length(imageHandle));
    for subImage = 1:M*N
        subplot(M,N,subImage)
        hold on;
        [handles,legendStrings] = plot(varargin{1}.PrtDataSet);
        hold off;
        
        HandleStructureTemp.Axes(subImage) = struct('imageHandle',{imageHandle(subImage)},'handles',{handles},'legendStrings',{legendStrings});
    end
    
    if nargout > 0
        HandleStructure = HandleStructureTemp;
    end
    return;
elseif nargin == 2 && prtUtilIsClassifier(varargin{1}) && isa(varargin{2},'prtDataSetBase')
    imageHandle = prtPlotClassifierConfidence(varargin{1});
    [M,N] = getSubplotDimensions(length(imageHandle));
    for subImage = 1:M*N
        subplot(M,N,subImage)
        hold on;
        [handles1,legendStrings1,handles2,legendStrings2] = multiDataSetPlot(varargin{1}.PrtDataSet,varargin{2});
        hold off;
        
        HandleStructureTemp.Axes(subImage) = struct('imageHandle',{imageHandle(subImage)},'handles1',{handles1},'handles2',{handles2},'legendStrings1',{legendStrings1},'legendStrings2',{legendStrings2});
    end
    
    if nargout > 0
        HandleStructure = HandleStructureTemp;
    end
    return;
end

function [handles1,legendStrings1,handles2,legendStrings2] = multiDataSetPlot(DataSet1,DataSet2)
%[handles1,legendStrings1,handles2,legendStrings2] = multiDataSetPlot(DataSet1,DataSet2);
%   Handle plotting 2 data sets at a time, taking care of fusing legends,
%   making sure colors don't overlap, etc.

%Two data sets specified, plot the first:
[handles1,legendStrings1] = plot(DataSet1);
hold on;

%if data set unlabeled plotted with data set, go ahead and change the
%color to not conflict with data set 1
if isa(DataSet2,'prtDataSetUnlabeled')
    secondClassSymbols = @(n)dprtClassSymbols(n,'.+*>^');
    DataSet2.symbolsFunction = secondClassSymbols;
end
%Plot the second:
[handles2,legendStrings2] = plot(DataSet2);
hold off;

%Fix the legend; we might could check here if the legendstrings are
%identical, and the handles -> markers and colors are identical, just
%do this once
legend(cat(1,handles1(:),handles2(:)),cat(1,legendStrings1(:),legendStrings2(:)));
