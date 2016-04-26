function DataSet = prtDataGenManual
%prtDataGenManual Manually specify 2-D data via mouse clicking
%
%   dataSet = prtDataGenManual outputs data X and labels Y defined
%   interactively by clicking on a figure.  Left clickes place points on
%   the figure, and right clicks change the labels for the points to be
%   placed.  To finish, close the figure, or click the small "Done" button
%   on the bottom left of the figure.
%
%   Example:
%
%   dataSet = prtDataGenManual;
%
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenManual, prtDataGenMary, prtDataGenNoisySinc,
%   prtDataGenOldFaithful,prtDataGenProtate, prtDataGenSprial,
%   prtDataGenSpiral3Regress, prtDataGenUnimodal, prtDataGenSwissRoll,
%   prtDataGenUnimodal, prtDataGenXor








hF = figure;
X = zeros(0,2);
Y = zeros(0,1);
currentLabel = 0;
maxLabel = 0;

hA = axes;
set(hA,'buttondownfcn',@prtDataGenManualAxesButtonDownFcn);
hB = uicontrol('style','pushbutton','string','Done','callback',@(o,e) close(hF),'units','normalized','Position',[0.05 0.05 0.05 0.05]);
dataManualTitle;

DataSet = prtDataSetClass(X,Y,'name','Manualy Defined DataSet');

uiwait(hF);


    function dataManualTitle
        title(sprintf('Left-click to add an H_{%d} observation. Right-click to change hypothesis.',currentLabel));
    end

    function prtDataGenManualAxesButtonDownFcn(o,e)
        persistent previous;
        sType = get(hF,'selectionType');
        previous = sType;
        point = get(gca,'CurrentPoint');
        
        switch sType
            case 'normal'
                DataSet = catObservations(DataSet,prtDataSetClass(point(2,1:2),currentLabel));
                V = axis;
                hP = plot(DataSet);
                set(hP,'hittest','off');
                set(gca,'buttondownfcn',@prtDataGenManualAxesButtonDownFcn);
                axis(V);
                if currentLabel == maxLabel
                    maxLabel = maxLabel + 1;
                end
                dataManualTitle;
            case 'alt'
                currentLabel = currentLabel + 1;
                if currentLabel > maxLabel
                    currentLabel = 0;
                end
                dataManualTitle;
            %this happens when double-clicking *either* mouse button, so
            %it's impossible to say which mouse button was pushed.  Which
            %is not really cool.  In either casel clicking too fast results
            %in no changes to the GUI.
            % case 'open'  
            %      disp('No double clicks allowed');
            %      % keyboard
        end
    end

end
