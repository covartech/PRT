classdef prtAlgorithm < prtAction & prtActionBig
    % prtAlgorithm  Combine prtActions 
    %
    %  ALG = prtAlgorithm creates an empty prtAlgorithm object. prtAction
    %  objects can be added to the prtAlgorithm object using overloaded
    %  operators as described below.
    %
    %  ALG = prtAlgorithm(ACTIONOBJ) creates a prtAlgorithm object with the
    %  prtAction object ACTIONOBJ. The algortihm can be further configured
    %  using overloaded operators.
    %
    %  Algorithms represent combinations of prtActions.
    % 
    %
    %  Overloaded operators
    % 
    %  +   Inserts a prtAction object at the end of the processing chain
    %
    %  -   Inserts a prtAction object at the beginning of the procesing chain
    %
    %  /   Inserts a prtAction object in parallel with the processing chain
    %
    %  \   Inserts a prtAction object in parallel with the processing
    %      chain. Note that operators \ and / perform the same operation. The
    %      only difference is where the actions are displayed when the
    %      prtAlgortihm is plotted.

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
        % Required by prtAction
        name = 'PRT Algorithm' % Prt Algorithm
        nameAbbreviation = 'ALGO';  % ALGO
    end
    
    properties (SetAccess=protected)
        isSupervised = true; % Default to true, but dependent on prtAction components
        isCrossValidateValid = true; % Default to true, but dependent on prtAction components
    end
    
    %This is the public face of the (protected) internalActionCell
    properties (Dependent)
        actionCell        
    end
    
    methods
        function Obj = set.actionCell(Obj,aCell)
           
            %Check is cell:
            if ~isa(aCell,'cell')
                error('prtAlgorithm:actionCell','prtAlgorithm''s actionCell must be a cell array');
            end
            %Check right size:
            if ~isvector(aCell)
                error('prtAlgorithm:actionCell','prtAlgorithm''s actionCell must be a vector cell array');
            end
            if length(aCell) ~= size(Obj.connectivityMatrix,1)-2
                error('prtAlgorithm:actionCell','Attempt to change a prtAlgorithm''s actionCell''s size.  actionCell must be a vector cell array of length(size(Obj.connectivityMatrix,1)-2)');
            end 
            %Check all prtActions:
            if ~all(cellfun(@(c)isa(c,'prtAction'),aCell))
                error('prtAlgorithm:actionCell','actionCell must be a vector cell array of prtActions')
            end
            
            for i = 1:length(aCell)
                if ~aCell{i}.classRunRetained
                    Obj.classRunRetained = false;
                    break;
                end
            end
            
            %Set the internal action cell correctly
            Obj.internalActionCell = aCell;
        end
        
        function actionCell = get.actionCell(Obj)
            actionCell = Obj.internalActionCell;
        end
    end
    
    properties (SetAccess=protected,GetAccess=protected,Hidden)
        internalActionCell = {};
    end
    properties (SetAccess=protected)
        connectivityMatrix = [];
    end
    
    methods (Hidden = true)
		
        function str = textSummary(self)
            str = '';
            for i = 1:length(self.actionCell)
                str = cat(2,str,self.actionCell{i}.textSummary);
            end
            str = strtrim(str);
        end
        function Obj = setVerboseStorage(Obj,val)
            assert(numel(val)==1 && (islogical(val) || (isnumeric(val) && (val==0 || val==1))),'prtAction:invalidVerboseStorage','verboseStorage must be a logical');
            Obj.verboseStorageInternal = logical(val);
            
            % Also set each actionCells
            for iAction = 1:length(Obj.actionCell)
                Obj.actionCell{iAction}.verboseStorage = val;
            end
        end
         
        function Obj = setShowProgressBar(Obj,val)
            if ~prtUtilIsLogicalScalar(val);
                error('prt:prtAction','showProgressBar must be a scalar logical.');
            end
            Obj.showProgressBarInternal = val;
            
            % Also set each actionCells
            for iAction = 1:length(Obj.actionCell)
                Obj.actionCell{iAction}.showProgressBar = val;
            end
        end
        
    end
    
    methods
        
        function plot(Obj)
            % Plots a block diagram of the algorithm 
            % Requires graphviz
            prtPlotUtilAlgorithmGui(Obj.connectivityMatrix, Obj.actionCell, Obj);
        end
        
        function in = inputNodes(Obj)
            in = all(Obj.connectivityMatrix == false,2);
            in = in(:);
        end
        function out = outputNodes(Obj)
            out = all(Obj.connectivityMatrix == false,1);
            out = out(:);
        end
        
        function Obj1 = plus(Obj1,Obj2)
            if ~isa(Obj2,'prtAlgorithm')
                Obj2 = prtAlgorithm(Obj2);
            end
            
            if isa(Obj2,'prtAlgorithm')

                in1 = Obj1.inputNodes;
                out1 = Obj1.outputNodes;
                
                tempCon1 = Obj1.connectivityMatrix;
                tempCon1 = tempCon1(~(in1|out1),~(in1|out1));
                
                in2 = Obj2.inputNodes;
                out2 = Obj2.outputNodes;
                
                tempCon2 = Obj2.connectivityMatrix;
                tempCon2 = tempCon2(~(in2|out2),~(in2|out2));
                
                tempOutput1 = cat(2,all(tempCon1 == 0,1),false(1,size(tempCon2,2)));
                tempInput2 = all(tempCon2 == 0,2);
                tempInput2 = cat(2,false(1,size(tempCon1,2)),tempInput2');
                
                newConn = prtUtilMatrixCornerCat(tempCon1,tempCon2,@false);
                newConn(tempInput2,tempOutput1) = true;
                
                newOutput = cat(2,false,all(newConn == 0,1),false);
                newInput = cat(2,false,all(newConn == 0,2)',false);
                
                tempNewConn = false(size(newConn)+2);
                tempNewConn(2:end-1,2:end-1) = newConn;
                newConn = tempNewConn;
                
                newConn(newInput,1) = true;
                newConn(end,newOutput) = true;
                
                Obj1.connectivityMatrix = newConn;
                Obj1.actionCell = cat(1,Obj1.actionCell(:),Obj2.actionCell(:));
                
                Obj1.isSupervised = any(cellfun(@(c)c.isSupervised,Obj1.actionCell));
                Obj1.isCrossValidateValid = all(cellfun(@(c)c.isCrossValidateValid,Obj1.actionCell));
                Obj1.isTrained = all(cellfun(@(c)c.isTrained,Obj1.actionCell));
            else
                error('prt:prtAlgorithm:plus','prtAlgorithm.plus is only defined for second inputs of type prtAlgorithm or prtAction, but the second input is a %s',class(Obj2));
            end
        end
        
        %this should be HIDDEN
        function Obj1 = minus(Obj1,Obj2)
            if ~isa(Obj2,'prtAlgorithm')
                Obj2 = prtAlgorithm(Obj2);
            end
            Obj1 = Obj2 + Obj1;
        end
        
        function Obj1 = mrdivide(Obj1,Obj2)
            if ~isa(Obj2,'prtAlgorithm')
                Obj2 = prtAlgorithm(Obj2);
            end
            
            if isa(Obj2,'prtAlgorithm')
                
                in1 = Obj1.inputNodes;
                out1 = Obj1.outputNodes;
                
                tempCon1 = Obj1.connectivityMatrix;
                tempCon1 = tempCon1(~(in1|out1),~(in1|out1));
                
                in2 = Obj2.inputNodes;
                out2 = Obj2.outputNodes;
                
                tempCon2 = Obj2.connectivityMatrix;
                tempCon2 = tempCon2(~(in2|out2),~(in2|out2));
                
                newConn = prtUtilMatrixCornerCat(tempCon1,tempCon2,@false);
                
                newOutput = cat(2,false,all(newConn == 0,1),false);
                newInput = cat(2,false,all(newConn == 0,2)',false);
                
                tempNewConn = false(size(newConn)+2);
                tempNewConn(2:end-1,2:end-1) = newConn;
                newConn = tempNewConn;
                
                newConn(newInput,1) = true;
                newConn(end,newOutput) = true;
                
                Obj1.connectivityMatrix = newConn;
                Obj1.actionCell = cat(1,Obj1.actionCell(:),Obj2.actionCell(:));
                
                Obj1.isSupervised = any(cellfun(@(c)c.isSupervised,Obj1.actionCell));
                Obj1.isCrossValidateValid = all(cellfun(@(c)c.isCrossValidateValid,Obj1.actionCell));
            else
                error('prt:prtAlgorithm:plus','prtAlgorithm.plus is only defined for second inputs of type prtAlgorithm or prtAction, but the second input is a %s',class(Obj2));
            end
            
        end
        
        %this should be hidden
        function Obj1 = mldivide(Obj1,Obj2)
            if ~isa(Obj2,'prtAlgorithm')
                if isa(Obj2,'prtAction') || all(cellfun(@(x)isa(x,'prtAction'),{prtPreProcPca,1}))
                    Obj2 = prtAlgorithm(Obj2);
                end
            end
            if isa(Obj2,'prtAlgorithm')
                Obj1 = Obj2 / Obj1;
            else
                error('prt:prtAlgorithm:mrdivide','prtAlgorithm.mrdivide is only defined for second inputs of type prtAlgorithm or prtAction, but the second input is a %s',class(in2));
            end
        end
        
        function Obj = prtAlgorithm(varargin)
            
            Obj.classTrain = '';
            Obj.classRun = '';
            Obj.classRunRetained = true;
            
            % One input is a constructor from another prtAction
            if nargin == 1
                assert(isa(varargin{1},'prtAction'),'prtAlgorithm constructor requires a prtAction input');
                Obj.connectivityMatrix = false(3);
                Obj.connectivityMatrix(2,1) = true;
                Obj.connectivityMatrix(3,2) = true;
                Obj.actionCell = varargin(1);
                Obj.isSupervised = varargin{1}.isSupervised;
            end
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj,DataSet)
            
            topoOrder = prtUtilTopographicalSort(Obj.connectivityMatrix');
            input = cell(size(Obj.connectivityMatrix,1),1);
            input{1} = DataSet;
            
            for i = 2:length(topoOrder)-1
                
                %Note: added this to fix catFeatures problems with data
                %sets that don't have catFeatures; they can still work in
                %"flat" algorithms.  See bug report on github and in
                %runAction
                inDataSets = find(Obj.connectivityMatrix(topoOrder(i),:));
                if length(inDataSets) == 1
                    currentInput = input{inDataSets};
                else
                    currentInput = catFeatures(input{Obj.connectivityMatrix(topoOrder(i),:)});
                end
                %keyboard
                Obj.actionCell{topoOrder(i-1)}.verboseStorage = Obj.verboseStorage;
                Obj.actionCell{topoOrder(i-1)} = train(Obj.actionCell{topoOrder(i-1)},currentInput);
                
                %Don't run the action if there are no other prtActions
                %(besides outputNodes) that rely on the output.
                
                outputDependentActions = find(Obj.connectivityMatrix(:,topoOrder(i)));
                if ~all(ismember(outputDependentActions,find(outputNodes(Obj))))
                    %fprintf('running %s\n',class(Obj.actionCell{topoOrder(i-1)}));
                    input{topoOrder(i)} = runOnTrainingData(Obj.actionCell{topoOrder(i-1)},currentInput);
                else
                    %fprintf('not running %s\n',class(Obj.actionCell{topoOrder(i-1)}));
                end
                
            end
        end
        
        function Obj = trainActionBig(Obj,DataSet)
            
            topoOrder = prtUtilTopographicalSort(Obj.connectivityMatrix');
            input = cell(size(Obj.connectivityMatrix,1),1);
            input{1} = DataSet;
            
            for i = 2:length(topoOrder)-1
                
                %Note: added this to fix catFeatures problems with data
                %sets that don't have catFeatures; they can still work in
                %"flat" algorithms.  See bug report on github and in
                %runAction
                inDataSets = find(Obj.connectivityMatrix(topoOrder(i),:));
                if length(inDataSets) == 1
                    currentInput = input{inDataSets};
                else
                    error('Only serial prtAlgorithms can be trained using big data'); % This is the first line that is different than trainAction
                    currentInput = catFeatures(input{Obj.connectivityMatrix(topoOrder(i),:)});
                end
                %keyboard
                Obj.actionCell{topoOrder(i-1)}.verboseStorage = Obj.verboseStorage;
                Obj.actionCell{topoOrder(i-1)} = trainBig(Obj.actionCell{topoOrder(i-1)},currentInput); % This is the second line that is different than trainAction
                
                %Don't run the action if there are no other prtActions
                %(besides outputNodes) that rely on the output.
                
                outputDependentActions = find(Obj.connectivityMatrix(:,topoOrder(i)));
                if ~all(ismember(outputDependentActions,find(outputNodes(Obj))))
                    %fprintf('running %s\n',class(Obj.actionCell{topoOrder(i-1)}));
                    input{topoOrder(i)} = runBig(Obj.actionCell{topoOrder(i-1)},currentInput); % This is the third line that is different than trainAction
                else
                    %fprintf('not running %s\n',class(Obj.actionCell{topoOrder(i-1)}));
                end
                
            end
        end
        
        
        
        function [DataSet, input] = runAction(Obj,DataSet)
            
            topoOrder = prtUtilTopographicalSort(Obj.connectivityMatrix');
            input = cell(size(Obj.connectivityMatrix,1),1);
            input{1} = DataSet;
            
            for i = 2:length(topoOrder)-1
                %Note: added this to fix catFeatures problems with data
                %sets that don't have catFeatures; they can still work in
                %"flat" algorithms.  See bug report on github, and in
                %trainAction
                inDataSets = find(Obj.connectivityMatrix(topoOrder(i),:));
                if length(inDataSets) == 1
                    currentInput = input{inDataSets};
                else
                    currentInput = catFeatures(input{Obj.connectivityMatrix(topoOrder(i),:)});
                end
                input{topoOrder(i)} = run(Obj.actionCell{topoOrder(i-1)},currentInput);
            end
            finalNodes = any(Obj.connectivityMatrix(Obj.outputNodes,:),1);
            DataSet = catFeatures(input{finalNodes});
        end
        
        function xOut = runActionFast(Obj,xIn,ds) %#ok<INUSD>
            
            if nargin > 2
                error('prt:prtAlgorithm:runActionFast','prtAlgorithm.runFast cannot currently take the input argument ds');
            end
            
            topoOrder = prtUtilTopographicalSort(Obj.connectivityMatrix');
            input = cell(size(Obj.connectivityMatrix,1),1);
            input{1} = xIn;
            
            for i = 2:length(topoOrder)-1
                currentInput = cat(2,input{Obj.connectivityMatrix(topoOrder(i),:)});
                input{topoOrder(i)} = runFast(Obj.actionCell{topoOrder(i-1)},currentInput);
            end
            finalNodes = any(Obj.connectivityMatrix(Obj.outputNodes,:),1);
            xOut = cat(2,input{finalNodes});
        end
    end
    
    methods (Static)
        function plotHelper(actionObj)
            figure
            plot(actionObj)
        end
    end

    methods (Hidden)
        
        function str = exportSimpleText(self) %#ok<MANU>
            str = '';
            for i = 1:length(self.actionCell)
                str = sprintf('%s\n%s',str,self.actionCell{i}.exportSimpleText);
            end
        end
        function plotAsClassifier(self)
            % plotAsClassifier(self)
            %   Plot an algorithm as though it were a classifier - e.g.,
            %   build the decision surface and visualize it.  Valid for
            %   algorithms trained with data sets with 3 or fewer features,
            %   and when the *very last* action is a prtClass.
            %
            % e.g.
            %   ds = prtDataGenBimodal;
            %   algoKmeans = prtPreProcKmeans('nClusters',4) + prtClassLogisticDiscriminant;
            %   algoKmeans = train(algoKmeans,ds);
            %   algoKmeans.plotAsClassifier;
            
            if isPlottableAsClassifier(self)
                plot(prtUtilClassAlgorithmWrapper('trainedAlgorithm',self));
            else
                error('prt:prtAlgorithm:plotAsClassifier','This prtAlgorithm cannot be plotted as a classifier');
            end
        end
        function tf = isPlottableAsClassifier(self)
            
            tf = false;
            if isempty(self.dataSetSummary)
                return
            end
            
            if self.dataSetSummary.nFeatures <= 3
                if sum(self.outputNodes)==1
                    lastNodes = self.connectivityMatrix(find(self.outputNodes,1,'first'),:);
                    if sum(lastNodes)==1
                        if isa(self.actionCell{find(lastNodes,1,'first')-1},'prtClass')
                            tf = true;
                        end
                    end
                end
            end
        end
        
        
        function [optimizedAlgorithm,performance] = optimize(Obj,DataSet,objFn,tag,parameterName,parameterValues)
            % OPTIMIZE Optimize action parameter by exhaustive function maximization. 
            %
            % [optimizedAlgorithm,performance] = optimize(Obj,DataSet,objFn,tag,parameterName,parameterValues)
            %
            % A prtActions within the algorithm is identified using either
            % the nameAbbreviation property or the tag property. 
            % The nameAbbreviation property takes presidence. If there are
            % multiple matches or no matches the tag preperty is
            % investigated, if there are still multiple matches or no
            % matches an error is thrown.
            %
            % Although functional this method is currently hidden.
            %
            % Examples:
            %   % Simple finding by nameAbbreviation
            %   ds = prtDataGenFeatureSelection;
            %   algo = prtPreProcZmuv + prtClassPlsda + prtClassLogisticDiscriminant;
            %   objFn = @(act,ds)prtEvalAuc(act,ds,3);
            %   [optimizedAlgorithm, performance] = optimize(algo,ds,objFn,'plsda','nComponents',2:10);
            %
            %   % Finding by tag
            %   ds = prtDataGenFeatureSelection;
            %   algo = prtPreProcZmuv('tag','asdf') + prtClassPlsda('tag','qwer') + prtClassLogisticDiscriminant('tag','zxcv');
            %   objFn = @(act,ds)prtEvalAuc(act,ds,25);
            %   [optimizedAlgorithm, performance] = optimize(algo,ds,objFn,'qwer','nComponents',2:30);
            
            if isnumeric(parameterValues) || islogical(parameterValues)
                parameterValues = num2cell(parameterValues);
            end
            performance = nan(length(parameterValues),1);
            
            %%%%%%%%
            %%%%%%%% Figure out what action we are talking about
            %%%%%%%%
            % First try to find using abbreviation
            actionAbbrevs = cellfun(@(c)c.nameAbbreviation,Obj.actionCell,'uniformOutput',false);
            
            actionCellInds = find(cellfun(@(c)~isempty(c),strfind(lower(actionAbbrevs),lower(tag))));
            if isempty(actionCellInds)
                % Cannot use simple tag mode, cant find it
                useRealTags = true;
            elseif length(actionCellInds) == 1
                actionCellInd = actionCellInds;
                useRealTags = false;
            else
                % Cannot use simple tag mode, we have used some actions
                % more than once
                useRealTags = true;
            end
            
            % Unsucessful based on tag
            if useRealTags 
                tags = cellfun(@(c)c.tag,Obj.actionCell,'uniformOutput',false);
                
                tagCellInds = find(cellfun(@(c)~isempty(c),strfind(lower(tags),lower(tag))));
                if isempty(tagCellInds)
                    if isempty(actionCellInds)
                        error('prt:prtAlgorithm:optimize','Could not find a prtAction within this prtAlgorithm with a tag or a nameAbbreviation that matches %s.',tag);
                    else
                        error('prt:prtAlgorithm:optimize','Multiple prtActions fitting the nameAbbreviation %s exist within this prtAlgorithm therefore acronym tagging cannot be used. There are no prtActions within this prtAlgorithm with the tag %s.',tag,tag);
                    end
                elseif length(tagCellInds) == 1
                    actionCellInd = tagCellInds;
                else
                    if isempty(actionCellInds)
                        error('prt:prtAlgorithm:optimize','Could not find a prtAction within this prtAlgorithm with a nameAbbreviation that matches %s but there are multiple prtActions that match the tag %s',tag);
                    else
                        error('prt:prtAlgorithm:optimize','The tag %s is not specific enough to identify a single prtAction within this prtAlgorithm.',tag);
                    end
                end
            end
            %%%%%%%%
            %%%%%%%%
            
            
            % Optimize
            if Obj.showProgressBar
                h = prtUtilProgressBar(0,sprintf('Optimizing %s.%s',class(Obj),parameterName),'autoClose',true);
            end
            
            for i = 1:length(performance)
                Obj.actionCell{actionCellInd}.(parameterName) = parameterValues{i};
                performance(i) = objFn(Obj,DataSet);
                h.update(i/length(performance));
            end
            if Obj.showProgressBar
                % Force close
                h.update(1);
            end
            
            [maxPerformance,maxPerformanceInd] = max(performance); %#ok<ASGLU>
            Obj.actionCell{actionCellInd}.(parameterName) = parameterValues{maxPerformanceInd};
            optimizedAlgorithm = train(Obj,DataSet);
            
        end
    end   
end
