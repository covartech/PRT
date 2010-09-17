classdef prtAlgorithm < prtAction
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'PRT Algorithm'
        nameAbbreviation = 'ALGO';
        isSupervised = true; % We say true even though we don't know
    end
    
    properties
        actionCell = {};
        connectivityMatrix = [];
    end
    
    
    methods (Hidden = true)
        function dataSet = updateDataSetFeatureNames(obj,dataSet)
            %Algorithms do not have to do this; since they are composed of
            %class objects, we can just rely on the dataSet to have the
            %right feature names already.
            %At least this is true for sing-stream Algorithm
        end
    end
    
    methods
        
        function in = inputNodes(Obj)
            in = all(Obj.connectivityMatrix == 0,2);
            in = in(:);
        end
        function out = outputNodes(Obj)
            out = all(Obj.connectivityMatrix == 0,1);
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
                
                tempNewConn = zeros(size(newConn)+2);
                tempNewConn(2:end-1,2:end-1) = newConn;
                newConn = tempNewConn;
                
                newConn(newInput,1) = true;
                newConn(end,newOutput) = true;
                
                Obj1.actionCell = cat(1,Obj1.actionCell(:),Obj2.actionCell(:));
                Obj1.connectivityMatrix = newConn;
                
            else
                error('prt:prtAlgorithm:plus','prtAlgorithm.plus is only defined for second inputs of type prtAlgorithm or prtAction, but the second input is a %s',class(in2));
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
                
                tempOutput1 = cat(2,all(tempCon1 == 0,1),false(1,size(tempCon2,2)));
                tempInput2 = all(tempCon2 == 0,2);
                tempInput2 = cat(2,false(1,size(tempCon1,2)),tempInput2');
                %
                %                 tempInput2 = cat(2,false,tempInput2,false);
                %                 tempOutput1 = cat(2,false,tempOutput1,false);
                %
                newConn = prtUtilMatrixCornerCat(tempCon1,tempCon2,@false);
                % newConn(tempInput2,tempOutput1) = true;
                
                newOutput = cat(2,false,all(newConn == 0,1),false);
                newInput = cat(2,false,all(newConn == 0,2)',false);
                
                tempNewConn = zeros(size(newConn)+2);
                tempNewConn(2:end-1,2:end-1) = newConn;
                newConn = tempNewConn;
                
                newConn(newInput,1) = true;
                newConn(end,newOutput) = true;
                
                Obj1.actionCell = cat(1,Obj1.actionCell(:),Obj2.actionCell(:));
                Obj1.connectivityMatrix = newConn;
                
            else
                error('prt:prtAlgorithm:plus','prtAlgorithm.plus is only defined for second inputs of type prtAlgorithm or prtAction, but the second input is a %s',class(in2));
            end
        end
        
        %this should be hidden
        function Obj1 = mldivide(Obj1,Obj2)
            if ~isa(Obj2,'prtAlgorithm')
                Obj2 = prtAlgorithm(Obj2);
            end
            if isa(Obj2,'prtAlgorithm')
                Obj1 = Obj2 / Obj1;
            else
                error('prt:prtAlgorithm:mrdivide','prtAlgorithm.mrdivide is only defined for second inputs of type prtAlgorithm or prtAction, but the second input is a %s',class(in2));
            end
        end
        
        function Obj = prtAlgorithm(varargin)
            if nargin == 0
                return
            end
            if isa(varargin{1},'prtAction');
                varargin{1} = {varargin{1}};
            end
            Obj.actionCell = varargin{1};
            Obj.connectivityMatrix = zeros(length(Obj.actionCell)+2);
            for i = 2:length(Obj.actionCell)+1
                Obj.connectivityMatrix(i,i-1) = 1;
            end
            terminalNodes = find(all(Obj.connectivityMatrix(:,1:end-1) == 0));
            Obj.connectivityMatrix(end,terminalNodes) = 1;
            
            if nargin > 1
                extraInputs = varargin(2:end);
                Obj = prtUtilAssignStringValuePairs(Obj,extraInputs{:});
            end
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            
            for iAction = 1:length(Obj.actionCell)
                %keyboard; %this is bbbbad
                if iscell(Obj.actionCell{iAction})
                    % Parallel
                    %newAlgo = prtAlgorithm
                    for jAction = 1:length(Obj.actionCell{iAction})
                        if ~iscell(Obj.actionCell{iAction}{jAction})
                            Obj.actionCell{iAction}{jAction}.verboseStorage = Obj.verboseStorage;
                            tempAlgorithm = Obj.actionCell{iAction}{jAction};
                        else
                            tempAlgorithm = prtAlgorithm(Obj.actionCell{iAction}{jAction});
                        end
                        %                         Obj.actionCell{iAction}{jAction} = train(Obj.actionCell{iAction}{jAction}, DataSet);
                        %                         ijDataSets{jAction} = run(Obj.actionCell{iAction}{jAction}, DataSet);
                        Obj.actionCell{iAction}{jAction} = train(tempAlgorithm, DataSet);
                        ijDataSets{jAction} = run(Obj.actionCell{iAction}{jAction}, DataSet);
                        
                    end
                    DataSetOut = catFeatures(ijDataSets{:});
                    DataSet = DataSet.setObservations(DataSetOut.getObservations());
                elseif isa(Obj.actionCell{iAction},'prtAction')
                    %Serial
                    Obj.actionCell{iAction}.verboseStorage = Obj.verboseStorage;
                    Obj.actionCell{iAction} = train(Obj.actionCell{iAction},DataSet);
                    
                    DataSetOut = run(Obj.actionCell{iAction},DataSet);
                    
                    DataSet = DataSet.setObservations(DataSetOut.getObservations());
                    
                else
                    error('prt:prtAlgorithm:trainAction:invalidInput','Invalid prtAction.')
                end
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            for iAction = 1:length(Obj.actionCell)
                if iscell(Obj.actionCell{iAction})
                    % Parallel
                    for jAction = 1:length(Obj.actionCell{iAction})
                        ijDataSets{jAction} = run(Obj.actionCell{iAction}{jAction}, DataSet);
                    end
                    DataSetOut = catFeatures(ijDataSets{:});
                    DataSet = DataSet.setObservations(DataSetOut.getObservations());
                elseif isa(Obj.actionCell{iAction},'prtAction')
                    % Serial
                    DataSet = run(Obj.actionCell{iAction},DataSet);
                else
                    error('prt:prtAlgorithm:trainAction:invalidInput','Invalid prtAction.')
                end
            end
        end
        
    end
    
end