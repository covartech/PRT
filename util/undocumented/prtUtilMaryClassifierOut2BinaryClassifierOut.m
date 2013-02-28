function posterior = prtUtilMaryClassifierOut2BinaryClassifierOut(maryOut,H0H1matrix,fusionFn)
%posterior = prtUtilMaryClassifierOut2BinaryClassifierOut(maryOut,H0H1matrix)
%posterior = prtUtilMaryClassifierOut2BinaryClassifierOut(maryOut,H0H1matrix,fusionFn)
% xxx Need Help xxx

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
