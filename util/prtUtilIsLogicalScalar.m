function bool = prtUtilIsLogicalScalar(value)
%bool = prtUtilIsLogicalScalar(value)





bool = islogical(value) && isscalar(value);

