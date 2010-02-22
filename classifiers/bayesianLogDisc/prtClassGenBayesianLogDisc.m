function BayesianLogDisc = prtClassGenBayesianLogDisc(PrtDataSet,PrtClassOpt)
%PrtClassFld = prtClassGenBayesianLogDisc(PrtDataSet,PrtClassOpt)

LogDisc = prtClassGenLogDisc(PrtDataSet,PrtClassOptLogDisc);
wInit = LogDisc.w;

sigmaFn = @(x) 1./(1 + exp(-x));

m0 = PrtClassOpt.priorMeanFn(length(wInit));
s0 = PrtClassOpt.priorCovFn(length(wInit));

myObjFn = @(w)  bayesLogDiscObjFn(w);
wMap = fminunc(myObjFn,wInit);

[~,x,~,y] = bayesLogDiscObjFn(wMap);

BayesianLogDisc.sMap = s0^(-1) + bsxfun(@times,y.*(1-y),x)'*x;
BayesianLogDisc.wMap = wMap;
BayesianLogDisc.PrtDataSet = PrtDataSet;
BayesianLogDisc.PrtOptions = PrtClassOpt;
BayesianLogDisc.isMary = false;

    function [objective,x,t,y] = bayesLogDiscObjFn(w)
        
        t = PrtDataSet.getTargets;
        x = PrtDataSet.getObservations;
        x = cat(2,ones(size(x,1),1),x);
        y = sigmaFn(x*w);
        y(y < eps) = eps;
        y(y > 1-eps) = 1-eps;
        
        obj1 = -1/2*(w-m0)'*s0^(-1)*(w-m0);
        obj2 = sum(t.*log(y) + (1-t).*log(1-y));
        objective = obj1 + obj2;
        objective = - objective;
    end

end