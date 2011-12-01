function C = nextperm(N,K)
%NEXTPERM Loop through permutations without replacement.
% NEXTPERM(N,K), when first called, returns a function handle.  This  
% function handle, when called, returns the next permutation without 
% replacement of K elements taken from the set 1:N. This can be useful
% when the number of such permutations is too large to hold in memory at
% once.  If the number of such permutations is not too large, use 
% COMBINATOR(N,K,'p') (on the FEX) instead.
%
% The number of permutations without replacement is:  N!/(N-K)!
%   where N >= 1, N >= K >= 0
%
% Examples:
%
%     % To use each permutation one at a time, put it in a loop.
%     N = 4;  % Length of the set.
%     K = 3;  % Number of samples taken for each sampling.
%     H = nextperm(N,K);
%     for ii = 1:((prod(1:N)/(prod(1:(N-K)))))
%         A = H();
%         % Do stuff with A: use it as an index, etc.
%     end
%
%
%     % To build all of the permutations, do this (See note below):
%     ROWS = (prod(1:N)/(prod(1:(N-K))));
%     C = ones(ROWS,K);
%     for ii = 1:ROWS
%         C(ii,:) = H();
%     end
%     %Note this is a lot slower than using combinator(N,K,'p')
%
% The function handle will cycle through when the final permutation is
% returned.
%
% See also,  nchoosek, perms, combinator, npermutek (both on the FEX)
%
% Author:   Matt Fig
% Contact:  popkenai@yahoo.com
% Date: 6/9/2009
% Reference:  http://mathworld.wolfram.com/BallPicking.html 

% Arg checking.
if K>N 
    error('K must be less than or equal to N.')
end

if isempty(N) || K == 0
   C = [];  
   return
elseif numel(N)~=1 || N<=0 || ~isreal(N) || floor(N) ~= N 
    error('N should be one real, positive integer. See help.')
elseif numel(K)~=1 || K<0 || ~isreal(K) || floor(K) ~= K
    error('K should be one real non-negative integer. See help.')
end

CNT = 0;  % Initializations for the nested function.
G = [];
TMP = [];
op = 1; % These are the variables which are passed to subfunc.
blk = 1;  % Keeps track of the permutation blocks in the subfunc.
idx = 1:N/2; % Index vectors for subfunc.
idx2 = idx;
WV = 1:K;  % Initial WV.
lim = 0;  % Sets the limit for working index.
inc = K;  % Controls which element of WV is being worked on.
cnt = 1;  % Keeps track of which block we are in.  See loop below.
BC = prod(1:N)/(prod(1:(N-K))); % Number of permutations.
L = prod(1:K);   % Size of the blocks.
CNT = 0;  % Counter for blocks.
Floop = BC - prod(1:K);  % Length of blocks.
A2 = (N-K+1):N;  % Seed for the final block.
B2 = 1:K;
ii = 1;

if K==1
    C = @nestfunc2;  % Return argument is a func handle.
else
    C = @nestfunc;
end

    function B = nestfunc2  
    % A handle to this function is passed back from the main func if K=1.    
        if WV > N
            B = 1;
            WV = 2;
            return
        end
       B = WV(1);
       WV = WV + 1;
    end

    function B = nestfunc
    % A handle to this function is passed back from the main func.
            if ii<=Floop
                if CNT == 0
                    for jj = 1:inc
                        WV(K + jj - inc) = lim + jj;
                    end
                    % This is the first combination.  We will permute it
                    % below for the rest of the calls in this block.
                    B = WV;
                    cnt = cnt + L;

                    if lim<(N-inc)
                        inc = 0;  % Reset this guy.
                    end

                    TMP = WV;  % This serves as seed for perm index.
                    inc = inc+1;  % Increment the counter.
                    lim = WV(K+1-inc);  % Limit for working index.
                    CNT = 1;
                    G = 1:K; % Seed for nextp subfunc
                    op = 1;
                    blk = 1;
                    idx = 1:N/2;
                    idx2 = idx;
                    ii = ii + 1; % "Loop" index.
                else
                    % Permute the seed.
                    [G,op,blk,idx,idx2] = nextp(G,op,blk,idx,idx2,K);
                    B = TMP(G);  % Index into current combination.
                    CNT = CNT + 1;

                    if CNT==(L) % Goes back to if for next seed (combin).
                        CNT = 0;
                    end
                    
                    ii = ii + 1;
                end
            else
                if ii == Floop+1  % We are at the last block
                    op = 1;  % Re-initialize for subfunc.
                    blk = 1;
                    idx = 1:N/2;
                    idx2 = idx;
                    B = A2;  % Seed for this last block.
                    cnt = cnt + 1;
                    ii = ii + 1;
                    return
                elseif ii == BC + 1  % Time to start over.
                    WV = 1:K;  % Seed for first block.
                    op = 1;  % Re-initialize for subfunc.
                    blk = 1;
                    idx = 1:N/2;
                    idx2 = idx;
                    inc = 1; % Reset the incrementer. 
                    lim = WV(K+1-inc); % And the lim.
                    cnt = L + 1;  % Reset block counter.
                    CNT = 1;
                    ii = 2;  % Reset "Loop" index.
                    B = WV;
                    TMP = WV;
                    B2 = 1:K;
                    G = 1:K;
                    return
                end
                % Permute seed the seed.
                [B2,op,blk,idx,idx2] = nextp(B2,op,blk,idx,idx2,K);
                B = A2(B2);
                cnt = cnt + 1;
                ii = ii + 1;
            end 
    end
end





function [x,op,blk,idx,idx2] = nextp(x,op,blk,idx,idx2,K) 
% Delivers one permutation at a time.  This is a modification of an
% algorithm attributed to H. F. Trotter.
% x = 1:4; 
% op = 1; 
% blk = 1;  
% idx = 1:length(x)/2; 
% idx2 = idx;  
% C(1,:) = x;
% for jj = 2:factorial(length(x))
%    [x,op,blk,idx,idx2] = nextp(x,op,blk,idx,idx2,length(x));
%    C(jj,:) = x;
% end

if op<K
    np = op + 1; % Index of where the 1 goes.
    x(op) = x(np);  % Here we are just doing the switcheroo on adjacents. 
    x(np) = 1;  % np is the current position of the 1.
    op = np;  % op is the old position of the 1, for next time.
    return
else
    x(K) = x(1);  % Here we are switching the endpoints of the vect.
    x(1) = 1;
    op = 1;  % Reset to the first position.
    blk = blk + 1;  % Keep track of this block. Reset every N*(N-1)th call.

    if blk<K % Not through with this block yet.
        return
    end

    blk = 1;  % If here, we need to mix internal elements of the vect.
    low = 2;  % Start with the second element.
    upp = K - 1;  % And the next to last element.

    while true  % We always break this loop.  
        % In here, on every N*(N-1)th call, we are mixing internal elems.
        % The number of times through the while loop is usually very small,
        % even for large N most calls will go through less than 3 times.  
        cur = idx(low);  % Holds the current index to switch.

        if cur==upp
            np = low;
            idx2(low) = idx2(low) + 1;
        else
            np = cur + 1;  % For next iter.
        end

        tmp = x(cur);  % Switcheroo.
        x(cur) = x(np);
        x(np) = tmp;
        idx(low) = np;

        if idx2(low)<upp
            break  % Out of while loop, we've mixed them enough.
        end

        idx2(low) = low;
        low = low + 1; % These two march towards each other.
        upp = upp - 1;
    end
end
end