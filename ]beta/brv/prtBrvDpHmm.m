classdef prtBrvDpHmm < prtBrvHmm

% Copyright (c) 2013 New Folder
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
    methods

        
        function obj = prtBrvDpHmm(varargin)
            if nargin < 1
                return
            end
            
            obj.components = varargin{1}(:);
            
            obj.initialProbabilities = prtBrvDiscreteStickBreaking(obj.nComponents);
            obj.initialProbabilities.model.useOptimalSorting = false;
            obj.initialProbabilities.model.useGammaPriorOnScale = false;
            
            obj.transitionProbabilities = repmat(prtBrvDiscreteStickBreaking(obj.nComponents),obj.nComponents,1);
            for s = 1:obj.nComponents
                obj.transitionProbabilities(s).model.useOptimalSorting = false;
                obj.transitionProbabilities(s).model.useGammaPriorOnScale = false;
            end
        end
    end
end
        
