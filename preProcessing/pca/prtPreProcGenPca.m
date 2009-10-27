function PrtPreProcPca = prtPreProcGenPca(PrtDataSet,PrtOptPca)
%PrtPreProcPca = prtPreProcGenPca(DS,PrtOptPca)

PrtPreProcPca.PrtOptions = PrtOptPca;

X = PrtDataSet.getObservations;

nSamplesEmThreshold = 1000;
maxComponents = min(size(X));

if PrtOptPca.nComponents > maxComponents
    PrtOptPca.nComponents = maxComponents;
end
    
PrtPreProcPca.means = mean(X);
X = bsxfun(@minus,X,PrtPreProcPca.means);
% We no longer divide by the STD of each column to match princomp
% 30-Jun-2009 14:05:20    KDM
    
useHD = size(X,2) > size(X,1);
    
if useHD
    useEM = size(X,1) > nSamplesEmThreshold;
else
    useEM = false;
end

%Figure out whether to use regular, HD, or EM PCA:
if useHD
    if useEM
        [Xout, PrtPreProcPca.pcaVectors] = prtUtilPcaEm(X,PrtOptPca.nComponents);
        fprintf('why aren''t pca values calc''d here');
        PrtPreProcPca.TrainedParams.pcaValues = nan(PrtOptPca.nComponents,1); % It is possible to calculate these but no one every needs them right?
    else
        [Xout, PrtPreProcPca.pcaVectors, PrtPreProcPca.pcaValues] = prtUtilPcaHd(X,PrtOptPca.nComponents);
    end
else
    [PrtPreProcPca.pcaVectors,whoCares,whoCares,PrtPreProcPca.pcaValues] = prtUtilPca(X,PrtOptPca.nComponents);
end
    
