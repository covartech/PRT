% 
% See also: prtClass, prtClassAdaBoost, prtClassBagging,
% prtClassBinaryToMaryOneVsAll, prtClassBumping, prtClassCap, prtClassDlrt,
% prtClassFld, prtClassGlrt, prtClassKmeansPrototypes, prtClassKmsd,
% prtClassKnn, prtClassLibSvm, prtClassLogisticDiscriminant, prtClassMap,
% prtClassMatlabNnet, prtClassMatlabTreeBagger, prtClassNaiveBayes,
% prtClassPlsda, prtClassRvm, prtClassRvmFigueiredo, prtClassRvmSequential,
% prtClassSvm, prtClassTreeBaggingCap

g = subDir(fullfile(prtRoot,'class'),'*.m');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
