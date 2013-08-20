%% Support Vector Machine Classification for Scientists & Engineers
% 
% In the mid-90's, support-vector machines became extremely populat machine
% learning algorithms due to a number of very nice properties, and because
% they can also acheive state-of-the-art performance on a number of data
% sets.
%
% Although the statistical underpinnings of why SVMs work rely on somewhat
% abstract statistical theory - e.g.,
% https://en.wikipedia.org/wiki/Vapnik%E2%80%93Chervonenkis_theory, modern
% statistical packages (like libSVM, and the PRT) make training and using
% SVM's almost trivial for the average engineer.
%
% That said, getting good performance out of an SVM is often not as easy as
% simply running pre-existing code on your data, and for some data-sets,
% SVM classification may not be appropriate.
%
% This blog entry will serve two purposes - 1) to provide an introduction
% to practical issues you (as an engineer or scientist) may encounter when
% using an SVM on your data, and 2) to be the first in a series of similar
% "for Engineers & Scientists" posts dedicated to helping engineers
% understand the tradeoffs and assumptions, and practical details of using
% various machine learning approaches on their data.
%

%% Quick Notes
% Thoughtout this post, we'll be using prtClassLibSvm, which is built
% directly on top of the fantastic LibSVM library, available here:
%
% http://www.csie.ntu.edu.tw/~cjlin/libsvm/
%
% The parameter nomenclature we're using matches theirs pretty closely, so
% feel free to leverage their documentation as well.

