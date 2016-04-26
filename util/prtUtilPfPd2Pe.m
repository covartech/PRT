function pE = prtUtilPfPd2Pe(pf,pd,priorH0,priorH1)
%pE = prtUtilPfPd2Pe(pf,pd)
%   Translate pf and pd (as from the output of prtScoreRoc) to probability
%   of error.







if nargin < 3 || isempty(priorH0)
    priorH0 = 1/2;
end
if nargin < 4 || isempty(priorH1)
    priorH1 = 1/2;
end

pE = pf*priorH0 + (1-pd)*priorH1;
