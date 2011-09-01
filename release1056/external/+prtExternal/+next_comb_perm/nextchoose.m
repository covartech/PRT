function C = nextchoose(N,K)
%NEXTCHOOSE Loop through combinations without replacement.
% NEXTCHOOSE(N,K), when first called, returns a function handle.  This  
% function handle, when called, returns the next combination without 
% replacement of K elements taken from the set 1:N. This can be useful
% when the number of such combinations is too large to hold in memory at
% once.  If the number of such combinations is not too large, use 
% COMBINATOR(N,K,'c') (on the FEX) instead.
%
% The number of combinations with replacement is:  N!/(K!(N-K)!);
%   where N >= 1, N >= K >= 0
%
% Examples:
%
%     % To use each combination one at a time, put it in a loop.
%     N = 4;  % Length of the set.
%     K = 3;  % Number of samples taken for each sampling.
%     H = nextchoose(N,K);
%     for ii = 1:(prod(1:N)/(prod(1:(N-K)) * prod(1:K)))
%         A = H();
%         % Do stuff with A: use it as an index, etc.
%     end
%
%
%     % To build all of the combinations, do this (See note below):
%     ROWS = prod(1:N)/(prod(1:(N-K)) * prod(1:K));
%     C = ones(ROWS,K);
%     for ii = 1:ROWS
%         C(ii,:) = H();
%     end
%     %Note this is a lot slower than using combinator(N,K,'c')
%
% The function handle will cycle through when the final combination is
% returned.
%
% See also,  nchoosek, perms, combinator, npermutek (both on the FEX)
%
% Author:   Matt Fig
% Contact:  popkenai@yahoo.com
% Date: 6/9/2009
% Reference:  http://mathworld.wolfram.com/BallPicking.html

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

lim = K;    % Sets the limit for working index.
inc = 1;    % Controls which element of A is being worked on.

if K > N/2
    WV = N-K; % We will re-use WV below. This is for calculating cycle.
else
    WV = K;
end

BC = prod(1:N)/(prod(1:(N-WV)) * prod(1:WV)) - 1;
CNT = 0;  % Tells us when to restart.
WV = [];  % Initial WV, the working vector for looping.  
C = @nestfunc;  % Handle to nested function.

    function B = nestfunc()
    % The user is passed a handle to this function.
        if CNT==0
            WV = 1:K;  % The first vector.
            B = WV;  % Return value
            CNT = 1;  % Increment the counter.
            return
        end
         
        if CNT == BC;
            B = (N-K+1):N;  % The final vector, reset other vals.
            CNT = 0;
            inc = 1;            
            lim = K;
            return
        end
        
        for jj = 1:inc
           WV(K + jj - inc) = lim + jj; % WV(K-inc+1:K) = lim+1:lim+inc;
        end

        if lim<(N-inc)
            inc = 0;
        end

        inc = inc+1;  % Increment the indexer.
        lim = WV(K+1-inc);  % lim for next run.
        CNT = CNT + 1;  % Increment the counter.
        B = WV;  % Return argument.
    end
end