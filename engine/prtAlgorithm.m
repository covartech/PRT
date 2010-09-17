classdef prtAlgorithm < prtAction
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'PRT Algorithm'
        nameAbbreviation = 'ALGO';
        isSupervised = true; % We say true even though we don't know
    end
    
    properties
        actionCell = {};
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
        
        function in1 = plus(in1,in2)
            if isa(in2,'prtAlgorithm')
                in1.actionCell = cat(1,in1.actionCell(:),in2.actionCell(:))';
            elseif isa(in2,'prtAction')
                in1.actionCell = cat(1,in1.actionCell(:),{in2})';
            else
                error('prt:prtAlgorithm:plus','prtAlgorithm.plus is only defined for second inputs of type prtAlgorithm or prtAction, but the second input is a %s',class(in2));
            end
        end
        
        %this should be HIDDEN
        function in1 = minus(in1,in2)
            if isa(in2,'prtAlgorithm')
                in1.actionCell = cat(1,in2.actionCell(:),in1.actionCell(:))';
            elseif isa(in2,'prtAction')
                in1.actionCell = cat(1,{in2},in1.actionCell(:))';
            else
                error('prt:prtAlgorithm:plus','prtAlgorithm.plus is only defined for second inputs of type prtAlgorithm or prtAction, but the second input is a %s',class(in2));
            end
        end
        
        %Hidden?
        function algoLen = getLength(Obj)
            algoLen = 0;
            for i = 1:size(Obj.actionCell,2)
                if ~iscell(Obj.actionCell{i})
                    algoLen = algoLen+1;
                else
                    maxLen = 0;
                    for j = 1:length(Obj.actionCell{i})
                        tempAlgo = prtAlgorithm(Obj.actionCell{i}{j});
                        tempLen = tempAlgo.getLength;
                        if tempLen > maxLen
                            maxLen = tempLen;
                        end
                    end
                    algoLen = algoLen + maxLen;
                end
            end
        end
        
        %Hidden?
        function algoHeight = getHeight(Obj)
            algoHeight = 0;
            for i = 1:size(Obj.actionCell,2)
                tempAlgoHeight = 0;
                if ~iscell(Obj.actionCell{i})
                    tempAlgoHeight = 1;
                else
                    for j = 1:size(Obj.actionCell{i},2)
                        if iscell(Obj.actionCell{i}{j})
                            tempAlgo = prtAlgorithm(Obj.actionCell{i}{j});
                            tempAlgoHeight = tempAlgoHeight + tempAlgo.getHeight + 1;
                        else
                            tempAlgoHeight = 1;
                        end
                    end
                end
                if tempAlgoHeight > algoHeight
                    algoHeight = tempAlgoHeight;
                end
            end
        end
        
        %hidden / broken
        %         function algoNesting = getNesting(Obj)
        %             algoNesting = 0;
        %             for i = 1:size(Obj.actionCell,2)
        %                 tempAlgoNesting = 0;
        %                 if iscell(Obj.actionCell{i})
        %                     tempAlgoNesting = 1;
        %                     for j = 1:length(Obj.actionCell{i})
        %                         tempAlgo = prtAlgorithm(Obj.actionCell{i}{j});
        %                         tempAlgoNesting = tempAlgoNesting + tempAlgo.getNesting;
        %                     end
        %                     if tempAlgoNesting > algoNesting
        %                         algoNesting = tempAlgoNesting;
        %                     end
        %                 end
        %             end
        %         end
        
        function [g,pi,pj] = toCellArray(Obj,parentI,parentJ)
            
            h = Obj.getHeight;
            l = Obj.getLength;
            g = cell(h,l);
            
            if nargin < 3
                parentI = 0;
                parentJ = 0;
            end
            pi = nan(size(g)); %not 3.1415
            pj = nan(size(g));
            
            if ~mod(h,2)
                c = h/2;
            else
                c = ceil(h/2);
            end
            
            %             error('calculating the parents is.. busted');
            cellI = 1;
            parentJ = c;
            for i = 1:size(Obj.actionCell,2)
                if ~isa(Obj.actionCell{i},'cell')
                    g{c,cellI} = Obj.actionCell{i}.nameAbbreviation;
                    pi(c,cellI) = cellI-1;
                    pj(c,cellI) = c;
                    parentJ = c;
                    cellI = cellI + 1;
                else
                    
                    maxLen = 1;
                    for j = 1:length(Obj.actionCell{i})
                        if ~isa(Obj.actionCell{i}{j},'cell')
                            disp('non-cell');
                            g{j,cellI} = Obj.actionCell{i}{j}.nameAbbreviation;
                            pi(j,cellI) = cellI-1;
                            pj(j,cellI) = parentJ;
                            
                            tempLen = 1;
                        else
                            disp('recurse');
                            innerTempAlgo = prtAlgorithm(Obj.actionCell{i}{j});
                            
                            innerLocalHeight = innerTempAlgo.getHeight;
                            innerLocalLength = innerTempAlgo.getLength;
                            innerLocalStart = floor((h + j-1 - innerLocalHeight)/2 + 1);
                            indI = innerLocalStart+j-1:innerLocalStart+innerLocalHeight+j-2;
                            indJ = cellI:cellI+innerLocalLength-1;
                            [g(indI,indJ),ppi,ppj] = innerTempAlgo.toCellArray(j,i);
                            
                            pi(indI,indJ) = ppi + indJ(1)-1;
                            pj(indI,indJ) = ppj + indI(1)-1;
                            tempLen = innerLocalLength;
                        end
                        if tempLen > maxLen
                            maxLen = tempLen;
                        end
                    end
                    cellI = cellI + maxLen;
                end
                %                 parentI = newParentI;
                %                 parentJ = newParentJ;
                %keyboard
            end
        end
               
        
        function in1 = mrdivide(in1,in2)
            if isa(in2,'prtAlgorithm')
                in1.actionCell = {{in1.actionCell},{in2.actionCell}};
            elseif isa(in2,'prtAction')
                in1.actionCell = {{in1.actionCell},{in2}};
            else
                error('prt:prtAlgorithm:mrdivide','prtAlgorithm.mrdivide is only defined for second inputs of type prtAlgorithm or prtAction, but the second input is a %s',class(in2));
            end
        end
        
        %this should be hidden
        function in1 = mldivide(in1,in2)
            if isa(in2,'prtAlgorithm')
                in1.actionCell = {{in2.actionCell},{in1.actionCell}};
            elseif isa(in2,'prtAction')
                in1.actionCell = {{in2},{in1.actionCell}};
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
            if ~ischar(varargin{1})
                if ~iscell(varargin{1})
                    error('prt:prtAlgorith:invalidInput','Invalid input. First input must be a cell of prtActions.');
                end
                
                Obj.actionCell = varargin{1};
                
                if nargin > 1
                    extraInputs = varargin(2:end);
                else
                    extraInputs = {};
                end
            else
                extraInputs = varargin;
            end
            Obj = prtUtilAssignStringValuePairs(Obj,extraInputs{:});
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