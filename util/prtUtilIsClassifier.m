function bool = prtUtilIsClassifier(Structure)
%bool = prtUtilIsClassifier(Structure)

bool = isa(Structure,'prtAction') && strcmpi(Structure.actionType,'classifier');