function varargout = prtUiPlot(varargin)
% obj = prtUiPlot(input, arguments, to, plot, ...)
%   obj is a prtUiPlotManager







obj = prtUiManagerPlot;
obj.plot(varargin{:});

if nargout
    varargout = {obj};
else
    varargout = {};
end
