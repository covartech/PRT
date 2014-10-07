function D = prtDistanceEuclideanMissingData(dataSet1,dataSet2)

Lnorm = 2;
[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);
nSamples1 = size(data1,1);
nDim1 = size(data1,2);
nSamples2 = size(data2,1);
D = nansum(bsxfun(@minus,reshape(data1,[nSamples1,1,nDim1]),reshape(data2,[1,nSamples2,nDim1])).^Lnorm,3);
