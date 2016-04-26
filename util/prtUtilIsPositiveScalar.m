function bool = prtUtilIsPositiveScalar(value)
%bool = prtUtilIsPositiveScalar(value)





bool = all(isnumeric(value)) && all(value > 0) && isscalar(value);

