function pE = prtUtilPfPd2Pe(pf,pd)
%pE = prtUtilPfPd2Pe(pf,pd)
%   Translate pf and pd (as from the output of prtScoreRoc) to probability
%   of error.

pE = pf*1/2 + (1-pd)*1/2;