classdef prtKernelRbfFixed < prtKernel







    
    properties (SetAccess = private)
        name = 'RBF Kernel'; % RBF Kernel
        nameAbbreviation = 'RBF'; % RBF
    end
    
    properties
        sigma = 1; % The inverse kernel width
        x0 = 0;
    end 
    
    methods (Hidden = true)
        
        function nDimensions = nDimensions(self)
            nDimensions = 1;
        end
        
    end
    methods (Access = protected, Hidden = true)
        function self = trainAction(self,ds)
            self.internalDataSet = ds;
            self.isTrained = true;
        end
        
        function dsOut = runAction(self,ds)
            if ~self.isTrained
                error('prtKernelRbf:run','Attempt to run an untrained kernel; use kernel.train(ds) to train');
            end
            if self.internalDataSet.nObservations == 0
                dsOut = prtDataSetClass;
            else
                gram = prtKernelRbf.kernelFn(ds.getObservations,self.x0,self.sigma);
                dsOut = ds.setObservations(gram);
            end
        end
    end
    
    methods
        function self = prtKernelRbfFixed(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function self = set.sigma(self,value)
            if ~prtUtilIsPositiveScalar(value)
                assert(isnumeric(value) && all(value>0) && isvector(value),'sigma must be a positive numeric vector')
                if isempty(self.internalDataSet) || self.internalDataSet.nObservations==0
                    error('prtKernelRbf:set','Value of sigma must be a positive scalar');
                else
                    assert(self.internalDataSet.nObservations==numel(value),'When setting sigma to be an array of values the internalDataSet must be set and the number of observations and the length of sigma must match');
                end
            end
            self.sigma = value(:);
        end
    end
    
    methods(Hidden = true)
        function varargout = plot(obj)
            x = obj.internalDataSet.getObservations;
            
            if size(x,2) <= 3
                if size(x,2) == 1 && obj.internalDataSet.isLabeled
                    xy = cat(2,x,obj.internalDataSet.getTargets);
                    h = prtPlotUtilScatter(xy, {}, obj.plotOptions.symbol, obj.plotOptions.markerFaceColor, obj.plotOptions.color, obj.plotOptions.symbolLineWidth, obj.plotOptions.symbolSize);
                else
                    h = prtPlotUtilScatter(x, {}, obj.plotOptions.symbol, obj.plotOptions.markerFaceColor, obj.plotOptions.color, obj.plotOptions.symbolLineWidth, obj.plotOptions.symbolSize);
                end
            else
                h = nan;
            end
            
            varargout = {};
            if nargout
                varargout = {h};
            end
        end
    end
    
    methods (Static, Hidden = true)
        function gram = kernelFn(x,y,sigma)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            %             if d ~= nin
            %                 error('size(x,2) must equal size(y,2)');
            %             end
            %             keyboard
            %dist2 = prtDistanceLNorm(x,y,2); 
            dist2 = repmat(sum((x.^2), 2), [1 n2]) + repmat(sum((y.^2),2), [1 n1]).' - 2*x*(y.');
            
            if numel(sigma) == 1
                gram = exp(-dist2/(sigma.^2));
            else
                gram = exp(-bsxfun(@rdivide,dist2,(sigma.^2)'));
            end
        end
    end
end
