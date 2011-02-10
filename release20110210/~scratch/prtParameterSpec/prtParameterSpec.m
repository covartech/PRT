classdef prtParameterSpec
    properties (Abstract)
        name
        description
    end
    properties(Abstract, SetAccess=protected)
        type
    end
    
    methods (Abstract)
        [isOk, message] = check(ParamSpecObj,value,ParentObj);
        uicHandle = makeUicontrol(varargin);
    end
end