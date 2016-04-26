function B = prtUtilStructVCatMergeFields(A,B)
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
if isempty(A)  %base case
    return;
end

assert(isstruct(A) && isstruct(B),'prt:prtUtilMergeStructureArrays','inputs must be structure arrays');

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
    B = cat(1,A,B);
catch
    error('prt:prtUtilStructVCatMergeFields','arguments dimensions are not consistent.');
end
