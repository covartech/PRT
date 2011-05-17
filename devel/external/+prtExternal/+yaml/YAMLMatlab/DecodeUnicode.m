function str = DecodeUnicode(orig_utf)
% This function decodes/encodes unicode characters into default character set
% orig_utf .. char 

%======================================================================
%{
		Copyright (c) 2011
		This program is a result of a joined cooperation of Energocentrum
		PLUS, s.r.o. and Czech Technical University (CTU) in Prague.
        The program is maintained by Energocentrum PLUS, s.r.o. and
        licensed under the terms of MIT license. Full text of the license
        is included in the program release.
		
        Author(s):
		Jiri Cigler, Dept. of Control Engineering, CTU Prague 
		Jan  Siroky, Energocentrum PLUS s.r.o.
		
        Implementation and Revisions:

        Auth  Date        Description of change
        ----  ---------   --------------------------------------------------
        jc    15-Mar-11   First implementation

%}
%======================================================================

import java.lang.String

string=String(orig_utf);

str = char(String(string.getBytes(feature('DefaultCharacterSet')),'UTF-8'));
end % end of function