classdef prtClassPlsda < prtClass
    % prtClassPlsda Properties: 
    %   name - Partial Least Squares Discriminant
    %	nameAbbreviation - PLSDA
    %	isSupervised - true
    %	isNativeMary - true
    %
    %   Bpls - regression weights - estimated during training
    %   xMeans - 
    %   yMeans -     

    properties (SetAccess=private)
        % Required by prtAction
        name = 'Partial Least Squares Discriminant'
        nameAbbreviation = 'PLSDA'
        isSupervised = true;
        
        % Required by prtClass
        isNativeMary = true;
    end
    
    properties
        % w is a DataSet.nDimensions x 1 vector of projection weights
        % learned during Fld.train(DataSet)
        nComponents = 2;
    end
    properties (SetAccess=protected)
        xMeans
        yMeans
        Bpls
    end
    
    methods
        
        function Obj = prtClassPlsda(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected)
        
        function Obj = trainAction(Obj,DataSet)
                                    
            X = DataSet.getObservations;
            if DataSet.nClasses > 2
                Y = DataSet.getTargetsAsBinaryMatrix;
            else
                Y = DataSet.getTargetsAsBinaryMatrix;
                Y = Y(:,2); %0's and 1's for H1
            end
            
            maxComps = min(size(X));
            if Obj.nComponents > maxComps;
                Obj.nComponents = maxComps;
            end
            
            Obj.xMeans = mean(X,1);
            Obj.yMeans = mean(Y,1);
            X = bsxfun(@minus, X, Obj.xMeans);
            Y = bsxfun(@minus, Y, Obj.yMeans);
            
            Obj.Bpls = prtUtilSimpls(X,Y,Obj.nComponents);
        end
        
        function DataSet = runAction(Obj,DataSet)
            yOut = bsxfun(@plus,DataSet.getObservations*Obj.Bpls, Obj.yMeans - Obj.xMeans*Obj.Bpls);
            DataSet = DataSet.setObservations(yOut);
        end
        
    end
    
end