classdef prtParameterSpecIntPos < prtParameterSpec
    properties
        name = 'undefined';
        description = 'undefined';
    end
    
    properties (SetAccess=protected)
        type = 'integerPositive'
    end
    
    methods 
        function Obj = prtParameterSpecIntPos(varargin)
            
        end
        function [isOk, message] = check(ParamSpecObj,value,ParentObj)
            isOk = false;
            message = 'Not Done Yet';
        end
        function uicHandle = makeUicontrol(varargin)
            uicHandle = uicontrol('text');
        end
    end
end