function D = prtDistanceCustom(dataSet1,dataSet2,singleDistanceFunction)
% prtDistanceCustom   Custom distance function
% 
%   DIST = prtDistanceCityBlock(D1,D2,DISTFUNHANDLE)  calculates the
%   distance from all the observations in dataset D1 to dataset D2, using
%   the function handle DISTFUNHANDLE. The output is a distance matrix of
%   size D1.nObservations x D2.nObservations. D1 and D2 must have the same
%   number of features.
%
%   DISTFUNHANDLE should be a function handle that accepts two 1xn
%   vectors and outputs the scalar distance between them.  For example, 
%
%   DISTFUNHANDLE = @(x,y)sqrt(sum((x-y).^2,2)); %euclidean distance
%
%   Note: This is provided as an example only, use prtDistanceEuclidean to
%   calculate Euclidean distances, as it is significantly faster than
%   prtDistanceCustom.
%   
%   %  Example:
%
%   % Create 2 data sets
%   dsx = prtDataSetStandard('Observations',[0 0; 1 1]);
%   dsy = prtDataSetStandard('Observations',[1 0; 2 2; 3 3;]);
%   % Compute their distance based on function handle
%   distance = prtDistanceCustom(dsx,dsy,@(x,y)sqrt(sum((x-y).^2,2)))
%
%   See Also: prtDistanceChebychev, prtDistanceCityBlock,
%   prtDistanceEuclidean, prtDistanceMahalanobis, prtDistanceSquare







[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);

D = zeros(size(data1,1),size(data2,1));
for i = 1:size(data1,1);
    for j = 1:size(data2,1);
        D(i,j) = feval(singleDistanceFunction,data1(i,:),data2(j,:));
    end
end
