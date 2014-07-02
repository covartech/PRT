function output = WriteYamlToString(matlab_struct)
% This function writers struct into str


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
        jc    01-Mar-11   First implementation
        jc    02-Mar-11   .jar package initialization moved to external fun

%}
%======================================================================
import prtExternal.yaml.*;

packagePath = fullfile(prtRoot,'+prtExternal','+yaml','YAMLMatlab','external-packages','snakeyaml');
jarPath = fullfile(packagePath,'snakeyaml-1.8.jar');

cPath = javaclasspath;

if iscell(cPath)
    if all(cellfun(@isempty,strfind(cPath,packagePath)))
        javaaddpath(jarPath)
    end
else
    if isempty(strfind(javaclasspath,packagePath))
        javaaddpath(jarPath)
    end
end

import('org.yaml.snakeyaml.Yaml');

yaml = Yaml();

Data = Struct2Hashmap(matlab_struct);

output = char(yaml.dump(Data));

end % end of function









