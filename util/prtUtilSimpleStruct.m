function s = prtUtilSimpleStruct(varargin)
%s = prtUtilSimpleStruct(varargin)
%s = prtUtilSimpleStruct('asdf',randn(100,1),'fff',randn(100 q,1))
%s = prtUtilSimpleStruct('asdf',randn(100,1),'fff',randn(100,1),'asfsadf',prtUtilCellPrintf('%s',num2cell(1:100)'))

% fields = varargin(1:2:end);
% vals = varargin(2:2:end);

structInput = cell(1,length(varargin));
for i = 1:2:length(varargin)
    cField = varargin{i};
    cVal = varargin{i+1};
    assert(isvarname(cField),'can not create struct with a field named %s',cField);
    
    if iscellstr(cVal)
        %ok
    else
        cVal = mat2cell(cVal,ones(size(cVal,1),1),size(cVal,2));
    end
    
    structInput(i:i+1) = {cField,cVal};
end
s = struct(structInput{:});