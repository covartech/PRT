function defaultOptions = prtOptionsGetDefault()

optionsPackageInfo = meta.package.fromName('prtOptions');

for iClass = 1:length(optionsPackageInfo.Classes)
    defaultOptions.(strrep(optionsPackageInfo.Classes{iClass}.Name,'prtOptions.','')) = feval(optionsPackageInfo.Classes{iClass}.Name);
end