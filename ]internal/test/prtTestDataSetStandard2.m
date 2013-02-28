function result = prtTestDataSetStandard2

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
result = true;


% Check that we can instantiate a data set
try
    ds = prtDataGenUnimodal;
    result = true;
catch
    ME = MException('prtTestDataSetStandard2:basicFail', ...
        'basic prtDataGen* failure');
    result = false;
    disp(ME)
end

ObsInfo = genObsInfo(ds);
ds.observationInfo = ObsInfo;

try
    ds = ds.retainObservations(1:3:ds.nObservations);
    
    if ~isequal(ds.observationInfo(3).obsName,'Obs #7')
        error('retainObsertions failed ro retain observationInfo correctly');
    end
catch ME
    result = false;
    disp(ME);
end

try 
    n = ds.nObservations;
    ds = ds.catObservations(ds);
    
    if ~isequal(ds.observationInfo(1),ds.observationInfo(n+1))
        error('catObservations failed ro retain observationInfo correctly');
    end
catch ME
    result = false;
    disp(ME);
end

% catObservaitons with different observationInfo structures
try
    ds2 = ds.catObservations(prtDataGenUnimodal);
    
    if ~isequal(fieldnames(ds.observationInfo),fieldnames(ds2.observationInfo))
        error('catObservations failed to update observationInfo correctly');
    end
    
    if ~isequal(ds2.observationInfo(3).obsName,'Obs #7')
        error('catObservations failed ro retain observationInfo correctly');
    end    
    
catch ME
    result = false;
    disp(ME);
end


function ObsInfo = genObsInfo(ds)

for i = 1:ds.nObservations;
    obsName{i} = sprintf('Obs #%d',i);
    mod2{i} = mod(i,2);
    randInt{i} = round(rand*4);
end
ObsInfo = struct('obsName',obsName,'mod2',mod2,'randInt',randInt);

