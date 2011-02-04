function B = prtUtilMergeStructureArrays(A,B,inds)
% B = prtUtilMergeStructureArrays(A,B,inds)
%
% Incase of field collisions, the values in A are used.

assert(isstruct(A) && isstruct(B) && all(size(A)==size(B)),'prt:prtUtilMergeStructureArrays','inputs must be structure arrays with the same size.');

assert(isstruct(A) && isstruct(B) && all(size(A)==size(B)),'prt:prtUtilMergeStructureArrays','inputs must be structure arrays with the same size.');

fnA = fieldnames(A);
fnB = fieldnames(B);

if ~isequal(fnA,fnB)
    % The two structures have different fields
    % We only need to reference the first entry in order to force matlab to
    % initialize everything else to []
    fieldsNotInB = setdiff(fnA,fnB);
    for iField = 1:length(fieldsNotInB)
        B(1).(fieldsNotInB{iField}) = [];
    end
    fieldsNotInA= setdiff(fnB,fnA);
    for iField = 1:length(fieldsNotInA)
        A(1).(fieldsNotInA{iField}) = [];
    end
end

% We need to make sure the fields are in the right order
B = orderfields(B, A);

try
    B(inds) = A(inds);
catch ME
    error('prt:prtUtilMergeStructureArrays','invalid indicies');
end