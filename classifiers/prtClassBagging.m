classdef prtClassBagging < prtClass
    %     % prtClassFld Properties:
    %     %   name - Fisher Linear Discriminant
    %     %   nameAbbreviation - FLD
    %     %   isSupervised - true
    %     %   isNativeMary - false
    %     %   w - regression weights - estimated during training
    %     %   plotBasis - logical, plot the basis
    %     %   plotProjections - logical, plot projections of points to basis
    %     %
    %     % prtClassFld Methods:

    properties (SetAccess=private)
        % Required by prtAction
        name = 'Bagging Classifier'
        nameAbbreviation = 'Bagging'
        isSupervised = true;
        
        % Required by prtClass
        isNativeMary = false;
    end
    
    properties
        % Note: Set the set.prtClassifier to check if it's an action, and
        % also check if it's supervised, and also check if it's native M-ary
        prtClassifier = prtClassFld;
        nBags = 100;
    end
    properties (SetAccess=protected)
        Classifiers
    end
    
    methods
        
        function Obj = prtClassBagging(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected)
        
        function Obj = trainAction(Obj,DataSet)

            for i = 1:Obj.nBags
                if i == 1
                    Obj.Classifiers = train(Obj.prtClassifier,DataSet.bootstrap(DataSet.nObservations));
                else
                    Obj.Classifiers(i) = train(Obj.prtClassifier,DataSet.bootstrap(DataSet.nObservations));
                end
            end
        end
        
        function yOut = runAction(Obj,DataSet)
            yOut = DataSet;
            for i = 1:Obj.nBags
                Results = run(Obj.Classifiers(i),DataSet);
                if i == 1
                    yOut = yOut.setObservations(Results.getObservations);
                else
                    yOut = yOut.setObservations(yOut.getObservations + Results.getObservations);
                end
            end
            yOut = yOut.setObservations(yOut.getObservations./Obj.nBags);
        end
        
    end
    
end