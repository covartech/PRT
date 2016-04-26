function D = prtDistanceQMetric(dataSet1,dataSet2,lambda)







% D = prtDistanceQMetric(dataSet1,dataSet2,lambda)

if nargin < 3 || isempty(lambda)
    lambda = -0.4;
end

assert(lambda <= 0 && lambda >= -1,'lambda must be between -1 and 0');

[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);

if any(data1(:)<0) || any(data1(:)>1) || any(data2(:)<0) || any(data2(:)>1)
    warning('prt:prtDistanceQMetric','prtDistanceQMetric should only be use for data with values in all dimensions between 0 and 1');
end

if lambda == 0
    D = prtDistanceLNorm(data1,data2,1);
    return
end

D = zeros(size(data1,1),size(data2,1));
for iDim = 1:size(data1,2)
    D = D + (1+lambda*D).*abs(bsxfun(@minus, data1(:,iDim),data2(:,iDim)'));
end
