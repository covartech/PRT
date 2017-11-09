% prtUtilSumExp(x)
%   returns log(sum(exp(x),1)) while avoiding underflow issues
%
% Notes: This only sums down, thus the sum( * , 1)
%        This only accepts real doubles
%        If there is a large spread between the min and max values
%           some underflow is still possible. Although unlikely to
%           matter in the end due to the large spread in your values.
%
%        Error checking is minimal and seg faults are possible
