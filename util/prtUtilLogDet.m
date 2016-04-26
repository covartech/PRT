function v = prtUtilLogDet(A)
% v = prtUtilLogDet(A)
% More numerically stable than v = log(det(A));







[L, U, P] = lu(A);
du = diag(U);
c = det(P) * prod(sign(du));
v = log(c) + sum(log(abs(du)));
