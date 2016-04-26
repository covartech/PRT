function bool = prtUtilIsClassifier(Structure)
%bool = prtUtilIsClassifier(Structure)
% xxx Need Help xxx
% Internal







bool = isa(Structure,'prtAction') && strcmpi(Structure.actionType,'classifier');
