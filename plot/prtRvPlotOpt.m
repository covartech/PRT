% prtPlotOpt contains available options for plotting within the PRT
% 
% Properties
%   nSamplesPerDim - 1x3 int array - number of samples to use for plotting 
%       classifier confidence as a function of dimensionality [1D 2D 3D]
%       Default=[500 100 20]
%   colorMapFunction - a MATLAB colormap function
%
% Methods
%   Obj = prtPlotOpt('paramName',paramVal,...) - Contructor
%

classdef prtRvPlotOpt
    
    properties
        nSamplesPerDim = [1000 500 100]; % Number of samples to use for plotting
        colorMapFunction = @(n)flipud(hot(n)); % Two class colormap function handle
        nColorMapSamples = 256;
    end
    
    methods
        function obj = prtRvPlotOpt(varargin)
            % prtRvPlotOpt - Constructor for prtRvPlotOpt
            % 
            % Obj = prtRvPlotOpt();
            % Obj = prtRvPlotOpt('paramName',paramVal,...);
            
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end    
end