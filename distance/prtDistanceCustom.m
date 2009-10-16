function D = prtDistanceCustom(varargin)

V1 = varargin{1};
V2 = varargin{2};
singleDistanceFunction = varargin{3};

D = zeros(size(V1,1),size(V2,1));
for i = 1:size(V1,1);
    for j = 1:size(V2,1);
        D(i,j) = feval(singleDistanceFunction,V1(i,:),V2(j,:));
    end
end