classdef prtBlockContextDependentRvm < prtBlock
    
    properties
        nContexts = 4;
        contextClassifier
        dataClassifier
    end
    methods
        function Obj = prtBlockContextDependentRvm
            Obj.nInputs = 2;
            Obj.inputNames = {'Context Data Set','Data Set'};
            Obj.inputTypes = {'DataSet','DataSet'};
            
            Obj.nOutputs = 1;
            Obj.outputNames = {'Output Data Set'};
            Obj.outputTypes = {'DataSet'};
        end
        
        function Obj = train(Obj,contextDataSet,classifierDataSet)
            
            Obj.contextClassifier = train(prtClusterKmeans('nClusters',3),contextDataSet);
            contextYOut = Obj.contextClassifier.run(contextDataSet);
            
            contexts = contextYOut.getObservations;
            Obj.dataClassifier = repmat(prtClassRvm,size(contexts,2),1);
            for i = 1:size(contexts,2)
                currInd = find(contexts(:,i));
                ds = classifierDataSet.retainObservations(currInd);
                Obj.dataClassifier(i) = train(prtClassRvm,ds);
            end
        end
        
        function yOut = run(Obj,contextDataSet,classifierDataSet)
            
            contextYOut = Obj.contextClassifier.run(contextDataSet);
            contexts = contextYOut.getObservations;
            for i = 1:size(contexts,2)
                currInd = find(contexts(:,i));
                ds = classifierDataSet.retainObservations(currInd);
                currYOut = Obj.dataClassifier(i).run(ds);
                yOutMatrix(currInd,:) = currYOut.getObservations;
            end
            yOut = classifierDataSet;
            yOut = yOut.setObservations(yOutMatrix);
        end
        
        function varargout = drawBlock(varargin)
        end
    end
end