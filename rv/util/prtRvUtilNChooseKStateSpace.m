function [binaryStateSpace,multiStateSpace] = prtRvUtilNChooseKStateSpace(n,k)
%[b,m] = nChooseKStateSpace(n,k)  N-Choose-K state space
%   [b,m] = nChooseKStateSpace(n,k) outputs a boolean matrix of
%   size(nchoosek(n,k),n) where each row is a unique set of k "true" values.  
%   Each row of m contains the indices of the corresponding row b which are
%   true.
%
%   Inputs:
%       n - (integer, 1 <= n <= 36) 
%       k - (integer, vector, 0 <= k(i) <= n) - if k is a vector,
%           nChooseKStateSpace returns a concatenation of 
%           nChooseKStateSpace(n,k(i)) \forall i.  Note, when k is a
%           vector, multiStateSpace is a cell array of matrices of indices
%
%           Note: If k is zero, binaryStateSpace is a row vector of zeros, 
%           and multiStateSpace is empty







if k == 0
    binaryStateSpace = zeros(1,n);
    multiStateSpace = [];
    return
end

if numel(k) > 1
    binaryStateSpace = [];
    for i = 1:numel(k)
        [bss,multiStateSpace{i}] = prtRvUtilNChooseKStateSpace(n,k(i));
        binaryStateSpace = cat(1,binaryStateSpace,bss);
    end
    return;
end
        
if k > n
    error('k (%d) must be <= n (%d)',n,k);
end
if n <= 0 || k < 0
    error('k (%d) must be > 0 and n (%d) must be >= 0',n,k);
end
if nchoosek(n,k) > 1e6
    error('Maximum matrix size exceeded. nchoosek(n,k) must be below 10^6.')
end

    
multiStateSpace = prtRvUtilMultinomialStateSpace(k,n);
multiStateSpace = sort(multiStateSpace,2);

multiStateSpace = unique(multiStateSpace,'rows');  %remove duplicates, only one of [1,2], [2,1] should be in there
multiStateSpace = multiStateSpace + 1;             % 0-->1, 1-->2, etc.

keepIndices = ~any(diff(multiStateSpace,1,2) == 0,2); %remove rows with same indices [3 3], [1 2 2] etc.
multiStateSpace = multiStateSpace(keepIndices,:);

binaryStateSpace = false(size(multiStateSpace,1),n);
for i = 1:size(binaryStateSpace,1)
    binaryStateSpace(i,multiStateSpace(i,:)) = true;  %make the binaryStateSpace matrix have ones where multiStateSpace says to put em
end
