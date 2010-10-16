function prtTestSmoke
% prt Smoke test. Runs most of the fast tests. Use this when you don't want
% to wait for all of the tests to run but want to make sure you haven't
% broken the entire product

functionNames = {'prtTestDistance','prtTestClass', 'prtTestFeatSelExhaustive', 'prtTestClassFLD',' prtTestFeatSelSfs', 'prtTestClassKnn','prtTestKernelRbf','prtTestPreProcZmuv','prtTestRegressGP','prtTestScoreAuc','prtTestDataSetClass','prtTestDataSetRegress','prtTestDataSetStandard', 'prtTestRvMvn.m'};

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