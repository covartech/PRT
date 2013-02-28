classdef prtPreProcFn < prtAction
    % prtPreProcFn
    % 
    %  Apply a generic function to each dataSet.X(i,:)
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


    properties (SetAccess = protected)
        isSupervised = false;  % False
        isCrossValidateValid = true; % True
    end
    properties (SetAccess=private)
        name = 'FN' % Principal Component Analysis
        nameAbbreviation = 'FN'  % PCA
    end
    
    properties
        fnHandle
    end
    
    methods
        function self = prtPreProcFn(varargin)     
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            self.isTrained = true;
        end
    end
    
    methods (Access = protected, Hidden = true)
        function self = trainAction(self,~)
            
        end
        
        function dsOut = runAction(self,ds)
            
            x = ds.getX;
            
            xOut = self.fnHandle(x(1,:));
            xOut = repmat(xOut,size(x,1),1);
            for i = 2:size(x,1)
                xOut(i,:) = self.fnHandle(x(i,:));
            end
            dsOut = ds;
            dsOut = dsOut.setX(xOut);
        end
        
        function xOut = runActionFast(self,x)
            
            xOut = self.fnHandle(x(1,:));
            xOut = repmat(xOut,size(x,1),1);
            for i = 2:size(x,1)
                xOut(i,:) = self.fnHandle(x(i,:));
            end
            
        end
    end
end
