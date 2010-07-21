function [z] = prtUtilAddExp(x,y)
%prtUtilAddExp	Return the sum of two exponentials in exponential form, i.e.
%	return z where exp(z) = exp(x) + exp(y)
%
%	This works without the pitfalls of overflow or underflow when taking
%	the exponential of a very large or very small number.
%

if (nargin == 1)
  big = max(x);
  if (min(size(x)) > 1)
    len = size(x,1);
  else 
    len = 1;
  end;
  z = big + log(sum( exp(x - ones(len,1)*big) ));
else
  big   = max(x,y);
  small = min(x,y);
  z = big + log(1 + exp(small-big));
end
