function defaultOptions = prtOptionsGetFactory()
% prtOptionsGetFactory  Get the factory options for the PRT
%   PRT factory options are hard coded in MATLAB class m files stored
%   within the prtOptions package. prtOptionsGetFactory returns a structure
%   with each of these classes loaded into a structure with field names
%   equal to the class names
%
%   defaultOptions = prtOptionsGetFactory()
%
% See also. prtOptionsGet, prtOptionsSet, prtOptionsSetDefault







optionsPackageInfo = meta.package.fromName('prtOptions');

if isempty(optionsPackageInfo)
    error('Package prtOptions was not found on path');
end

for iClass = 1:length(optionsPackageInfo.Classes)
    defaultOptions.(strrep(optionsPackageInfo.Classes{iClass}.Name,'prtOptions.','')) = feval(optionsPackageInfo.Classes{iClass}.Name);
end
