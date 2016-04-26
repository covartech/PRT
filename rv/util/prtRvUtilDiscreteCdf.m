function y = prtRvUtilDiscreteCdf(X,values,probabilities)
%y = discretecdf(X,values,probabilities);
%	Return the cdf of a discrete distribution with values and
%	probabilities.







[Xsort,IND] = sort(X);
y = zeros(size(Xsort));
for i = 1:size(Xsort(:),1);
    cI = find(Xsort(i) >= values);
    if isempty(cI)
        if i > 1
            y(i) = y(i-1);
        else
            y(i) = 0;
        end
    else
        cI = cI(end);
        y(i) = sum(probabilities(1:cI));
    end
end

%un-sort the outputs
[inter,i1,i2] = intersect(1:length(X),IND);
y = y(i2); 
