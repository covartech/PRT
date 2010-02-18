function DataSet = prtDataManual
%[X,Y] = prtDataManual Manually specify 2-D data via mouse clicking
%
%   [X,Y] = prtDataManual outputs data X and labels Y defined
%   interactively by clicking on a figure.  Left clickes place points on
%   the figure, and right clicks change the labels for the points to be
%   placed.  To finish, close the figure, or click the small "Done" button
%   on the bottom left of the figure.

hF = figure;
error('this is all broken');
X = zeros(0,2);
Y = zeros(0,1);
currentLabel = 0;
maxLabel = 0;

hA = axes;
set(hA,'buttondownfcn',@prtDataManualAxesButtonDownFcn);
hB = uicontrol('style','pushbutton','string','Done','callback',@(o,e) close(hF),'units','normalized','Position',[0.05 0.05 0.05 0.05]);
dataManualTitle;

DataSet = prtDataSet(X,Y,'name','Manualy Defined DataSet');

uiwait(hF);


    function dataManualTitle
        title(sprintf('Left-click to add an H_{%d} observation. Right-click to change hypothesis.',currentLabel));
    end

    function prtDataManualAxesButtonDownFcn(o,e)
        sType = get(hF,'selectionType');
        point = get(gca,'CurrentPoint');
        switch sType
            case 'normal'
                DataSet = catObservations(DataSet,point(2,1:2),currentLabel);
                V = axis;
                hP = plot(DataSet);
                set(hP,'hittest','off');
                set(gca,'buttondownfcn',@prtDataManualAxesButtonDownFcn);
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
        end
    end

end