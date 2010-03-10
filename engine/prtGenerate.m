function PrtActionObj = prtGenerate(varargin)
% PrtStruct = prtGenerate(DataSet,PrtOptions)
% PrtStruct = prtGenerate(X,Y,PrtOptions)

if nargin == 2
    DataSet = varargin{1};
    PrtOptions = varargin{2};
end
if nargin == 3
    DataSet = prtDataSetLabeled(varargin{1:2});
    PrtOptions = varargin{3};
end

if isstruct(PrtOptions)
    [useMary, emulate] = prtUtilDetermineMary(DataSet,PrtOptions);
    if useMary && emulate
        PrtStruct = PrtOptions.MaryEmulationOptions.emulationFunction(DataSet,PrtOptions);
    else
        PrtStruct = PrtOptions.Private.generateFunction(DataSet,PrtOptions);
    end
    
    PrtActionObj = prtAction(DataSet, PrtOptions, PrtStruct);
    
elseif iscell(PrtOptions)
    for i = 1:length(PrtOptions)
        if iscell(PrtOptions{i})
            % Parallel
            cPrtOptionsCell = PrtOptions{i};
            for j = 1:length(cPrtOptionsCell)
                PrtActionObj{i}{j} = prtGenerate(DataSet,cPrtOptionsCell{j});
                newDataSets{j} = prtRun(PrtActionObj{i}{j},DataSet);
            end
            DataSetOut = joinFeatures(newDataSets{:});
            DataSet = DataSet.setObservations(DataSetOut.getObservations());
        elseif isstruct(PrtOptions{i})
            
            %Serial
            PrtActionObj{i} = prtGenerate(DataSet,PrtOptions{i});
            DataSetOut = prtRun(PrtActionObj{i},DataSet);
            DataSet = DataSet.setObservations(DataSetOut.getObservations());
            
        else
            error('prt:prtGenerate:Invalid PrtOptions.')
        end
    end
end