% % Check that we can set the observations and targets.
% try
%     dataSet = prtDataSetStandard;
%     dataSet =  dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
%     result = true;
% catch
%     result = false;
%     disp('Failed Test #2 Set Obs and Targets')
% end
%
%
% try
%     dataSet = prtDataSetStandard;
%     dataSet = dataSet.setX([1 2; 3 4; 5 6]);
%     dataSet = dataSet.setY([1 2 3]');
%     result = true;
% catch
%     result = false;
%     disp('Failed Test #3 Set X and Y')
% end
%
%
% dataSet = prtDataSetStandard('Observations',[1 2; 3 4; 5 6],'Targets', [1;2;3]);
% if ( ~isequal(dataSet.getX() ,[1 2; 3 4; 5 6]) ||( ~isequal(dataSet.getY(),[1;2;3])))
%     result = false;
%     disp('Failed Test #4, Param/Value constructor')
% end
%
%
%
%
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
% % Check features and dims
% if (dataSet.nFeatures ~=2) || (dataSet.nObservations ~=3)
%     result = false;
%     disp('Failed test #5, checking nFeatures and nObservations')
% end
%
%
% dataSet =  dataSet.setFeatureNames({'Sam';'Man'});
% if ( ~isequal(dataSet.getFeatureNames(), {'Sam';'Man'}))
%     result = false;
%     disp('Failed test #6, setting feature names')
% end
%
% % XXX
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1 2 ; 2 3 ; 3 4]);
% dataSet = dataSet.setTargetNames({'Sam';'Man'});
% if ( ~isequal(dataSet.getTargetNames(),{'Sam';'Man'}))
%     result = false;
%     disp('Failed test #7, setting target names')
% end
%
% %
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
% dataSet1 = dataSet.catFeatures([ 7 8 9 ]');
% if ~isequal(dataSet1.getX, [ 1 2 7; 3 4 8; 5 6 9])
%     result = false;
%     disp('Failed test #8, cat features')
% end
%
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservations([1 2; 3 4; 5 6]);
% dataSet1 = dataSet.catObservations([7 8]);
% if( ~isequal(dataSet1.getX, [1 2;3 4; 5 6; 7 8 ]))
%     result = false;
%     disp('Failed test #9, cat obs')
% end
%
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
% dataSet = dataSet.removeObservations(2);
% if ~isequal(dataSet.getX(), [1 2; 5 6])
%     result = false;
%     disp('Failed test #10, remove Obs')
% end
%
%
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
% dataSet = dataSet.removeFeatures(2);
% if ~isequal(dataSet.getX(), [1;3;5])
%     result = false;
%     disp('failed test #11, remove features')
% end
%
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1 2; 2 3; 3 4]);
% dataSet = dataSet.retainTargets(1);
% if ~isequal(dataSet.getY(), [1 2 3]')
%     result = false;
%     disp('failed test #12, retain targets')
% end
%
%
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
% dataSet = dataSet.retainFeatures(1);
% if ~isequal(dataSet.getX(), [ 1 3 5]');
%     result = false;
%     disp('failed test#13, retain features');
% end
%
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
% data = dataSet.getFeatures(2);
% if  ~isequal(data,[2 4 6]')
%     result = false;
%     disp('failed test #14, get features')
% end
%
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
% dataSet = dataSet.setFeatures([7 8 9]', 2);
% if  ~isequal(dataSet.getFeatures(2),[7 8 9]')
%     result = false;
%     disp('failed test #15, set features')
% end
%
%
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
% dataSet = dataSet.retainObservations(1);
% if ~isequal(dataSet.getX(), [ 1 2]);
%     result = false;
%     disp('failed test #16, retain observations')
% end
%
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1 2; 2 3; 3 4]);
% dataSet1 = dataSet.retainTargets(1);
% if ~isequal(dataSet1.getY(), [ 1 2 3]');
%     result = false;
%     disp('failed test #17, retain targets')
% end
%
% % Check setting higher dimension target data
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setX([ 1 2]');
% dataSet = dataSet.setY([1 2; 3 4]);
% if (~isequal(dataSet.getY(), [1 2;3 4]) || ~isequal(dataSet.nTargetDimensions, 2))
%     result = false;
%     disp('failed test #18, high dim target data')
% end
%
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setX([ 1 2]');
% dataSet = dataSet.setY([1 2; 3 4]);
% dataSet = dataSet.setY([8; 8], :, [1]);
% if ~isequal(dataSet.getY(:,1), [8;8])
%     result = false;
%     disp('failed test #19, set high dim target')
% end
%
% % Check indexing into X
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
% if( dataSet.getX(3,2) ~= 6)
%     result = false;
%     disp('failed test #20, index with getX')
% end
% dataSet = dataSet.setObservations(8, 3,2);
% if( dataSet.getX(3,2) ~= 8)
%     result = false;
%     disp('failed test #21, index with set Obs')
% end
%
% % XXX
% % cat targets
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; ], [1; 2; ]);
% dataSet = dataSet.catTargets([3;4]);
% if ~isequal(dataSet.getTargets, [1 3;2 4]);
%     result = false;
%    disp('failed test #22 cat targets')
% end
%
% % Test boostrap
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; 3]);
% dataSet = dataSet.bootstrap(2);
% if (dataSet.nObservations ~=2)
%     result = false;
%     disp('failed test #23, boostrap')
% end
%
%
% % Check user data
% s = struct('Sam',{'Rules', 'Man'}, 'Man', {'Hot' 'damn'});
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; ], [1; 2; ]);
% try
%     dataSet.observationInfo = s;
%     if ~isequal(dataSet.observationInfo, s(:))
%         result = false;
%         disp('failed test #24, Userdata')
%     end
% catch
%     result = false;
%     disp('failed test #24, Userdata')
% end
%
%
% %%
% %% Error checks
%
% error = true;  % We will want all these things to error
%
%
% try  % Make sure we can't instantiate base class
%     dataSet = prtDataSet;
%     error = false;  % Set it to false if the preceding operation succeeded
%     disp('Failed test #25, successful instantiation of base class')
% catch
%     % do nothing
%     % We can potentially catch and check the error string here
%     % For now, just be happy it is erroring out.
% end
%
% dataSet = prtDataSetStandard;
% try
%     dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1; 2; ]);
%     error = false;
%     disp('Failed test #26, data/target size matching')
% catch
%
% end
%
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setX([1 2; 3 4; 5 6]);
% try
%     dataSet = dataSet.setY([1; 2]);
%     error = false;
%     disp('Failed test #27, target size match')
% catch
%
% end
%
%
%
% dataSet = prtDataSetStandard;
% dataSet = dataSet.setObservationsAndTargets([1 2; 3 4; 5 6], [1;2;3]);
% try
%     dataSet = dataSet.catObservations([4 5]);
%     error = false;
%     disp('Failed test #28, trying to concat observations when targets present')
% end
%
% result = result & error;% & noerror;
