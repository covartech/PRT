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