%% SVM Forumation
% Typical SVM formulations assume that you have a set of n-dimensional real
% training vectors, {x_i} for i = 1...N, and corresponding labels {y_i},
% y_i \in {-1,1}.  Let x_ik represent the k'th element of the vector x_i.
%
% Also assume that you have a relevant kernel function
% (https://en.wikipedia.org/wiki/Kernel_methods), P, which takes two input
% arguments, both n-dimensional real vectors, and outputs a scalar metric -
% P(x_i,x_j) = z_ij.  The most common choice of P is a radial basis
% function (http://en.wikipedia.org/wiki/Radial_basis_function):
%   P(x_i,x_j) = exp(- (\sum_{k} (x_ik-x_jk)^2 )/s^2 )
%
% SVMs perform prediction of new labels by calculating:
%
%  f(x) = \hat{y} = ( \sum_{i} (w_i*P(x_i,x) - b) ) > 0
%
% e.g., the SVM learns a representation for the labels (y) based on the
% data (x) with a linear combination (w) of a set of functions of the
% training data (x_i) and the test data (x).

%% Appropriate Data Sets
% Binary/M-Ary: Typically, SVMs are appropriate for binary classification problems -
% multi-class problems require some extensions of SVMs, although in the
% PRT, SVMs can be used in prtClassBinaryToMaryOneVsAll to emulate
% multi-class classification.
%
% Data: SVM formulations often assume vector-valued training data, however
% as long as a suitable kernel-function can be constructed, SVMs can be used
% on arbitrary data (e.g., string-match distances can be usned as a kernel
% for calculating the distances between character strings).  Note, however,
% that SVMs do assume that the kernel used is a Mercer kernel, so some
% functions are not appropriate as SVM kernels -
% http://en.wikipedia.org/wiki/Mercer's_theorem. 
%
% Computational Considerations: Depending on the kernel, and particular
% algorithm under consideration, training an SVM can be very time-consuming
% for very large data sets.  Proper selection of SVM parameters can
% significantly improve training time.  At run-time, SVMs are typically
% very fast, with computational complexity that grows approximately
% linearly with the size of the training data set.

%% SVM Parameters & Notes
% As you might imagine, several SVM parameters will have significant effect
% on overall classification performance.  Good performance requires careful
% selection of each of these; though some general rules-of-thumb can help
% provide reasonable performance with a minimum of headaches.

%% Parameter: Cost (Scalar)
% Internally, the SVM is going to try and ignore a whole bunch of your
% training data, by setting their corresponding w_i to zero.  This might
% sound counter-intuitive, but it's very important, because it makes for
% fast run-time, and also (it turns out) that setting a bunch of w's to
% zero is fundamental to why the SVM performs so well in general (see any
% number of articles on V-C Theory for more information).
%
% Unfortunately, this presents a dillema - how much should the SVM try and
% make w's zero vs. how mhuch should it try and classify your data
% absolutely perfectly?  More zero-w's might improve performance on the
% training set, but reduce the performance of the SVM on an unseen testing
% set!  
%
% The "Cost" parameter in the SVM enables you to control this trade off.
% Higher cost leads to more non-zero w' vectors, and more correctly
% classified training points, while lower costs tend to generate w vectors
% with lots of zeros, and slightly worse performance on training data
% (though performance on testing data may be better).  
%
% We usually run a number of experiments for different cost values across a
% range of, say 0.01 to 100, though if performance is plateauing it might
% make sense to extend this range.  The following figures show how the SVM
% decision boundaries change with varying costs in the PRT.
%

close all;
ds = prtDataGenUnimodal;
c = prtClassLibSvm;
count = 1; 
for w = logspace(-2,2,4); 
    c.cost = w;
    c = c.train(ds); 
    subplot(2,2,count); 
    plot(c); 
    legend off; 
    title(sprintf('Cost: %.2f',c.cost));
    count = count + 1; 
end

%% Parameter: Relative Class Error Weights
% In typical discussions of "cost", errors in both classes are treated
% equally - e.g., it's equally bad to call a "-1" a "1" and vice-versa.  In
% realistic operations, that may not be the case - for example, failing to
% detect a landmine, is significantly worse than calling a coke-can a
% landmine.  
%
% Luckily, SVMs enable us to specify class-specific error costs, so if
% class 1 has error cost of 1, and class -1 has an error cost of 100, it's
% 100x as bad to mistake a "-1" for a "1" as the opposite.
%
% LibSVM implements these class-specific weights using parameters called
% "w-1", "w1", etc.  In the PRT, these are implemented as a vector,
% weights.  The following example shows how the effects of changing the
% error weight on class 1 affects the overall SVM contours.  Clearly, as
% the cost on class 1 increases, the SVM spends more effort to correctly
% classify red elements.
close all;
c = prtClassLibSvm;
count = 1; 
for w = logspace(-1,1,4); 
    c.weight = [1 w];   %Class0: 1, Class1: w
    c = c.train(ds); 
    subplot(2,2,count); 
    plot(c); 
    legend off; 
    title(sprintf('Weight: [%.2f,%.2f]',c.weight(1),c.weight(2)));
    count = count + 1; 
end

%% Parameter: Kernel Choice & Associated Parameters
% The proper choice of kernel makes a huge difference in the resulting
% performance of your classifier.  We tend to stick with RBF and linear
% kernels (kernelType = 0 or 2 in prtClassLibSvm), but several other
% options (including hand-made kernels) are also possible.  The linear
% kernel doesn't have any parameters to set, but the RBF has a parameter
% that can significantly impact performance.  In most formulations, the
% parameter is referred to as sigma, but in LibSVM, the parameter is gamma,
% and it's equivalent to 1/sigma.  For the RBF, you can set it to any
% positive value.  You can also use the special character 'k', and specify
% a coefficient as a string.  'k' will evaluate to the number of features
% in the data set - e.g., '5k' evaluates to 10 for a 2-dimensional data
% set.
%
% In general, we find that for normalized data (see below), the default
% gamma value of 'k' (the number of dimensions) works well.
% 
% The following example code generates 4 example images for SVM decision
% boundaries for varying gamma parameters.
close all;
c = prtClassLibSvm;
count = 1; 
d = prtDataGenUnimodal;
for kk = logspace(-1,.5,4); 
    c.gamma = sprintf('%.2fk',kk);  
    c = c.train(d); 
    subplot(2,2,count);
    plot(c); 
    title(sprintf('\\gamma = %s',c.gamma));
    legend off; 
    count = count + 1;
end

%% SVM Pre-Prccessing
% Note that for many kernel choices (e.g., RBF, and many others, see
% http://en.wikipedia.org/wiki/Kernel_methods#Popular_kernels), the kernel
% output (P(x_i,x_j) depends strongly and non-linearly on the magnitudes of
% the data vectors.  E.g., exp(-1000) is not equal to 1000*exp(-1).  In
% fact, if you refer to the RBF equation above, you'll notice that if two
% elements of your vector have a difference approaching 1000, P(x1,x2) will
% be dominated by a term like exp(-1000), which by any reasonable metric
% (and certainly in floating point precision) is exactly 0.  This is a bad
% thing (tm).
%
% In general, non-linear kernel functions should only be applied to data
% that is guaranteed to be in a reasonable range (e.g., -10 to 10), or data
% that has been pre-processed to remove outliers or control for data
% magnitude.  The PRT pamkes several such techniques available - compare
% and contrast the performance in the following example:
%
close all;

ds = prtDataGenBimodal; 
ds.X = 100*ds.X; %scale the data

yOutNaive = kfolds(prtClassLibSvm,ds,3);
yOutNorm = kfolds(prtPreProcZmuv + prtClassLibSvm,ds,3);

[pfNaive,pdNaive] = prtScoreRoc(yOutNaive);
[pfNorm,pdNorm] = prtScoreRoc(yOutNorm);
h = plot(pfNaive,pdNaive,pfNorm,pdNorm);
set(h,'linewidth',3);
legend(h,{'Naive','Pre-Proc'});
title('ROC Curves for Naive and Pre-Processed Application of SVM to Bimodal Data');

%%
% Clearly, performance on un-normalized data is attrocious, but simple
% re-scaling acheives good results.

%% Optimizing Parameters
% The general procedure in developing an SVM is to optimize both the C and
% gamma parameters for your particular data set.  You can do this using two
% for-loops and the PRT:
close all;
gammaVec = logspace(-2,1,10);
costVec = logspace(-2,1,10);
ds = prtDataGenUnimodal;

auc = nan(length(gammaVec),length(costVec));
kfoldsInds = ds.getKFoldKeys(3);
for gammaInd = 1:length(gammaVec);
    for costInd = 1:length(costVec);
        c = prtClassLibSvm;
        c.cost = costVec(costInd);
        c.gamma = gammaVec(gammaInd);
        yOut = crossValidate(c,ds,kfoldsInds);
        auc(gammaInd,costInd) = prtScoreAuc(yOut);
        
        imagesc(auc,[.95 1]); 
        colorbar
        drawnow;
    end
end
title('AUC vs. Gamma Index (Vertical) and Cost Index (Horizontal)');

%% Some Rules-Of-Thumb
% In general, you may not have time or simply want to optimize over your
% SVM parameters.  In this case, you can usually get by using ZMUV
% pre-processing, and the default SVM parameters (RBF kernel, Cost = 1,
% gamma = 'k')

algo = prtPreProcZmuv + prtClassLibSvm; 

%% Concluding
% We hope this entry helps you make sense of how to use an SVM in
% real-world scenarios, and how to optimize the SVM parameters for your
% particular data set.  As always, proper cross-validation is fundamental
% to good generalizability.
%
% Happy coding.  