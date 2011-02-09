function prtSetup
% prtSetup - Guide user through setup process for the prt.

% Check for graphviz
[err,output] = system('dot -V');

if err
    warning('prt:prtSetup','Could not find GraphViz installation. Graphviz must be installed and on the system path to enable prtAlgorithm plotting. Go to http://www.graphviz.org/ and follow the installation instructions for your operating system.')
end

% Build help
builddocsearchdb(fullfile(prtRoot,'doc'));
