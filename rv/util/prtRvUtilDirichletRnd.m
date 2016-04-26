function X = prtRvUtilDirichletRnd(alpha,N)
% X = dirichletrnd(alpha,N)







K = length(alpha);
gams = zeros(N,K);
for iK = 1:K
    gams(:,iK) = gamrnd(alpha(iK),1,N,1);
end

X = gams ./ repmat(sum(gams,2),1,K);
