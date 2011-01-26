function bool = prtUtilIsPostiveScalar(value)
%bool = prtUtilIsPostiveScalar(value)
bool = all(value > 0) && isscalar(value);
