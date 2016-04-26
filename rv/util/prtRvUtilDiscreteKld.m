function k = prtRvUtilDiscreteKld(q,p)
% DISCRETEKLD







k = q.*(log(q)-log(p));
k(q==0) = 0;
k = sum(k(:));


end
