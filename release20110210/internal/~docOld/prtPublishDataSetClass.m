%% prtDataSetClass
% 
% The PRT stores information regarding data sets with samples from multiple
% distinct classes in objects of type prtDataSetClass.  A prtDataSetClass
% object contains all the information and methods necessary to perform
% basic data analysis, visualization, and modification in one conciese
% package.  There are a number of ways to generate a prtDataSetClass; we
% can use prtDataGen functions, i.e. 

clear all;
ds = prtDataGenUnimodal;

%%
% Or we can manually specify the data we'd like to use, and the class
% labels (targets).  We can load some example data using a .MAT file that
% ships with the PRT like so:

clear ds;
load prtExampleDataLabels.mat data labels
whos

%%
% From this we can see that data is a 400 x 2 matrix, and labels is a 400 x
% 1 vector of class labels.  In the PRT, rows always correspond to
% observations, and columns always correspond to features, so the data matrix is a
% 400 observation x 2 feature matrix.  Note that the number of observations
% in the targets matches the number of observations in the data.  
%
% PRT labels (also called "targets") are always vectors of integer valued 
% class labels.  In this case, the labels take values 0 and 1 corresponding
% to the null hypothesis (H_{0}) and the class of interest (H_{1}). 
%
% If we have a data and labels matrices, we can always create a data set 
% class by providing the data and labels as the first two input arguments 
% to the prtDataSetClass constructor:

ds = prtDataSetClass(data,labels);
disp(ds);

%%
% From the disp() statement we can see that the data set we've created has
% 2 classes, is binary (has 2 classes), the two classes take values 0 and 1
% (isZeroOne is true), there are 400 observations and 2 features in the
% data set, and the number of target dimensions is one (don't worry about
% this for now).  
%
% Before we go any further, let's plot the newly created data set and see 
% how our data is distributed:

plot(ds);

%% Feature, Observation, DataSet, and Class Names
%
% When we plotted the data set above, the figure that appeared used some
% generic names for the feature dimensions, the dataset and class names.
% We can change this behavior of the prt by setting various fields of the
% data set to have the correct values.  Most user-settable fields of
% prtDataSet objects can be set using "parameter-value-pair" additional
% input arguments to object constructors.  This basically means, after the
% data and labels, use:
%
% prtDataSetClass(...,'field1Name',field1Value,'field2Name',field2Value,...)
%
% To set fields of the prtDataSet object.  For example, let's say that
% we're measuring widgets to see if they pass quality control, and our
% feature measurements are "length" and "width".  Furthermore, we work for
% ACME widget supply, and our classes are "good widget" and "bad widget".
% We'll use a mixture of the constructor and set/get methods to make our
% data set have the correct names:

load prtExampleDataLabels.mat data labels
ds = prtDataSetClass(data,labels,'name','ACME Widget Experiment 1','featureNames',{'length','width'});
ds = ds.setClassNames({'bad widget','good widget'});
plot(ds);

%%
% Now note that our plot displays all the information for our data set 
% correctly.  If we have information about our 400 individual observations, 
% we can also set them using setObservationNames.
%
% You can also get access to these names using the get*Names methods
% (these return default values if the values were not set by the user).
% For example:
%
% 
load prtExampleDataLabels.mat data labels
ds = prtDataSetClass(data,labels);
disp(ds.getFeatureNames)     %Default values
ds = prtDataSetClass(data,labels,'name','ACME Widget Experiment 1','featureNames',{'length','width'});
disp(ds.getFeatureNames)      %User defined values

%% Accessing the data and targets
%
% If you take a look at the properties of the prtDataSetClass we made so
% far, you'll notice that there is no field or property names "data", and
% no field or property names "labels".  There are two reasons for this.  1)
% Internally we refer to "data" as "observations" and "labels" as
% "targets", and 2) Access to the observations and targets properties is
% restricted, and only possible through the methods get*,set*,retain*,
% remove*, and replace* where * is one of "Observations" or "Targets". 
%
% There are a number of reasons for hiding the observations and targets
% properties from the user, but the most important is that this leaves
% different prtDataSetClass objects free to implement access functions in
% their own ways.  In other words, someone might write a prtDataSet object
% that inherits from prtDataSetClass but that keeps all of it's
% observations and targets in .MAT files to save mempory.  That's OK,
% because the author of that class will write the get*, set*, etc.
% functions to handle the files properly, and you will never have to know
% the difference since you can only access observations and targets through
% the get*, set*, etc. functions.
%
% Let's take a look at some of those functions and their usage:
%

feature1 = ds.getFeatures(1);  %this returns the first column of observations
bothFeatures = ds.getFeatures(1:2); %both columns of observations

%Get the even observations and targets:
evenObservations = ds.getObservations(1:2:ds.nObservations);
evenTargets = ds.getTargets(1:2:ds.nObservations);

%% 
%We can also use retain and remove to build new data sets out of our
%current data sets; note that these retain the feature names, class names,
%etc. from the original data set "ds"

dsEvenSamples = ds.retainObservations(1:2:ds.nObservations);
dsEvenSamples.name = 'Even Samples';
dsOddSamples = ds.removeObservations(1:2:ds.nObservations);
dsOddSamples.name = 'Odd Samples';

subplot(2,2,1:2); ds.plot; V = axis;
subplot(2,2,3); dsEvenSamples.plot; axis(V);
subplot(2,2,4); dsOddSamples.plot;  axis(V);

%% Other methods
%
% There are a great number of other ways to access a prtDataSetClass.  Take
% a look at the output of methods() called on a prtDataSetClass to see
% what's available, and then use matlab's commands:
%
% >>help prtDataSetClass
%
% or
%
% >>doc prtDataSetClass
%
% For more information

methods(ds)
