function alloc = prtUtilPreAllocateHandles(varargin)
%alloc = prtUtilPreAllocateHandles(varargin)
%   Call either "zeros(varargin{:})" or "gobjects(varargin{:})" depending
%   on your MATALB version.
%

if verLessThan('matlab','8.4')
    alloc = zeros(varargin{:});
else    
    alloc = gobjects(varargin{:});
end
    