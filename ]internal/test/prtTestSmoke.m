function prtTestSmoke
% prt Smoke test. Runs most of the fast tests. Use this when you don't want
% to wait for all of the tests to run but want to make sure you haven't
% broken the entire product

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


functionNames = {'prtTestDistance','prtTestClass', 'prtTestFeatSelExhaustive', 'prtTestClassFLD',' prtTestFeatSelSfs', 'prtTestClassKnn','prtTestKernelRbf','prtTestPreProcZmuv','prtTestScoreAuc','prtTestDataSetClass','prtTestDataSetRegress','prtTestDataSetStandard', 'prtTestRvMvn'};

prtTest(functionNames);
                                   
% prtTestClass.m                  prtTestFeatSelExhaustive.m      
% prtTestClassFLD.m               prtTestFeatSelLlnn.m            
% prtTestClassKMSD.m              prtTestFeatSelSfs.m             
% prtTestClassKmeansPrototypes.m  prtTestFeatSelStatic.m          
% prtTestClassKnn.m               prtTestKernelRbf.m              
% prtTestClassMAP.m               prtTestPreProcZmuv.m            
% prtTestClassPlsda.m             prtTestRegressGP.m              
% prtTestClassRvm.m               prtTestRegressLslr.m            
% prtTestClassSvm.m               prtTestRegressRvm.m             
% prtTestClassTreeBaggingCap.m    prtTestScoreAuc.m               
% prtTestDataSetClass.m           prtTestpreProcPCA.m             
% prtTestDataSetRegress.m         
% prtTestDataSetStandard.m        
% prtTestRvMvn.m
