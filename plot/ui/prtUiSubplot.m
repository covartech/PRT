function obj = prtUiSubplot(inputSpec,constructorFun)
% obj = prtUiSubplot(varargin)
%
% obj = prtUiSubplot({{subplot one inputs}, {subplot two inputs},...},{prtGuiManagerAxesType1, prtGuiMangerAxesType2,...});
% obj = prtUiSubplot([2,2,1:2],prtUiManagerAxesType1);
% obj = prtUiSubplot([2,2],prtUiManagerAxesType1);







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
