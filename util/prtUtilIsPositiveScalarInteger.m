function bool = prtUtilIsPositiveScalarInteger(value)
%bool = prtUtilIsPositiveScalarInteger(value)
% xxx Need Help xxx





bool = all(isnumeric(value)) && isscalar(value) && value > 0 && value == round(value);

