% prtOptionsRvPlot contains available options for plotting RVs within the PRT
% 
% Properties
%   nSamplesPerDim - 1x3 int array - number of samples to use for plotting 
%       classifier confidence as a function of dimensionality [1D 2D 3D]
%       Default=[100 40 20]
%   colorMapFunction - a MATLAB colormap function
%
% Methods
%   Obj = prtOptionsRvPlot('paramName',paramVal,...) - Contructor
%

classdef prtOptionsRvPlot
    % Internal function
    % xxx Need Help xxx
    properties
        nSamplesPerDim = [100 40 20]; % Number of samples to use for plotting
        colorMapFunction = @(n)flipud(hot(n)); % Two class colormap function handle
        nColorMapSamples = 256;
    end
    
    methods
        function obj = prtOptionsRvPlot(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end    
end