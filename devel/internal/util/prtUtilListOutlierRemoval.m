% 
% See also: prtOutlierRemoval, prtOutlierRemovalMissingData,
% prtOutlierRemovalNStd, prtOutlierRemovalNonFinite,

g = subDir(fullfile(prtRoot,'outlierremoval'),'*.m');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
