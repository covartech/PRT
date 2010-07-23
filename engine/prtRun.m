function PrtResults = prtRun(PrtObject,varargin)
% PrtResults = prtRun(PrtObject,X)
% PrtResults = prtRun(PrtObject,PrtDataSet)

if isa(varargin{1},'prtDataSetBase')
    PrtDataSet = varargin{1};
else
    PrtDataSet = prtDataSetClass(varargin{1});
end

if isa(PrtObject,'prtAction')
    PrtResults = PrtObject.runFunction(PrtObject,PrtDataSet);
    
    % Figure out if we have an Mary Situation or any sort of emulation
    [useMary, emulate] = prtUtilDetermineMary(PrtObject);
    if useMary % Mary output
        if emulate
            % Emulated Mary with a binary classifier
            %
            % We have taken care of this in generate so we dont need to do
            % anything here
        else
            % Native Mary
            %
            % We don't need to do anything special we can output the matrix
        end
    else % Binary output
        if emulate
            % Emulate Binary
            %
            % We have an M-ary classifier and need to produce a single DS
            
            % We need to check the BinaryEmulationOptions to make sure they
            % will work. This way we can spit out informative error
            % messages
            if PrtObject.dataSetNClasses ~= length(PrtObject.BinaryEmulationOptions.classAssignment);
                error('prt:prtRun:BinaryEmulation','The specified BinaryEmulationOptions.classAssignment is not valid. It must be a logical with a length equal to the number of classes.')
            end
            if length(unique(PrtObject.BinaryEmulationOptions.classAssignment)) ~= 2
                error('prt:prtRun:BinaryEmulation','The specified BinaryEmulationOptions.classAssignment is not valid. It must be a logical containing at least one element which is true and one element which is false.')
            end
            PrtResults = PrtResults.setObsetvations(dprtMaryClassifierOut2BinaryClassifierOut(PrtResults.getObservations(),PrtObject.BinaryEmulationOptions.classAssignment,PrtObject.BinaryEmulationOptions.aggregationFunction));
        else
            % Native Binary
            %
            % There are actually two possibilities here.
            %   1) Native Binary Classifier single DS -> Fine
            %   2) Mary Classifier with twoClassParadigm = 'binary'
            
            % This should take care of both cases
            PrtResults = PrtResults.setObservations(PrtResults.getObservations(:,end));
        end
    end
    
elseif iscell(PrtObject)
    % For block diagram-like calls
    for i = 1:length(PrtObject)
        if iscell(PrtObject{i})
            % Parallel
            cPrtObjectCell = PrtObject{i};
            for j = 1:length(cPrtObjectCell)
                [PrtResults{i}{j}, Etc{i}{j}] = prtRun(cPrtObjectCell{j},PrtDataSet);
            end
            %PrtDataSet = prtDataSetUnLabeled(PrtResults{i}{:});
            PrtDataSet = joinFeatures(PrtResults{i}{:});
        elseif isstruct(PrtObject{i})
            % Serial
            [PrtResults{i}, Etc{i}] = prtRun(PrtObject{i},PrtDataSet);
            PrtDataSet = PrtResults{i};
        else
            error('prt:prtRun:ModelConstruction','Invalid PRT model construction.')
        end
    end
end
if iscell(PrtResults)
   PrtResults = PrtResults{end};
end