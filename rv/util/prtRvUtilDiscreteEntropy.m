function e = prtRvUtilDiscreteEntropy(q)
% DISCRETEENTROPY







e = q.*log(q);
e(q==0) = 0;
e = sum(e(:));

end
