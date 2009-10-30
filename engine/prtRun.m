function [PrtResults,Etc] = prtRun(PrtObject,varargin)
% PrtResults = prtRun(PrtObject,X)
% PrtResults = prtRun(PrtObject,PrtDataSet)

if isa(varargin{1},'prtDataSetBase')
    PrtDataSet = varargin{1};
else
    PrtDataSet = prtDataSet(varargin{1});
end

if isstruct(PrtObject)
    [PrtResults,Etc] = PrtObject.PrtOptions.Private.runFunction(PrtObject,PrtDataSet);
elseif iscell(PrtObject)
    for i = 1:length(PrtObject)
        if iscell(PrtObject{i})
            % Parallel
            cPrtObjectCell = PrtObject{i};
            for j = 1:length(cPrtObjectCell)
                [PrtResults{i}{j},Etc{i}{j}] = prtRun(cPrtObjectCell{j},PrtDataSet);
            end
            %PrtDataSet = prtDataSetUnLabeled(PrtResults{i}{:});
            PrtDataSet = joinFeatures(PrtResults{i}{:});
        elseif isstruct(PrtObject{i})
            % Serial
            [PrtResults{i},Etc{i}] = prtRun(PrtObject{i},PrtDataSet);
            PrtDataSet = PrtResults{i};
        else
            error('werawer')
        end
    end
end
if iscell(PrtResults)
   PrtResults = PrtResults{end};
end