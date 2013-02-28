function C = prtUtilNextChoose(N,K)
%prtUtilNextChoose Loop through combinations without replacement.
% prtUtilNextChoose(N,K), when first called, returns a function handle.  This  
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
%     H = prtUtilNextChoose(N,K);
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

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


% This function is a modification of the matlab central submission
%   next_comb_perm. See prtExtrenal.next_comb_perm.*   
%
% The license information for that file below
%
% Copyright (c) 2009, Matt Fig
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.


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

%BC = prod(1:N)/(prod(1:(N-WV)) * prod(1:WV)) - 1;
BC = round(prod(1:N)/(prod(1:(N-WV)) * prod(1:WV)) - 1); 

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
         
        if CNT >= BC;
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
