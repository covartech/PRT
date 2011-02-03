classdef prtAlgorithm < prtAction
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
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'PRT Algorithm' % Prt Algorithm
        nameAbbreviation = 'ALGO';  % ALGO
    end
    
    properties (SetAccess=protected)
        isSupervised = true; % Set to true, but dependent on prtAction components
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
            
            %Set the internal action cell correctly
            Obj.internalActionCell = aCell;
        end
        
        function actionCell = get.actionCell(Obj)
            actionCell = Obj.internalActionCell;
        end
    end
    
    properties (SetAccess=protected)
        internalActionCell = {};
        connectivityMatrix = [];
    end
    
    methods (Hidden = true)
        function dataSet = updateDataSetFeatureNames(obj,dataSet) %#ok<MANU>
            %Algorithms do not have to do this; since they are composed of
            %class objects, we can just rely on the dataSet to have the
            %right feature names already.
            
            %At least this is true for single-stream Algorithms
        end
    end
    
    methods
        
        function plot(Obj)
            % Plots a block diagram of the algorithm 
            % Requires graphviz
            prtPlotUtilAlgorithmGui(Obj.connectivityMatrix, Obj.actionCell);
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
                
                % Set inputClass & outputClass
                keyboard
                
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
                
                tempNewConn = zeros(size(newConn)+2);
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
            % One input is a constructor from another prtAction
            
            % As an action subclass we must set the properties to reflect
            % our dataset requirements
            % Because we are an algorithm we actually don't know the
            % answers, we will figure these out in get
            if nargin == 1
                assert(isa(varargin{1},'prtAction'),'prtAlgorithm constructor requires a prtAction input');
                Obj.connectivityMatrix = false(3);
                Obj.connectivityMatrix(2,1) = true;
                Obj.connectivityMatrix(3,2) = true;
                Obj.actionCell = varargin(1);
                Obj.isSupervised = varargin{1}.isSupervised;
                
                Obj.classInput = varargin{1}.getClassInput;
                Obj.classOutput = varargin{1}.getClassOutput;
                Obj.classInputOutputRetained = varargin{1}.classInputOutputRetained;
            end
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj,DataSet)
            
            topoOrder = prtUtilTopographicalSort(Obj.connectivityMatrix');
            input = cell(size(Obj.connectivityMatrix,1),1);
            input{1} = DataSet;
            
            for i = 2:length(topoOrder)-1
                currentInput = catFeatures(input{Obj.connectivityMatrix(i,:)});
                Obj.actionCell{i-1}.verboseStorage = Obj.verboseStorage;
                Obj.actionCell{i-1} = train(Obj.actionCell{i-1},currentInput);
                input{i} = runOnTrainingData(Obj.actionCell{i-1},currentInput);
                
                %Fixed by having runOnTrainingData call postRunProcessing
                %input{i} = input{i}.setTargets(input{1}.getTargets);
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            topoOrder = prtUtilTopographicalSort(Obj.connectivityMatrix');
            input = cell(size(Obj.connectivityMatrix,1),1);
            input{1} = DataSet;
            
            for i = 2:length(topoOrder)-1
                currentInput = catFeatures(input{Obj.connectivityMatrix(i,:)});
                input{i} = run(Obj.actionCell{i-1},currentInput);
            end
            finalNodes = any(Obj.connectivityMatrix(Obj.outputNodes,:),1);
            DataSet = catFeatures(input{finalNodes});
        end
        
    end
    
    methods (Static)
        function plotHelper(actionObj)
            figure
            plot(actionObj)
        end
    end
    
end