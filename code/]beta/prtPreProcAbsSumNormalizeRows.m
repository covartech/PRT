classdef prtPreProcAbsSumNormalizeRows < prtPreProc
    % prtPreProcAbsSumNormalizeRows Normalize the rows to have
    % sum(abs(x))==1
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


    properties (SetAccess=private)
        
        name = 'Abs Sum Normalize Rows'  %  MinMax Rows
        nameAbbreviation = 'ASNR'  % MMR
    end
    
    properties
        %no properties
    end
    
    methods
        
        function Obj = prtPreProcAbsSumNormalizeRows(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet) %#ok<INUSD>
            %do nothing
        end
        
        function DataSet = runAction(Obj,DataSet) %#ok<MANU>
            
            theData = DataSet.getObservations;
            theData = abs(bsxfun(@rdivide,theData,sum(abs(theData),2)));
            DataSet = DataSet.setObservations(theData);
        end
        
    end
    
end
