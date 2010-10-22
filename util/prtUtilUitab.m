function varargout = prtUtilUitab(varargin)

out = cell(nargout,1);

if verLessThan('matlab', '7.11')
    [out{:}] = uitab('v0',varargin{:});
else
    [out{:}] = uitab(varargin{:});
end

varargout = {};
if nargout
    varargout = out;
end