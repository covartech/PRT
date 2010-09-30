function bool = prtUtilIsPositiveInteger(value)
%bool = prtUtilIsPositiveInteger(value)

bool = all(value > 0) && all(value == round(value));
