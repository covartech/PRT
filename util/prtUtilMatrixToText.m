function textStr = prtUtilMatrixToText(matrix,varargin)
% textStr = prtUtilMatrixToText(matrix,varargin)
% 

p = inputParser;
p.addParamValue('varName','unknown');
p.addParamValue('printfSpec','%d');
p.parse(varargin{:});
res = p.Results;

textStr = sprintf('name = %s\r\n',res.varName);
textStr = cat(2,textStr,sprintf('nDims = %d\r\n',ndims(matrix)));
textStr = cat(2,textStr,sprintf('matSize = %s\r\n',mat2str(size(matrix))));

matrixStr = sprintf('%d ',matrix(:));
textStr = cat(2,textStr,sprintf('variable = %s\r\n\r\n',matrixStr));