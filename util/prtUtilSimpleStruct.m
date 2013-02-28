function s = prtUtilSimpleStruct(varargin)
%s = prtUtilSimpleStruct(varargin)
%s = prtUtilSimpleStruct('asdf',randn(100,1),'fff',randn(100,1))
%s = prtUtilSimpleStruct('asdf',randn(100,1),'fff',randn(100,1),'asfsadf',prtUtilCellPrintf('%s',num2cell(1:100)'))
%s = prtUtilSimpleStruct(origStruct,...)

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


% fields = varargin(1:2:end);
% vals = varargin(2:2:end);

if mod(nargin,2) %odd # inputs
    origStruct = varargin{1};
    
    if isempty(origStruct)
        origStruct = struct;
    end
    
    if ~isa(origStruct,'struct')
        error('prtUtilSimpleStruct:firstInputStruct','prtUtilSimpleStruct with odd # of inputs expects first input to be a structure');
    end
    varargin = varargin(2:end);
else
    origStruct = struct;
end
structInput = cell(1,length(varargin));

for i = 1:2:length(varargin)
    cField = varargin{i};
    cVal = varargin{i+1};
    assert(isvarname(cField),'can not create struct with a field named %s',cField);
    
    if iscellstr(cVal)
        %ok
    else
        cVal = mat2cell(cVal,ones(size(cVal,1),1),size(cVal,2));
    end
    
    structInput(i:i+1) = {cField,cVal};
end
newStruct = struct(structInput{:});

f1 = fieldnames(origStruct);
f2 = fieldnames(newStruct);

%If the new structure data specifies a pre-existing field in origStruct,
%remove the field from origStruct before trying to merge the structures
uNames = unique(cat(1,f1(:),f2(:)));
for i = 1:length(uNames)
    if any(strcmpi(f2,uNames{i})) && any(strcmpi(f1,uNames{i})) 
        origStruct = rmfield(origStruct,uNames{i});
    end
end

s = mergestruct(origStruct,newStruct);


function sout = mergestruct(varargin)
%MERGESTRUCT Merge structures with unique fields.
% This is from http://blogs.mathworks.com/loren/2009/10/15/concatenating-structs/
%   Copyright 2009 The MathWorks, Inc.

% Start with collecting fieldnames, checking implicitly
% that inputs are structures.
fn = [];
for k = 1:nargin
    try
        fn = [fn ; fieldnames(varargin{k})];
    catch MEstruct
        throw(MEstruct)
    end
end

% Make sure the field names are unique.
if length(fn) ~= length(unique(fn))
    error('mergestruct:FieldsNotUnique',...
        'Field names must be unique');
end

% Now concatenate the data from each struct.  Can't use
% structfun since input structs may not be scalar.
c = [];
for k = 1:nargin
    try
        c = [c ; struct2cell(varargin{k})];
    catch MEdata
        throw(MEdata);
    end
end

% Construct the output.
sout = cell2struct(c, fn, 1);
