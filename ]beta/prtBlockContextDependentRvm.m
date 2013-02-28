classdef prtBlockContextDependentRvm < prtBlock

% Copyright (c) 2013 New Folder Consulting
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
