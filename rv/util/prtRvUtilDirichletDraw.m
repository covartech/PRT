function X = prtRvUtilDirichletDraw(alpha,N)
% X = prtRvUtilDirichletDraw(alpha,N)
% Internal
% xxx Need Help xxx







if nargin < 2 || isempty(N)
    N = 1;
end

K = length(alpha);
gams = zeros(N,K);
for iK = 1:K
    if alpha(iK) == 1
        % Short cut to use exprnd(1)
        % gamma(1) is equivalent to exp(1) so 
        % actually using exprnd is slow because of input checks
        % Because of simplifications because alpha is one this is really
        % simple.
        gams(:,iK) = log(rand([N,1]));
    else
        % gamrnd is slow because of checking the input arguments
        %gams(:,iK) = gamrnd(alpha(iK),1,N,1);
    
        % So this is equivalent and faster
        gams(:,iK) = randg(alpha(iK),[N,1]);
    end
end

X = bsxfun(@rdivide,gams,sum(gams,2));
