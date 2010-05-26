classdef prtAlgorithm < prtAction
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'PRT Algorithm'
        nameAbbreviation = 'ALGO'
        isSupervised = true; % We say true even though we don't know
    end
    
    properties
        actionCell = {};
    end
    
    methods
        
        function Obj = prtAlgorithm(varargin)
            if nargin == 0
                return
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
                if iscell(Obj.actionCell{iAction})
                    % Parallel
                    for jAction = 1:length(Obj.actionCell{iAction})
                        Obj.actionCell{iAction}{jAction}.verboseStorage = Obj.verboseStorage;
                        Obj.actionCell{iAction}{jAction} = train(Obj.actionCell{iAction}{jAction}, DataSet);
                        ijDataSets{jAction} = run(Obj.actionCell{iAction}{jAction}, DataSet);
                    end
                    DataSetOut = joinFeatures(ijDataSets{:});
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
                    DataSetOut = joinFeatures(ijDataSets{:});
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