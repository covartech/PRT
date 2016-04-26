function cost = prtUtilPfPd2Cost(pf,pd,costMatrix,priorH0,priorH1)
%cost = prtUtilPfPd2Cost(pf,pd)
%cost = prtUtilPfPd2Cost(pf,pd,costMatrix)
%cost = prtUtilPfPd2Cost(pf,pd,costMatrix,priorH0,priorH1)
%
%   Cost matrix = [0, 1; 1 0];







if nargin < 3
    costMatrix = [0, 1; 1 0];  %equal costs
end
if nargin < 4
    priorH0 = 1/2;
    priorH1 = 1/2;
end
cost = (pd*costMatrix(1,1) + (1-pd)*costMatrix(1,2))*priorH1 + (pf*costMatrix(2,1) + (1-pf)*costMatrix(2,2))*priorH0;
