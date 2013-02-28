function str = prtUtilStructToStr(S,varName)
%
%     S.a = [1 2 3];
%     S.b = 'asdf';
%     prtUtilStructToStr(S)
%
%     S(1).a = [1 2 3];
%     S(1).b = 'asdf';
%     S(2).a = 'lkjh';
%     S(2).b = [4 5 6];
%     prtUtilStructToStr(S)    
%
%     S1(1).S2.a = [1 2 3];
%     S1(2).S2.b = 'lkjh';   
%     prtUtilStructToStr(S1)    

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


%     S.innnerS(1).a = [1 2 3];
%     S.innnerS(2).a = 'lkjh';
%     prtUtilStructToStr(S,'myStruct');    

if nargin < 2 || isempty(varName)
    varName = inputname(1);
end

assert(isstruct(S),'prtUtilStruct2Str is only for structure inputs');

if numel(S) > 1;
    str = cell(0,1);
    for iS = 1:numel(S)
        cStr = prtUtilStructToStr(S(iS),sprintf('%s(%d)',varName,iS));
        
        str = cat(1,str,cStr);
    end
    
    reshapeStr = sprintf('%s = reshape(%s,%s);',varName,varName,mat2str(size(S)));
    
    str = cat(1,str,reshapeStr);
    
    return
    
end
    
fnames = fieldnames(S);

str = cell(0,1);
for iField = 1:length(fnames)
    cVal = S.(fnames{iField});
    
    if isnumeric(cVal) || islogical(cVal)
        cValStr = mat2str(cVal);
        cValStr = sprintf('%s.%s = %s;',varName,fnames{iField},cValStr);
        
    elseif ischar(cVal)
        if ~isvector(cVal)
            error('prt:prtUtilStructToStr','prtUtilStructToStr only accepts vector character arrays');
        end
        
        cValStr = cat(2,'''',cVal(:)','''');
        cValStr = sprintf('%s.%s = %s;',varName,fnames{iField},cValStr);
        
    elseif isstruct(cVal)
        cValStr = prtUtilStructToStr(cVal,cat(2,varName,'.',fnames{iField}));
    else
        error('prt:prtUtilStructToStr','prtUtilStructToStr only accepts structures with numeric or character fields.');
    end
    
    if ~iscell(cValStr)
        cValStr = {cValStr};
    end
    
    str = cat(1,str,cValStr);
end
