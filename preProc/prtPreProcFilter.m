classdef prtPreProcFilter < prtPreProc
    % prtPreProcFilter   Data filtering
    %   Apply the filter specified in the propertes a and b to the rows of
    %   the data in dataSet.X:
    %
    % ds = prtDataGenCylinderBellFunnel;
    % b = fir1(21,.5);
    % pp = prtPreProcFilter('b',b,'a',1);
    % pp = pp.train(ds);
    % dsLpf = pp.run(ds);
    % subplot(1,2,1); imagesc(ds);
    % subplot(1,2,2); imagesc(dsLpf);

% Copyright (c) 2014 CoVar Applied Technologies
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
        name = 'Filter'  % Zero Mean Unit Variance
        nameAbbreviation = 'Filt'  % ZMUV
    end
    
    properties
        b = [];
        a = 1;
        filtfilt = true;
    end
    
    methods
        function Obj = prtPreProcFilter(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        function self = trainAction(self,ds)
            % nothing to do
        end
        
        
        function ds = runAction(self,ds)
            % Remove the means and normalize the variance
            X = ds.X;
            if self.filtfilt
                X = filtfilt(self.b,self.a,X')';
            else
                X = filter(self.b,self.a,X')';
            end
            ds.X = X;
        end
        
        function xOut = runActionFast(self,xIn,ds) %#ok<INUSD>
           if self.filtfilt
                xOut = filtfilt(self.b,self.a,xIn')';
            else
                xOut = filter(self.b,self.a,xIn')';
            end
        end
    end
    
    methods (Hidden)
        
        function str = exportSimpleText(self) %#ok<MANU>
            error('Not implemented');
            %             titleText = sprintf('%% prtPreProcZmuv\n');
            %             zmuvMeansText = prtUtilMatrixToText(self.means,'varName','means');
            %             zmuvVarsText = prtUtilMatrixToText(self.stds,'varName','std');
            %             str = sprintf('%s%s%s',titleText,zmuvMeansText,zmuvVarsText);
        end
    end
end
