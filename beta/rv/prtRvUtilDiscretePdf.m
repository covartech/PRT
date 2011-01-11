function y = prtRvUtilDiscretePdf(X,values,probabilities)
%y = discretepdf(X,values,probabilities);
%	Return the PDF of a discrete distribution with values and
%	probabilities.

% Author: Peter Torrione
% Revised by: 
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 18-March-2007
% Last revision:

y = zeros(size(X));
for i = 1:size(X(:),1);
    cI = find(X(i) == values);
    if isempty(cI)
        y(i) = 0;
    else
        y(i) = probabilities(cI);
    end
end