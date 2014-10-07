function obj = prtUiSubplot(inputSpec,constructorFun)
% obj = prtUiSubplot(varargin)
%
% obj = prtUiSubplot({{subplot one inputs}, {subplot two inputs},...},{prtGuiManagerAxesType1, prtGuiMangerAxesType2,...});
% obj = prtUiSubplot([2,2,1:2],prtUiManagerAxesType1);
% obj = prtUiSubplot([2,2],prtUiManagerAxesType1);

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


obj = prtUiManagerMultiAxes;

if nargin < 2 || isempty(constructorFun)
    constructorFun = @prtUiManagerPlot;
end

if iscell(inputSpec)
    if ~iscell(constructorFun)
        constructorFun = repmat({constructorFun},length(inputSpec));
        assert(isa(constructorFun,'function_handle'),'constructorFun must be a function handle');
    else
        assert(length(constructorFun)==length(inputSpec),'length of specified prtGuiManager*s must match the number of specified subplots');
        assert(isa(constructorFun{1},'function_handle'),'constructorFun must be or contain a function handle');
    end
    
    nAxes = length(inputSpec);
    for iAxes = 1:nAxes
        cInputSpec = inputSpec{iAxes};
        
        if iscell(cInputSpec)
            assert(length(cInputSpec)==3,'prtUiSubplot inputs must be a cell');
            axesManagers(iAxes) = constructorFun{iAxes}('managedHandle',subplot(cInputSpec{1},cInputSpec{2},cInputSpec{3}, 'parent', obj.managedHandle)); %#ok<AGROW>
        else
            assert(prtUtilIsPositiveInteger(cInputSpec) & numel(cInputSpec)==3,'prtUiSubplot inputs must be a cell or a length(3) vector of positive integers');
            axesManagers(iAxes) = constructorFun{iAxes}('managedHandle',subplot(cInputSpec(1),cInputSpec(2),cInputSpec(3), 'parent', obj.managedHandle)); %#ok<AGROW>
        end
    end
else
    assert(prtUtilIsPositiveInteger(inputSpec) & ismember(numel(inputSpec),[2 3]),'prtUiSubplot inputs must be vector of positive integers');
    
    if ~iscell(constructorFun)
        assert(length(constructorFun)==1,'length of specified prtGuiManager*s must match the number of specified subplots');
    end
    
    switch numel(inputSpec)
        case 2
            nAxes = prod(inputSpec);
            if iscell(constructorFun)
                assert(numel(constructorFun)==nAxes,'length of specified prtGuiManager*s must match the number of specified subplots');
            end
            for iAxes = 1:nAxes
                if iscell(constructorFun)
                    cConstructorFun = constructorFun{iAxes};
                else
                    cConstructorFun = constructorFun;
                end
                
                axesManagers(iAxes) = cConstructorFun('managedHandle',subplot(inputSpec(1),inputSpec(2),iAxes, 'parent', obj.managedHandle)); %#ok<AGROW>
            end
            
        case 3
            axesManagers = constructorFun('managedHandle', subplot(inputSpec(1), inputSpec(2), inputSpec(3), 'parent', obj.managedHandle));
    end
end

obj.axesManagers = axesManagers;
