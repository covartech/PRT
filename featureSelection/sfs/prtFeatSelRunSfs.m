function DS = prtFeatSelRunSfs(prtFeatSelector,DS)
%DS = prtFeatSelRunSfs(prtFeatSelector,DS)

data = DS.getObservations;
labels = DS.getTargets;
DS = prtDataSet(data,labels);
error('Fix this by fixing the classes');
