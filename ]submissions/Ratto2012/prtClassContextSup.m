classdef prtClassContextSup < prtClass
    % prtClassContextGen Supervised context-dependent
    % classification
    %
    %   CLASSIFIER = prtClassContextSup returns a supervised
    %   context-dependent classifier
    %
    %   CLASSIFIER = prtClassContextSup(PROPERTY1, VALUE1, ...) constructs a
    %   prtClassContextDiscrim object CLASSIFIER with properties as specified by
    %   PROPERTY/VALUE pairs.
    %
    %   A prtClassContextSup object inherits all properties from the abstract class
    %   prtClass. In addition is has the following properties:
    %
    %
    %   A prtClassContextSup also has the following read-only properties:
    %

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


    properties (SetAccess=private)
        name = 'Context-Dependent Classification (Supervised)'
        nameAbbreviation = 'CDC-Sup';
        isNativeMary = false;
    end
    
    properties
        contextModel = prtClassMap;
        classModel = prtClassRvmForContext;
    end
    
    
    methods
        
        function Obj = prtClassContextSup(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        
        function Obj = set.contextModel(Obj,val)
            if ~isa(val,'prtClass') || ~any(cat(1,[],val.isNativeMary))
                error('prt:prtClassContextGen:contextModel','Context model must be a prtClass that is native M-ary capable.');
            end
            Obj.contextModel = val;
        end
        
         function Obj = set.classModel(Obj,val)
            if ~isa(val,'prtClass')
                error('prt:prtClassContextClass:classModel','Class model must be a prtClass.');
            end
            Obj.classModel = val;
        end       
        
        function varargout = plot(Obj)
            %             % plot - Plot output confidence of the prtClassContextDiscrim object
            %             %
            %             %   CLASS.plot plots the output confidence of the prtClassContextDiscrim
            %             %   object. The dimensionality of the dataset must be 3 or
            %             %   less, and verboseStorage must be true.
            %
            HandleStructure = plot@prtClass(Obj);
            
            subplot(2,1,1)
            plot(Obj.contextModel)
            subplot(2,1,2)
            plot(Obj.classModel)
            
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
        
    end
    
    
    methods (Access=protected, Hidden = true)
        
        %% Training
        function Obj = trainAction(Obj,dataSetContext)
            dsContext = dataSetContext.getContextDataSet;
            dsClass = dataSetContext.getTargetDataSet;
            
            Obj.contextModel = Obj.contextModel.train(dsContext);
            nContexts = dsContext.nClasses;
            Obj.classModel = repmat(Obj.classModel,1,nContexts);
            for i = 1:nContexts
                contextInds = dsContext.Y == i;
                Obj.classModel(i) = Obj.classModel(i).train(dsClass.retainObservations(contextInds));
            end
        end
        
        
        function dataSetOut = runAction(Obj,dataSetContext)
            dsContext = dataSetContext.getContextDataSet;
            dsClass = dataSetContext.getTargetDataSet;
            
            dsOutContext = Obj.contextModel.run(dsContext);
            pCgivenX = dsOutContext.X;
            
            nContexts = Obj.contextModel.dataSet.nClasses;
            nObservations = dataSetContext.nObservations;
            pH1givenXC = zeros(nObservations,nContexts);
            for i = 1:nContexts
                dsOutClass = Obj.classModel(i).run(dsClass);
                pH1givenXC(:,i) = dsOutClass.X;
            end
            
            pH1givenX = sum(pCgivenX.*pH1givenXC,2);
            dsConf = prtDataSetClass(pH1givenX,dataSetContext.Y);
            dsDummy = prtDataSetClass;
            dataSetOut = prtDataSetClassContext(dsConf,dsDummy);
        end
    end

end
