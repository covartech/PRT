function s = prtRvUtilMultinomialStateSpace(n,m)
% MNOMIALSTATESPACE     Multinomial State Space matrix
%   Yields an M^N x N matrix of all of the possible entries of the state
%   space of the multinomial variable. This does not work for values of m
%   over 36.
%
% Syntax: s = mNomialStateSpace(n,m)
%
% Inputs:
%   n - The number of variables to include
%   m - The base of the number system
%
% Outputs:
%   s - The matrix conting all of the entries in the state space
%
% Example:
%   s = mNomialStateSpace(2,2);
%   andTruthTable = [s,and(s(:,1),s(:,2))]
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

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




if nargin == 1
    m = 2;
end

if m^n > 1e6
    error('Maximum matrix size exceeded. m^n must be below 10^6.')
end

s = zeros([m^n n]);
for iSamp = 0:(m^n-1)
    temp = double(dec2base(iSamp, m, n)') - 48;
    temp(temp>=17) = temp(temp>=17)-7;
    s(iSamp+1,:) = temp;
end

