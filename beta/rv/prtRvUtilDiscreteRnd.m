function y = prtRvUtilDiscreteRnd(values,probabilities,N,discreteEps)
%y = discreternd(values,probabilities,N);
%	Draw N RV's from a multi-variate uniform distribution with limits
%	LIMS.

% Author: Peter Torrione
% Revised by: 
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 18-March-2007
% Last revision:

if nargin < 3
    N = 1;
end
if nargin < 4
    discreteEps = 1e-6;
end

if isa(values,'double')
    if isscalar(N)
        y = nan(N,1);
    else
        y = nan(N);
    end
elseif isa(values,'cell');
    if isscalar(N)
        y = cell(N,1);
    else
        y = cell(N);
    end
else
    if isscalar(N)
        y = nan(N,1);
    else
        y = nan(N);
    end
end
PROBS = cumsum(probabilities);
if max(PROBS) > 1 + discreteEps
    error('Invalid probability vector');
end
for i = 1:numel(y)
    x = rand;
    I = find(x < PROBS);
    I = I(1);
    if isa(values,'double')
        y(i) = values(I);
    elseif isa(values,'cell');
        y{i} = values{I};
    else %handle classes:
        if i == 1
            y = values(I);
        else
            y(i) = values(I);
        end
    end
end