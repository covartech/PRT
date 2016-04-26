function y = prtRvUtilDiscretePdf(X,values,probabilities)
%y = discretepdf(X,values,probabilities);
%	Return the PDF of a discrete distribution with values and
%	probabilities.








y = zeros(size(X));
for i = 1:size(X(:),1);
    cI = find(X(i) == values);
    if isempty(cI)
        y(i) = 0;
    else
        y(i) = probabilities(cI);
    end
end
