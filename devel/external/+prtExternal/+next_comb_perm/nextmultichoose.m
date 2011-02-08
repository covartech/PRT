function C = nextmultichoose(N,K)
%NEXTMULTICHOOSE Loop through combinations with replacement.
% NEXTMULTICHOOSE(N,K), when first called, returns a function handle.  This  
% function handle, when called, returns the next combination with 
% replacement of K elements taken from the set 1:N. This can be useful
% when the number of such combinations is too large to hold in memory at
% once.  If the number of such combinations is not too large, use 
% COMBINATOR(N,K,'c','r') (on the FEX) instead.
%
% The number of combinations with replacement is: (N+K-1)!/(K!(N-1)!)
%   where N >= 1, K >= 0
% Examples:
%
%     % To use each combination one at a time, put it in a loop.
%     N = 4;  % Length of the set.
%     K = 3;  % Number of samples taken for each sampling.
%     H = nextmultichoose(N,K);
%     for ii = 1:(prod((N):(N+K-1))/(prod(1:K)))
%         A = H();
%         % Do stuff with A: use it as an index, etc.
%     end
%
%
%     % To build all of the combinations, do this (See note below):
%     ROWS = prod((N):(N+K-1))/(prod(1:K));
%     C = ones(ROWS,K);
%     for ii = 1:ROWS
%         C(ii,:) = H();
%     end
%     %Note this is a lot slower than using combinator(N,K,'c','r')
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

if isempty(N) || K == 0
   C = [];  
   return
elseif numel(N)~=1 || N<=0 || ~isreal(N) || floor(N) ~= N 
    error('N should be one real, positive integer. See help.')
elseif numel(K)~=1 || K<0 || ~isreal(K) || floor(K) ~= K
    error('K should be one real non-negative integer. See help.')
end

WV = [];  % Initializer for nested func.
BC = prod(N:(N+K-1))/prod(1:K);  % Tells us when to start over.
CNT = 0; % Initializer for nested func.
C = @nestfunc;  % Return argument is a func handle.

    function B = nestfunc()
    % The user is passed a handle to this function.  
        if CNT==0 || CNT==BC  % Here we are starting over and at the end.
            WV = ones(1,K);  
            B = WV;
            CNT = 1;
            return
        end
        
        if WV(K) == N
            cnt = K-1;  % Work backwards in WV.

            while WV(cnt) == N
                cnt = cnt-1;  % Work backwards in WV.
            end

            WV(cnt:K) = WV(cnt) + 1;  % Fill forward.
        else
            WV(K) = WV(K)+1;   % Keep working in this group.
        end

        CNT = CNT+1;
        B = WV;
    end
end
