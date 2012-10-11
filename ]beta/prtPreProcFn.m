classdef prtPreProcFn < prtAction
    % prtPreProcFn
    % 
    %  Apply a generic function to each dataSet.X(i,:)
    %
    
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