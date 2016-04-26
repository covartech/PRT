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

