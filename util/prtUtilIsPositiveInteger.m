function bool = prtUtilIsPositiveInteger(value)
%bool = prtUtilIsPositiveInteger(value)
% xxx Need Help xxx





bool = all(isnumeric(value)) && all(value > 0) && all(value == round(value));

