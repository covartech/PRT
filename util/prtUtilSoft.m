function y = prtUtilSoft(a,delta)
% sign(a)*max(0,abs(a)-delta)





y = sign(a).*max(abs(a)-delta,0);

