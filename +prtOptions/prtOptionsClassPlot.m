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
