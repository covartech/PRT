%% New Visualization - IMAGESC
% In the last entry, we introduced a data set - the Cylinder-Bell-Funnel
% data set, prtDataGenCylinderBellFunnel.  To visualize it easily, we used
% the MATLAB function imagesc, which makes an image out of the data, with
% automatically determined colormap settings.  
%

% Copyright (c) 2014 CoVar Applied Technologies
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


%% Example
% For a lot of high-dimensional data sets, it turns out creating an
% observations x features image of the data is a great way to visualize and
% understand your data.  This week we made that process a little easier and
% cleaner by introducing a method of prtDataSetClass - imagesc. 
%
% The method takes care of a number of things that were a little tricky to
% do previously - first, it makes sure the observations are sorted by class
% index, next it creates an image of all the data with black bars
% denoting the class boundaries, and finally, it makes the y-tick-marks
% contain the relevant class names.  
%
% It's now easy to generate clean visualizations like so:

ds = prtDataGenCylinderBellFunnel;
ds.imagesc;

%% Other Data Sets
% Of course, you can do the same thing with other data sets, too.  Look at
% how easy it is to see which features are important in
% prtDataGenFeatureSelection:

ds = prtDataGenFeatureSelection;
ds.imagesc;

%% Wrapping Up
% That's it for this week.  We use imagesc-based visualization all the
% time, and hopefully you'll find it interesting and useful, too.
