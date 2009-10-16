function PrtResults = prtRun(PrtObject,varargin)
% PrtResults = prtRun(PrtObject,X)
% PrtResults = prtRun(PrtObject,PrtDataSet)

if isa(varargin{1},'prtDataSetBase')
    PrtDataSet = varargin{1};
else
    PrtDataSet = prtDataSet(varargin{1});
end

if isstruct(PrtObject)
    PrtResults = PrtObject.PrtOptions.Private.runFunction(PrtObject,PrtDataSet);
elseif iscell(PrtObject)
    for i = 1:length(PrtObject)
        if iscell(PrtObject{i})
            % Parallel
            cPrtObjectCell = PrtObject{i};
            for j = 1:length(cPrtObjectCell)
                PrtResults{i}{j} = prtRun(cPrtObjectCell{j},PrtDataSet);
            end
            PrtDataSet = prtDataSetUnLabeled(PrtResults{i}{:});
        elseif isstruct(PrtObject{i})
            % Serial
            PrtResults{i} = prtRun(PrtObject{i},PrtDataSet);
        else
            error('werawer')
        end
    end
end
% 
% if ~isa(PrtObject,'cell')
%     PrtResults = PrtObject.PrtOptions.Private.runFunction(PrtObject,PrtDataSet);
% else
%     for i = 1:length(PrtObject)
%         PrtDataSet = prtRun(PrtObject{i},PrtDataSet);
%     end
%     PrtResults = PrtDataSet;
% end