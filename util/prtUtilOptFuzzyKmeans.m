function Options = prtUtilOptFuzzyKmeans
%Options = prtUtilOptFuzzyKmeans

Options.nClusters = 2;
Options.distanceMeasure = @(x1,x2) distance(x1,x2);

Options.smoothFactor = 2; 
Options.maxIterations = 100; 
Options.minProbChange = 1e-5;
Options.minClassMeanChange = 1e-5;
Options.warningDisplay = false;