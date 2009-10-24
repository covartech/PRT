function PrtClassFld = prtClassGenFld(PrtDataSet,PrtClassOpt)
%PrtClassFld = prtClassGenFld(PrtDataSet,PrtClassOpt)

x = getObservations(PrtDataSet);
y = getTargets(PrtDataSet);

n = PrtDataSet.nObservations;
p = PrtDataSet.nFeatures;

if p > n
    warning('prt:prtDataSet:illconditioned','PrtDataSet has n (%d) < p (%d); PrtClassFld may not be stable',n,p);
end

uY = unique(y);
dataH0 = x(y == uY(1),:);
dataH1 = x(y == uY(2),:);

M0 = mean(dataH0,1);
M1 = mean(dataH1,1);

% Following lines are equivalent to 
%       (Hi - repmat(Mi,size(Hi,1))'*(Hi - repmat(Mi,size(Hi,1))'
%   because of some clever math tricks involving the fact that Mi is
%   defined as mean(Hi) (thanks Kenny!)
s0 = dataH0'*dataH0 - M0'*M0*n;
s1 = dataH1'*dataH1 - M1'*M1*p;

Sw = s1 + s0;

w = Sw\(M0-M1)'; %w = Sw^-1 * (M0-M1)'; % But better

w = w./norm(w);

PrtClassFld.PrtDataSet = PrtDataSet;
PrtClassFld.PrtOptions = PrtClassOpt;
PrtClassFld.w = -w;