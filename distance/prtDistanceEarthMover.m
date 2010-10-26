function distance = prtDistanceEarthMover(dataSet1,dataSet2,X1,X2)
% prtDistanceEarthMover   Earth mover distance
%
%   dist = prtDistanceEarthMover(d1,d2) for data sets or double matrices d1
%   and d2 calculates the earth mover distance from all the observations in
%   d1 to d2, and ouputs a distance matrix of size d1.nObservations x
%   d2.nObservations (size(d1,1) x size(d2,1) for double matrices).  With
%   two input arguments, prtDistanceEarthMover assumes that columns
%   represent weights for equally spaced points at locations
%   1:dataSet.nFeatures.
%  
%   d1 and d2 should have the same dimensionality, i.e. d1.nFeatures ==
%   d2.nFeatures (size(d1,2) == size(d2,2) for double matrices).
%   
%   Earth mover's distance requires that the values in d1 and d2 are
%   positive, and they should have constant row sums for the distance to be
%   meaningful.
%
%   distance = prtDistanceEarthMover(dataSet1,dataSet2,X1,X2) where X1 and 
%   X2 are double matrices of size dataSet1.nObservations x
%   dataSet1.nFeatures and dataSet2.nObservations x dataSet2.nFeatures
%   allows the user to specify the locations of the points in each of the
%   data sets.
%
%   Example:
%       d = rand(20,3);
%       d = bsxfun(@rdivide,d,sum(d,2));
%       distance = prtDistanceEarthMover(d,d);
%
%   For more information, see:
%   
%   http://en.wikipedia.org/wiki/Earth_mover's_distance
%
%   See also: Rubner, Tomasi, Guibas.  The Earth Mover's Distance as a Metric
%   for Image Retrieval. 

[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2,false);
if nargin < 4
    X1 = repmat(1:size(data1,2),size(data1,1),1);
    X2 = repmat(1:size(data2,2),size(data2,1),1);
end
if any(data1(:)) < 0 || any(data2(:)) < 0
    error('prt:prtDistanceEarthMover:InvalidWeights','prtDistanceEarthMover is only defined for data with values > 0');
end
if length(unique(sum(cat(1,data1,data2),2))) ~= 1
    warning('prt:prtDistanceEarthMover:InvalidWeights','prtDistanceEarthMover best defined for data whose rows sum to a constant value - length(unique(sum(data,2))) should be 1 (i.e. normalized histograms)');
end

opts1= optimset('display','off');

distance = zeros(size(data1,1),size(data2,1));
for i = 1:size(data1,1)
    for j = 1:size(data2,1)
        x1 = X1(i,:)';
        x2 = X2(j,:)';
        w1 = data1(i,:)';
        w2 = data2(j,:)';
        
        f = prtDistanceEuclidean(x1,x2);
        f = f';
        f = f(:);
        
        A = kron(eye(size(x1,1)),ones(1,size(x2,1)));
        A = cat(1,A,kron(ones(1,size(x1,1)),eye(size(x2,1))));
        b = [w1(:); w2(:)];
        
        Aeq = ones(size(f));
        beq = min([sum(w1),sum(w2)]);
        
        [~,distance(i,j)] = linprog(f,A,b,Aeq',beq,zeros(size(f)),[],[],opts1);
    end
end
