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

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
