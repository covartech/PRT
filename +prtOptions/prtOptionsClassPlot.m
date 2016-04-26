% prtOptionsClassPlot contains available options for plotting within the PRT
% 
% Properties
%   nSamplesPerDim - 1x3 int array - number of samples to use for plotting 
%       classifier confidence as a function of dimensionality [1D 2D 3D]
%       Default=[500 100 20]
%   colorsFunction - Function handle that returns the colors to use for
%       plotting datasets. Must accept an int (nClasses) and return an
%       nClassesx3 double of RGB colors Default=@prtPlotUtilClassColors;
%   symbolsFunction - Function handle that returns the symbols to use for
%       plotting datasets. Must accept an int (nClasses) and return a
%       1xnClasses char array of plotting symbols. 
%       Default=@prtPlotUtilClassSymbols
%   twoClassColorMapFunction - Function handle that returns a colormap for 
%       plotting confidence in two class problems. Must be able to accept
%       a single int (nColorInds) and return a valid MATLAB colormap
%       Default=@prtPlotUtilTwoClassColorMap
%   mappingFunction - A function handle that maps the confidence values
%       prior to visualization traditional plot function. Must accept a
%       double array of Nx1, Nx2, or Nx3 and return a double array of the
%       same size. Default=[]
%   additionalPlotFunction - A function handle that gets executed after the
%       traditional plot function. Must accept two arguments
%       (PrtActionObj, DataSet) Default=[]
%
% Methods
%   Obj = prtPlotOpt('paramName',paramVal,...) - Contructor
%







classdef prtOptionsClassPlot
    % xxx Need Help xxx
    properties
        nSamplesPerDim = [500 100 20]; % Number of samples to use for plotting
        colorsFunction = @prtPlotUtilClassColors; % Colors function handle

        twoClassColorMapFunction = @prtPlotUtilTwoClassColorMap; % Two class colormap function handle        
    end
    
    methods
        function obj = prtOptionsClassPlot(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end    
end
