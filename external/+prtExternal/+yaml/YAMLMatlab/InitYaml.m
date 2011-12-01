function InitYaml()
% This function initializes the YAMLReader and Writer


%  %======================================================================
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
        jc    02-Mar-11   First implementation
        jc    03-Mar-11   Fixed bug with initialization on windows machines
        jc    04-Mar-11   Added character encoding check (in order to set UTF-8)
%}
%==========================================================================

archive_name =   'snakeyaml-1.8.jar';
package_path = ['external-packages' filesep 'snakeyaml'];
% add .jar to dynamic path

if isempty(strfind(javaclasspath,package_path))
    r = matlabpath;
    tokens = strtok(r,pathsep);
    found = 0;
    [p, remain] = strtok(r,pathsep);
    while p
        if not(isempty(strfind(p, package_path )))
            javaaddpath([ p filesep archive_name ] );
            found = 1;
            break;
        end
        [p, remain] = strtok(remain,pathsep);
    end
    if not(found)
        error('YAMLMatlab:init:failed','YAMLMatlab initialization failed')
    end
end


end