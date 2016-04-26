function gram = prtUtilRbfDist(x,y,varargin)




%   gram = rbfDistance(x,y,param1,value1,...)
%   finds the Radial Basis Function distance between X and Y.
%
%   gram = prtUtilRbfDist(x,y,param1,value1,...)
%   Enables inputs of parameter/value pairs as described below:
%
%   Parameters:
%       
%   sigma - Variance of the Radial Basis Function (RBF)
%
%   Example usage:
%
%   ds=prtDataGenUnimodal;
%   gram=prtUtilRbfDist(ds.X,ds.X,'sigma',1);
%   imagesc(gram)
%   title('X vs. Y Gram Matrix');
 


p = inputParser;

p.addParamValue('sigma',.2)

p.parse(varargin{:});
inputStruct = p.Results;
sigma=inputStruct.sigma;

[n1, d] = size(x);
[n2, nin] = size(y);

if d ~= nin
    error('size(x,2) must equal size(y,2)');
end

dist2 = repmat(sum((x.^2), 2), [1 n2]) + repmat(sum((y.^2),2), [1 n1]).' - 2*x*(y.');

if numel(sigma) == 1
    gram = exp(-dist2/(sigma.^2));
else
    gram = exp(-bsxfun(@rdivide,dist2,(sigma.^2)'));
end

end
