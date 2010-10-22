function varargout = prtUtilUitabgroup(varargin)

out = cell(nargout,1);

if verLessThan('matlab', '7.11')
    [out{:}] = uitabgroup('v0',varargin{:});
else
    [out{:}] = uitabgroup(varargin{:});
end

varargout = {};
if nargout
    varargout = out;
end