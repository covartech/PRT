classdef prtKernelStep < prtKernel







    
    properties (SetAccess = private)
        name = 'Kernel Step'; % RBF Kernel
        nameAbbreviation = 'Step'; % RBF
    end
    
    properties
        sigma = 1; % The inverse kernel width
    end 
    
    methods (Access = protected, Hidden = true)
        function Obj = trainAction(Obj,ds)
            Obj.internalDataSet = ds;
            Obj.isTrained = true;
        end
        
        function dsOut = runAction(Obj,ds)
            if ~Obj.isTrained
                error('prtKernelRbf:run','Attempt to run an untrained kernel; use kernel.train(ds) to train');
            end
            if Obj.internalDataSet.nObservations == 0
                dsOut = prtDataSetClass;
            else
                gram = prtKernelStep.kernelFn(ds.getObservations,Obj.internalDataSet.getObservations);
                dsOut = ds.setObservations(gram);
            end
        end
    end
    
    methods
        function Obj = prtKernelStep(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
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
        function gram = kernelFn(x,y)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            gram = true(n1,n2);
            for dim = 1:d;
                gram = gram & bsxfun(@(x,y) x > y,x(:,d),y(:,d)');
            end
            gram = double(gram);
%             gram = imfilter(gram,fspecial('gaussian',[11,1],4));
            
        end
    end
end
