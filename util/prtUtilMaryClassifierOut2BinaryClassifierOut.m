function posterior = prtUtilMaryClassifierOut2BinaryClassifierOut(maryOut,H0H1matrix,fusionFn)
%posterior = prtUtilMaryClassifierOut2BinaryClassifierOut(maryOut,H0H1matrix)
%posterior = prtUtilMaryClassifierOut2BinaryClassifierOut(maryOut,H0H1matrix,fusionFn)
% xxx Need Help xxx







if any(maryOut(:) < 0)
    error('prt:NonProbabilisticInputs',sprintf('Some M-ary outputs are not between 0 and 1 (%.2f < 0); prtUtilMaryClassifierOut2BinaryClassifierOut requires probabilistic maryOut (0 <= maryOut <= 1)',min(maryOut(:)))); %#ok
elseif any(maryOut(:) > 1)
    error('prt:NonProbabilisticInputs',sprintf('Some M-ary outputs are not between 0 and 1 (%.2f > 1); prtUtilMaryClassifierOut2BinaryClassifierOut requires probabilistic maryOut (0 <= maryOut <= 1)',max(maryOut(:)))); %#ok
end
if length(H0H1matrix) ~= size(maryOut,2)
    error('prt:MatrixDimensionMismatch',sprintf('Length of H0H1matrix (%d) must match size(maryOut,2) (%d)',length(H0H1matrix),size(maryOut,2))); %#ok
end

if nargin == 2
    fusionFn = @(x)sum(x,2);
end
pH1 = fusionFn(maryOut(:,H0H1matrix == 1));
pH0 = fusionFn(maryOut(:,H0H1matrix == 0));
posterior = pH1./(pH1 + pH0);
