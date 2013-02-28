function B = prtUtilStructVCatMergeFields(A,B)
% B = prtUtilStructVCatMergeFields(A,B)

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
