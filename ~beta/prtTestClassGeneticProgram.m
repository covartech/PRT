%%
close all
clear classes

%ds = prtDataGenUnimodal;
ds = prtDataGenBimodal;
c = prtClassGeneticProgram('nOrganisms',1000,'nGenerations',25,'nBootstrapSamplesForFitness',[],'verbosePlot',true,'maxTreeDepth',3);
c = c.train(ds);
plot(c)

%%
