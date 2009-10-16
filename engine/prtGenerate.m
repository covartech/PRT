function PrtStruct = prtGenerate(varargin)
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
elseif iscell(PrtOptions)
    for i = 1:length(PrtOptions)
        if iscell(PrtOptions{i})
            % Parallel
            cPrtOptionsCell = PrtOptions{i};
            for j = 1:length(cPrtOptionsCell)
                PrtStruct{i}{j} = prtGenerate(DataSet,cPrtOptionsCell{j});
                newDataSets{j} = prtRun(PrtStruct{i}{j},DataSet);
            end
            classLabels = DataSet.getLabels;
            DataSet = prtDataSet(newDataSets{:});
            DataSet = prtDataSetLabeled(DataSet.data,classLabels);
%            keyboard
        elseif isstruct(PrtOptions{i})
            %Serial
            classLabels = DataSet.getLabels;
            PrtStruct{i} = prtGenerate(DataSet,PrtOptions{i});
            DataSet = prtRun(PrtStruct{i},DataSet);
            DataSet = prtDataSetLabeled(DataSet.data,classLabels);
        else
            error('werawer')
        end
    end
end
