function B = prtUtilStructVCatMergeFields(varargin)
% B = prtUtilStructVCatMergeFields(A,B)

% Some sanity checks
%
% %%
% S1(1,1).a = 'asdf';
% S1(2,1).b = 2;
% S2(1,1).c = 2;
% S2(2,1).d = 'qwer';
% 
% Out = prtUtilStructVCatMergeFields(S1,S2);
% %%
% 
% S1(1,1).a = 'asdf';
% S1(1,2).b = 2;
% S2(1,1).c = 2;
% S2(1,2).d = 'qwer';
% 
% Out = prtUtilStructVCatMergeFields(S1,S2);
% 
% %%
% 
% S1(1,1).a = 'asdf';
% S1(1,2).b = 2;
% S2(1,1).c = 2;
% S2(1,3).d = 'qwer';
%  
% Out = prtUtilStructVCatMergeFields(S1,S2); % This errors

%%
if nargin==1 && iscell(varargin{1})
    structCell = varargin{1};
else
    structCell = varargin;
end
structCell(cellfun(@isempty,structCell)) = [];
nStructs = length(structCell);

if nStructs<2
    B = structCell{1};
    return
end

assert(all(cellfun(@isstruct,structCell)),'prt:prtUtilMergeStructureArrays','inputs must be structure arrays');

fn = cellfun(@(a){fieldnames(a)},structCell);
allFields = {};
for iStruct = 1:nStructs
    allFields = union(allFields,fn{iStruct});
end

for iStruct = 1:nStructs
    missingFields = setdiff(allFields,fn{iStruct});
    for iField = 1:length(missingFields)
        tmp = cell(size(structCell{iStruct}));
        [structCell{iStruct}(:).(missingFields{iField})] = deal(tmp);
    end
    structCell{iStruct} = orderfields(structCell{iStruct});
end

try
    B = cat(1,structCell{:});
catch
    error('prt:prtUtilStructVCatMergeFields','arguments dimensions are not consistent.');
end
