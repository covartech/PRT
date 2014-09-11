%% Determining Gender from Handwriting - A Kaggle Competition
% 
% Hi everyone, today I wanted to introduce a new data set and some
% preliminary processing that helps us perform better than a random forest
% (gasp!).  
%  
% The data we're going to use is from a Kaggle competition that's going on
% from now (March 28, 2013) until April 15, 2013.  
clear all;
close all;
[dsTrain,dsTest] = prtDataGenTextGender;

folds = prtUtilEquallySubDivideData([dsTrain.observationInfo.writerId],3);

%% Naive Random Forest

yOut = kfolds(prtClassTreeBaggingCap,dsTrain,3);
logLossInitialRf = prtScoreLogLoss(yOut);

%% Remove Meaningless features

fprintf('There are %d features that only take one value... \n',length(find(all(dsTrain.X == 0))));
removeFeats = all(dsTrain.X == 0);
dsTrainRemove = dsTrain.removeFeatures(removeFeats);
dsTestRemove = dsTest.removeFeatures(removeFeats);

%% Slight improvement
yOutRf = kfolds(prtClassTreeBaggingCap,dsTrainRemove,3);
logLossRf = prtScoreLogLoss(yOutRf);

%% Accumulate (mean) over the same people, to get a decent score
xOutAccum = accumarrayLike([dsTrainRemove.observationInfo.writerId]',yOutRf.X,[],@(x)mean(x));
yOutAccum = accumarrayLike([dsTrainRemove.observationInfo.writerId]',yOutRf.Y,[],@(x)unique(x));
yOutAccum = prtDataSetClass(xOutAccum,yOutAccum);
logLossAccum = prtScoreLogLoss(yOutAccum);

%% Split it up into English and Arabic?  Surprisingly, no help!
dsEng = dsTrainRemove.select(@(s)strcmpi(s.language,'English'));
dsAra = dsTrainRemove.select(@(s)strcmpi(s.language,'Arabic'));
yOutEng = kfolds(prtClassTreeBaggingCap,dsEng,3);
yOutAra = kfolds(prtClassTreeBaggingCap,dsAra,3);

dsFull = catObservations(yOutEng,yOutAra);
xOutAccum = accumarrayLike([dsFull.observationInfo.writerId]',dsFull.X,[],@(x)mean(x));
yOutFull = accumarrayLike([dsFull.observationInfo.writerId]',dsFull.Y,[],@(x)unique(x));
yOutFull = prtDataSetClass(xOutAccum,yOutFull);
logLossEnglish = prtScoreLogLoss(yOutEng);
logLossArabic = prtScoreLogLoss(yOutAra);
logLossFused = prtScoreLogLoss(yOutFull);

%% Let's optimize # of PLSDA components

nIter = 10;
maxComp = 30;
logLossPlsda = nan(maxComp,nIter);
logLossPlsdaAccum = nan(maxComp,nIter);
for nComp = 1:maxComp;
    classifier = prtClassPlsda('nComponents',nComp) + prtClassLogisticDiscriminant;
    for iter = 1:nIter
        yOutPlsda = kfolds(classifier,dsTrainRemove,3);
        logLossPlsda(nComp,iter) = prtScoreLogLoss(yOutPlsda);
        
        xOutAccum = accumarrayLike([dsTrainRemove.observationInfo.writerId]',yOutPlsda.X,[],@(x)mean(x));
        yOutAccum = accumarrayLike([dsTrainRemove.observationInfo.writerId]',yOutPlsda.Y,[],@(x)unique(x));
        yOutAccum = prtDataSetClass(xOutAccum,yOutAccum);
        logLossPlsdaAccum(nComp,iter) = prtScoreLogLoss(yOutAccum);
    end
end

%% Plotting (Non-Accumulated)
boxplot(logLossPlsda')
hold on; 
h2 = plot(1:maxComp,repmat(logLossInitialRf,1,maxComp),'k:',1:maxComp,repmat(logLossRf,1,maxComp),'b:');
hold off;
legend(h2,{'Random Forest Log-Loss','Random Forest - Removed Features'});
h = findobj(gca,'type','line');
set(h,'linewidth',2);
xlabel('#PLSDA Components');
ylabel('Log-Loss');
title('Log-Loss For PLSDA (vs. # Components) and Random Forest')

%% Plotting (Accumulated)

boxplot(logLossPlsdaAccum')
hold on; 
h2 = plot(1:maxComp,repmat(logLossInitialRf,1,maxComp),'k:',1:maxComp,repmat(logLossRf,1,maxComp),'b:',1:maxComp,repmat(logLossAccum,1,maxComp),'g:');
hold off;
legend(h2,{'Random Forest Log-Loss','Random Forest - Removed Features','Random Forest - Removed Features - Accum'});
h = findobj(gca,'type','line');
set(h,'linewidth',2);
xlabel('#PLSDA Components');
ylabel('Log-Loss');
title('Log-Loss For PLSDA With Accumumation (vs. # Components) and Random Forest')

%% Let's Run It !

% Training data:
classifier = prtClassPlsda('nComponents',17) + prtClassLogisticDiscriminant;
classifier = classifier.train(dsTrainRemove);
yOutPlsdaKfolds = classifier.kfolds(dsTrainRemove,3);

xOutAccum = accumarrayLike([dsTrainRemove.observationInfo.writerId]',yOutPlsdaKfolds.X,[],@(x)mean(x));
yOutAccum = accumarrayLike([dsTrainRemove.observationInfo.writerId]',yOutPlsdaKfolds.Y,[],@(x)unique(x));
yOutAccum = prtDataSetClass(xOutAccum,yOutAccum);
logLossPlsdaEstimate = prtScoreLogLoss(yOutAccum)

% Testing
yOut = classifier.run(dsTestRemove);

[xOutAccumSplit,uLike] = accumarrayLike([dsTestRemove.observationInfo.writerId]',yOut.X,[],@(x)mean(x));
matrixOut = cat(2,uLike,xOutAccumSplit);
csvwrite('outputPlsda.csv',matrixOut);


%%

%classifier = prtPreProcPca('nComponents',30) + prtClassGlrt + prtClassLogisticDiscriminant;
%classifier = prtPreProcPca('nComponents',100) + prtClassMatlabNnet + prtClassLogisticDiscriminant;
classifier = prtClassPlsda('nComponents',17) + prtClassLogisticDiscriminant;
classifier = classifier.train(dsTrainRemove);
yOutClass = classifier.kfolds(dsTrainRemove,3);

xOutAccum = accumarrayLike([dsTrainRemove.observationInfo.writerId]',yOutClass.X,[],@(x)mean(x));
yOutAccum = accumarrayLike([dsTrainRemove.observationInfo.writerId]',yOutClass.Y,[],@(x)unique(x));
yOutAccum = prtDataSetClass(xOutAccum,yOutAccum);
logLossClassifier = prtScoreLogLoss(yOutAccum)


%% This takes... forever
warning off;
c = prtClassPlsda('nComponents',17,'showProgressBar',false);
sfs = prtFeatSelSfs('nFeatures',100,'evaluationMetric',@(ds)-1*prtEvalLogLoss(c,ds,2));
sfs = sfs.train(dsTrainRemove);

%%
load sfs.mat sfs
plot(-sfs.performance)

%%

logLossClassifierFeatSel = nan(100,10);
for nFeats = 1:100;
    for iter = 1:10
        dsTrainRemoveFeatSel = dsTrainRemove.retainFeatures(sfs.selectedFeatures(1:nFeats));
        yOutPlsdaFeatSel = classifier.kfolds(dsTrainRemoveFeatSel,3);
        
        xOutAccum = accumarrayLike([dsTrainRemove.observationInfo.writerId]',yOutPlsdaFeatSel.X,[],@(x)mean(x));
        yOutAccum = accumarrayLike([dsTrainRemove.observationInfo.writerId]',yOutPlsdaFeatSel.Y,[],@(x)unique(x));
        yOutAccumFeatSel = prtDataSetClass(xOutAccum,yOutAccum);
        logLossClassifierFeatSel(nFeats,iter) = prtScoreLogLoss(yOutAccumFeatSel);
    end
    boxplot(logLossClassifierFeatSel')
    drawnow;
end

ylabel('Log-Loss');
xlabel('# Features')
title('Log-Loss vs. # Features')

%% Adding in some post-processing

%% Run the New Version:

[minVal,nFeatures] = min(mean(logLossClassifierFeatSel'));
dsTrainTemp = dsTrainRemove.retainFeatures(sfs.selectedFeatures(1:nFeatures));
dsTestTemp = dsTestRemove.retainFeatures(sfs.selectedFeatures(1:nFeatures));

classifier = prtClassPlsda('nComponents',17) + prtClassLogisticDiscriminant;
classifier = classifier.train(dsTrainRemove);
yOutPlsdaKfolds = classifier.kfolds(dsTrainRemove,3);


xOutAccum = accumarrayLike([dsTrainRemove.observationInfo.writerId]',yOutPlsdaKfolds.X,[],@(x)mean(x));
yOutAccum = accumarrayLike([dsTrainRemove.observationInfo.writerId]',yOutPlsdaKfolds.Y,[],@(x)unique(x));
yOutAccum = prtDataSetClass(xOutAccum,yOutAccum);
yOutPostLogDisc = kfolds(prtClassLogisticDiscriminant,yOutAccum,3);
postLogDisc = train(prtClassLogisticDiscriminant,yOutAccum);
logLossPlsdaEstimate = prtScoreLogLoss(yOutPostLogDisc)

% Testing
yOut = classifier.run(dsTestRemove);
[xOutAccumSplit,uLike] = accumarrayLike([dsTestRemove.observationInfo.writerId]',yOut.X,[],@(x)mean(x));
dsTestPost = prtDataSetClass(xOutAccumSplit);
yOutPost = postLogDisc.run(dsTestPost);

matrixOut = cat(2,uLike,yOutPost.X);
csvwrite('outputPlsda_FeatSelPostProc.csv',matrixOut);
