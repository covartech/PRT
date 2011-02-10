function D = prtDistanceCustom(dataSet1,dataSet2,singleDistanceFunction)
% prtDistanceCustom   Custom distance function
% 
%   dist = prtDistanceCityBlock(d1,d2,singleDistanceFunction) for data sets 
%   or double matrices d1 and d2 calculates the distance from all the 
%   observations in d1 to d2, using the function singleDistanceFunction, 
%   and ouputs a distance matrix of size d1.nObservations x d2.nObservations 
%   (size(d1,1) x size(d2,1) for double matrices).
%
%   singleDistanceFunction should be a function handle that accepts two 1xn
%   vectors and outputs the scalar distance between them.  For example, 
%
%   singleDistanceFunction = @(x,y)sqrt(sum((x-y).^2,2)); %euclidean distance
%
%   Note: This is provided as an example only, use prtDistanceEuclidean to
%   calculate Euclidean distances, as it is significantly faster than
%   prtDistanceCustom.
%  
%   d1 and d2 should have the same dimensionality, i.e. d1.nFeatures ==
%   d2.nFeatures (size(d1,2) == size(d2,2) for double matrices).
%   
%    Example:
%      X = [0 0; 1 1];
%      Y = [1 0; 2 2; 3 3;];
%      D = prtDistanceCustom(X,Y,@(x,y)sqrt(sum((x-y).^2,2)))
%
%      % prtDistanceCustom also accepts prtDataSet inputs:
%      dsx = prtDataSetStandard(X);
%      dsy = prtDataSetStandard(Y);
%      distance = prtDistanceCustom(dsx,dsy,@(x,y)sqrt(sum((x-y).^2,2)))
%
%   See Also:  prtDistance prtDistanceChebychev prtDistanceCityBlock
%   prtDistanceEuclidean prtDistanceMahalanobis prtDistanceSquare

[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);

D = zeros(size(data1,1),size(data2,1));
for i = 1:size(data1,1);
    for j = 1:size(data2,1);
        D(i,j) = feval(singleDistanceFunction,data1(i,:),data2(j,:));
    end
end