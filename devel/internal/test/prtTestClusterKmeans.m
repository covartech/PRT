function result = prtTestClusterKmeans
result = true;

% BASELINE generation, uncomment to run to generate new baseline
% Run numIter times to get idea distribution of percentage
% Pick off the lowest % correct and use that as baseline
% numIter = 1000;
% percentCorr = zeros(1,numIter);
% for i = 1:numIter
%     TestDataSet = prtDataGenMary;
%     TrainingDataSet = prtDataGenMary;
% 
%     cluster = prtClusterKmeans;
%     cluster = cluster.train(TrainingDataSet);
%     classified = run(cluster, TestDataSet);
%     classes  = classified.getX;
%     percentCorr(i) = prtScorePercentCorrect(classes,TestDataSet.getTargets);
% end
% min(percentCorr)


%% Classification correctness test.
baselinePercentCorr = .7400;

TestDataSet = prtDataGenMary;
TrainingDataSet = prtDataGenMary;

cluster = prtClusterKmeans;
cluster = cluster.train(TrainingDataSet);
classified = run(cluster, TestDataSet);

[garbage,classInds] = max(classified.getX(),[],2);
classes = TestDataSet.uniqueClasses(classInds);

percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

result = result & (percentCorr > baselinePercentCorr);
if (percentCorr < baselinePercentCorr)
    disp('prtClusterKmeans below baseline')
    result = false;
end


%% Check that cross-val and k-folds work

TestDataSet = prtDataGenMary;

cluster = prtClusterKmeans;

% cross-val
keys = mod(1:300,2);
crossVal = cluster.crossValidate(TestDataSet,keys);
[garbage,classInds] = max(crossVal.getX(),[],2);
classes = TestDataSet.uniqueClasses(classInds);
percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

if (percentCorr < baselinePercentCorr)
    disp('prtClusterKmeans cross-val below baseline')
    result = false;
end

% k-folds

crossVal = cluster.kfolds(TestDataSet,10);
[garbage,classInds] = max(crossVal.getX(),[],2);
classes = TestDataSet.uniqueClasses(classInds);

percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
if (percentCorr < baselinePercentCorr)
    disp('prtClusterKmeans kfolds below baseline')
    result = false;
end



%% Error checks

error = true;  % We will want all these things to error



%% Object construction
% We want these to be non-errors
noerror = true;

try
    cluster = prtClusterKmeans('nClusters', 4);
catch
    noerror = false;
    disp('kmeans cluster param/val fail')
end

try
    TestDataSet = prtDataGenMary;
    TrainingDataSet = prtDataGenMary;
    
    
    cluster = prtClusterKmeans;
    cluster = cluster.train(TrainingDataSet);
    cluster.plot();
    close
catch
    noerror = false;
    disp('k-means prototype plot fail')
    close
end
%%
result = result & error & noerror;
