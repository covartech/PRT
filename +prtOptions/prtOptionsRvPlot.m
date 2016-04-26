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
        colorMapFunction = @(n)hot(n); % Two class colormap function handle
        nColorMapSamples = 256;
    end
    
    methods
        function obj = prtOptionsRvPlot(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end
    
%     methods
%         function obj = set.nSamplesPerDim(obj,val)
%             assert(length(val)==3,'largestMatrixSize must be a positive integer');
%             
%             if val < 1e3
%                 warning('prt:prtOptionsComputation','Although valid, this value for largestMatrixSize is small. Consider using a larger value.')
%             end
%         end
%     end
end
