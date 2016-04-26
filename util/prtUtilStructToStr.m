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
