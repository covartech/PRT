classdef prtPreProcLda < prtPreProcClass
    % prtPreProcLda  Linear discriminant analysis processing
    %
    %   preProc = prtPreProcLda creates a linear discriminant pre
    %   processing object. A prtPreProcLda object projects the input data
    %   onto a linear space that best separates class labels
    %
    %   A prtPreProcLda object has the following properties:
    %
    %   nComponents - The number of dimensions to project the data onto.
    %                 This must less than or equal to the input data's
    %                 number of features, and less than or equal to the 
    %                 input data sets number of classes.
    %
    %   A prtPreProcLda object also inherits all properties and functions from
    %   the prtAction class
    %
    %   More information about LDA can be found at the following URL:
    %   http://en.wikipedia.org/wiki/Linear_discriminant_analysis
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;               % Load a dataset
    %   dataSet = dataSet.retainFeatures(1:3);  % Retain the first 3 features
    %   lda = prtPreProcLda;                    % Create the pre-processor
    %
    %   lda = lda.train(dataSet);               % Train
    %   dataSetNew = lda.run(dataSet);          % Run
    %
    %   % Plot the results
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Data');
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('LDA Projected Data');
    %
    %   See Also: prtPreProc, prtPreProcPca, prtPreProcPls,
    %   prtPreProcHistEq, prtPreProcZeroMeanColumns, prtPreProcLda,
    %   prtPreProcZeroMeanRows, prtPreProcLogDisc, prtPreProcZmuv,
    %   prtPreProcMinMaxRows







    properties (SetAccess=private)
        name = 'Linear discriminant analysis' % Linear discriminant analysis
        nameAbbreviation = 'LDA' % LDA
    end
    
    properties
        nComponents = 2;   % The number of LDA components
    end
    properties (SetAccess=private)
        projectionMatrix = []; % The projection matrix
        globalMean = [];       % The global mean
    end
    
    methods
        
        % Allow for string, value pairs
        function Obj = prtPreProcLda(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
	end
    
	methods (Hidden = true)
        function featureNameModificationFunction = getFeatureNameModificationFunction(obj) %#ok<MANU>
            featureNameModificationFunction = prtUtilFeatureNameModificationFunctionHandleCreator('LDA Score #index#');
        end
	end
    
    methods
        function Obj = set.nComponents(Obj,nComp)
            if ~prtUtilIsPositiveScalarInteger(nComp)
                error('prt:prtPreProcPca','nComponents must be a positive scalar integer');
            end
            Obj.nComponents = nComp;
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj,DataSet)
            if Obj.nComponents > DataSet.nClasses
                error('prt:prtPreProcLda','Attempt to train LDA pre-processor with more components (%d) than unique classes in data set (%d)',Obj.nComponents,DataSet.nClasses);
            end
            [Obj.projectionMatrix,Obj.globalMean] = prtUtilLinearDiscriminantAnalysis(DataSet,Obj.nComponents);
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            X = DataSet.getObservations;
            X = bsxfun(@minus,X,Obj.globalMean);
            DataSet = DataSet.setObservations(X*Obj.projectionMatrix);
        end
        
    end
    
end
