% PRTBRVDISCRETEHIERARCHY - PRT BRV Discrete hierarchical model structure
%   Has parameters that specify a dirichlet density

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
classdef prtBrvDiscreteHierarchy

    properties
        lambda
    end
    methods
        function self = prtBrvDiscreteHierarchy(varargin)
            if nargin < 1
                return
            end
            
            self = defaultParameters(self,varargin{1});
        end
        
        function self = defaultParameters(self, nDimensions)
            self.lambda = ones(1,nDimensions)/nDimensions;
            %self.lambda = ones(1,nDimensions)*nDimensions;
        end
        
        function tf = isValid(self)
            tf = ~isempty(self.lambda);
        end
    end
end
