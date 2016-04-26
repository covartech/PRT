function [contextDataSet,classificationDataSet] = prtDataGenContextDependent







contextDataSet = prtDataGenBimodal(400);
kmeans = prtClusterKmeans('nClusters',4);
kmeans = train(kmeans,contextDataSet);

yOut = kmeans.run(contextDataSet);

labels = yOut.getObservations;
for i = 1:size(labels,2)
    currDataInd = find(yOut.X(:,i));
    
    i1 = randn < 0;
    if i1 == 0
        i1 = -1;
    end
    
    mu1 = [1 1] * i1;
    mu0 = -mu1;
    
    rvH1 = prtRvMvn('mu',mu1,'sigma',eye(2));
    rvH0 = prtRvMvn('mu',mu0,'sigma',eye(2));
    nSamples1 = floor(length(currDataInd)/2);
    nSamples0 = ceil(length(currDataInd)/2);
    
    x(currDataInd,:) = cat(1,rvH0.draw(nSamples0),rvH1.draw(nSamples1));
    y(currDataInd,1) = prtUtilY(nSamples0,nSamples1);
end
classificationDataSet = prtDataSetClass(x,y);

end
