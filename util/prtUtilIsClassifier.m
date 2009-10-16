function bool = prtUtilIsClassifier(Structure)
%bool = prtUtilIsClassifier(Structure)

bool = false;
if isa(Structure,'struct') && isfield(Structure,'PrtOptions') && strcmpi(Structure.PrtOptions.Private.PrtObjectType,'classifier')
    bool = true;
end