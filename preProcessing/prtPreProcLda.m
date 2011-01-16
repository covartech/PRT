classdef prtPreProcLda < prtPreProc
    % prtPreProcLda  Linear discriminant analysis processing
    %
    %   LDA = prtPreProcLda creates a linear discriminant pre
    %   processing object. A prtPreProcLda object projects the input data
    %   onto a linear space that best separates class labels
    % 
    %   prtPreProcLda has the following properties:
    %
    %   nComponents - The number of dimensions to project the data onto.
    %                 Must be <= ds.nFeatures, and <= ds.nClasses - 1
    %
    %   A prtPreProcHistEq object also inherits all properties and functions from
    %   the prtAction class
    %
    %   More information about LDA can be found at the following URL:
    %   http://en.wikipedia.org/wiki/Linear_discriminant_analysis
    % 
    %   Example:
    %
    %   dataSet = prtDataGenIris;     
    %   dataSet = dataSet.retainFeatures(1:3);
    %   lda = prtPreProcLda;           
    %                        
    %   lda = lda.train(dataSet);     
    %   dataSetNew = lda.run(dataSet);
    % 
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Data');
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('LDA Projected Data');
    %
        %   See Also: prtPreProc,
    %   prtOutlierRemoval,prtPreProcNstdOutlierRemove,
    %   prtOutlierRemovalMissingData,
    %   prtPreProcNstdOutlierRemoveTrainingOnly, prtOutlierRemovalNStd,
    %   prtPreProcPca, prtPreProcPls, prtPreProcHistEq,
    %   prtPreProcZeroMeanColumns, prtPreProcLda, prtPreProcZeroMeanRows,
    %   prtPreProcLogDisc, prtPreProcZmuv, prtPreProcMinMaxRows                    

    properties (SetAccess=private)
        % Required by prtAction
        name = 'Linear discriminant analysis'
        nameAbbreviation = 'LDA'
        isSupervised = true;
    end
    
    properties
        nComponents = 2;   % The number of LDA components
    end
    properties (SetAccess=private)
        % General Classifier Properties
        projectionMatrix = [];
        globalMean = [];
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtPreProcLda(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Hidden = true)
        function featureNames = updateFeatureNames(obj,featureNames) %#ok<MANU>
            for i = 1:length(featureNames)
                featureNames{i} = sprintf('LDA Score %d',i);
            end
        end
    end
    
    methods
        function Obj = set.nComponents(Obj,nComp)
            if ~isnumeric(nComp) || ~isscalar(nComp) || nComp < 1 || round(nComp) ~= nComp
                error('prt:prtPreProcPca','nComponents (%s) must be a positive scalar integer',mat2str(nComp));
            end
            Obj.nComponents = nComp;
        end
    end
    
    methods (Access = protected)
        
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