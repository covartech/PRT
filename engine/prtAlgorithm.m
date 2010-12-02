classdef prtAlgorithm < prtAction
    % xxx NEED HELP xxx
    %
    %  Algorithms represent combinations of prtActions.
    % 
    %
    properties (SetAccess=private)
        % Required by prtAction
        name = 'PRT Algorithm'
        nameAbbreviation = 'ALGO';
        isSupervised = true; % We say true even though we don't know
    end
    
    properties (SetAccess=protected)
        actionCell = {};
        connectivityMatrix = [];
    end
    
    methods (Hidden = true)
        function dataSet = updateDataSetFeatureNames(obj,dataSet) %#ok<MANU>
            %Algorithms do not have to do this; since they are composed of
            %class objects, we can just rely on the dataSet to have the
            %right feature names already.
            %At least this is true for sing-stream Algorithm
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
                
                Obj1.actionCell = cat(1,Obj1.actionCell(:),Obj2.actionCell(:));
                Obj1.connectivityMatrix = newConn;
                
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
                
                Obj1.actionCell = cat(1,Obj1.actionCell(:),Obj2.actionCell(:));
                Obj1.connectivityMatrix = newConn;
                
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
            if nargin == 1
                assert(isa(varargin{1},'prtAction'),'prtAlgorithm with 1 input requires a prtAction input');
                Obj.actionCell = varargin(1);
                Obj.connectivityMatrix = false(3);
                Obj.connectivityMatrix(2,1) = true;
                Obj.connectivityMatrix(3,2) = true;
            else
                Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            end
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            
            topoOrder = prtUtilTopographicalSort(Obj.connectivityMatrix');
            input = cell(size(Obj.connectivityMatrix,1),1);
            input{1} = DataSet;
            
            for i = 2:length(topoOrder)-1
                currentInput = catFeatures(input{Obj.connectivityMatrix(i,:)});
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