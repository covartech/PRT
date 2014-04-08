classdef prtDataTypeImage < prtUtilActionDataAccess
    %prtDataTypeImage
    % General class for image storage, with conversions between MAT, GRAY,
    % RGB, and HSV.  Also includes tools for data pixel-wise labeling,
    % key-point location and scale storage, multi-scale processing, etc.
    %
    % Note: translating from some image types (gray) to others (rgb) is
    % impossible (unless additional assumptions are made).  In these cases,
    % asking for output in an incompatible type results in NaNs.
    %
    % Constructors:
    %   prtDataTypeImage('imageData',data,'imageType','rgb');
    %   prtDataTypeImage(data,'rgb');
    %   prtDataTypeImage('peppers.png');
    %
    % Examples:
    %
    % peppers = imread('peppers.png');
    % img = prtDataTypeImage('imageData',peppers,'imageType','rgb');
    % imshow(img);
    %
    % imgGray = img.gray;
    % imshow(imgGray)
    %
    % imgFromFile = prtDataTypeImage('peppers.png');
    %

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


    properties
        patchExtractionMode = 'gray';
        imageData = [];
        imageType = ''; %'mat','gray','rgb','hsv'
        actionData
        
        keypoints
    end
    
    properties (Access = protected)
        internalRgbData = [];
        internalGrayData = [];
        internalHsvData = [];
        internalLabData = [];
        internalYuvData = [];
        
        internalRgbToLabConverter = [];
        internalLabToRgbConverter = [];
    end
    
    %use these to get the data in different formats
    properties (Dependent)  
        gray
        rgb
        hsv
        lab
        yuv
    end
    
    methods
        
        function sz = getImageSize(self,varargin)
            %sz = getImageSize(self,varargin)
            sz = size(self.imageData,varargin{:});
        end
        
        function self = imresize(self,varargin)
            %self = imresize(self,varargin)
            imgData = imresize(self.imageData,varargin{:});
            self = prtDataTypeImage(imgData,self.imageType);
        end
        
        function [self,rect] = imcrop(self,varargin)
            %self = imcrop(self,varargin)
            [imgData,rect] = imcrop(self.imageData,varargin{:});
            self = prtDataTypeImage(imgData,self.imageType);
        end
        
        function varargout = imagesc(self,varargin)
            %h = imagesc(self,varargin)
            imgData = self.getDataForImage;
            h = imagesc(imgData,varargin{:});
            
            varargout = {};
			if nargout
				varargout{1} = h;
			end
        end
        
        function varargout = imshow(self,varargin)
            %h = imshow(self,varargin)
            imgData = self.getDataForImshow;
            h = imshow(imgData,varargin{:});
			
			varargout = {};
			if nargout
				varargout{1} = h;
			end
        end
        
        function varargout = image(self,varargin)
            %h = image(self,varargin)
            imgData = self.getDataForImage;
            h = image(imgData,varargin{:});
            set(h,'CDataMapping','scaled');
            
            varargout = {};
			if nargout
				varargout{1} = h;
			end
        end
        
        function self = prtDataTypeImage(varargin) 
            % prtDataTypeImage - video processing image constructor
            %   obj = prtDataTypeImage(imgData,imgType)
            %       Accepts an NxM or NxMx3 matrix and imgType
            %       {'mat', 'gray', 'rgb', 'hsv', 'lab', 'yuv'}
            %
            %   obj = prtDataTypeImage(imgData)
            %       Accepts an NxM or NxMx3 and assumes the image is either
            %       gray or rgb depending on the image size.
            %
            %   obj = prtDataTypeImage(imgFile)
            %       Uses imread to read the RGB values from the image file
            %       imgFile.
            %
            if nargin == 0
                self.imageType = 'gray';
                return;
            end
            
            if nargin == 2
                if isa(varargin{1},'char') % one input, infer type
                    data = varargin{2};
                    if size(data,3) == 3
                        varargin = {'imageData',data,'imageType','rgb'};
                    else
                        varargin = {'imageData',data,'imageType','gray'};
                    end
                    %fall through
                else
                    varargin = {'imageData',varargin{1},'imageType',varargin{2}};
                end
            elseif nargin == 1
                if isa(varargin{1},'char') && exist(varargin{1},'file')
                    data = imread(varargin{1});
                    varargin = {'imageData',data,'imageType','rgb'};
                else
                    data = varargin{1};
                    if size(data,3) == 3
                        varargin = {'imageData',data,'imageType','rgb'};
                    else
                        varargin = {'imageData',data,'imageType','gray'};
                    end
                end
            end
            
            
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            if ~isValid(self)
                error('Need to specify imageData and imageType');
            end
            
        end
        
        function data = getDataForImshow(self)
            %data = getDataForImshow(self)
            switch self.imageType
                case 'mat'
                    data = self.gray;
                case 'hsv'
                    data = self.rgb;
                otherwise
                    data = self.imageData;
            end
        end
        
        function data = getDataForImage(self)
            %data = getDataForImage(self)
            switch self.imageType
                case 'mat'
                    data = self.gray;
                    data = data - min(data(:));
                    data = round(data./max(data(:))*255);
                case 'gray'
                    data = self.gray;
                    data = data - min(data(:));
                    data = round(data./max(data(:))*255);
                case 'hsv'
                    data = self.rgb;
                otherwise
                    data = self.imageData;
            end
        end
        
        
        function self = setImageDataAndType(self,imgData,imgType)
            %self = setImageDataAndType(self,imgData,imgType)
            self.imageData = imgData;
            self.imageType = imgType;
            self = clearStorage(self);
        end
        
        function is = isValid(self)
            is = ~isempty(self.imageData) && ~isempty(self.imageType);
        end
        
        
        function self = convert(self,type)
            switch lower(type)
                case 'gray'
                    self.internalGrayData = self.gray;
                case 'hsv'
                    self.internalHsvData = self.hsv;
                case 'rgb'
                    self.internalRgbData = self.rgb;
                case 'lab'
                    self.internalLabData = self.lab;
                case 'yuv'
                    self.internalYuvData = self.yuv;
                case 'all'
                    self.internalGrayData = self.gray;
                    self.internalRgbData = self.rgb;
                    self.internalHsvData = self.hsv;
                    self.internalLabData = self.lab;
                    self.internalYuvData = self.yuv;
                    
                otherwise
                    error('prtDataTypeImage:invalidSpec','The specified image format was not valid');
            end
        end
        
        function self = clearStorage(self)
            self.internalRgbData = [];
            self.internalHsvData = [];
            self.internalGrayData = [];
            self.internalLabData = [];
            self.internalYuvData = [];
        end
        
        function g = get.gray(self)
            if isempty(self.internalGrayData)
                switch lower(self.imageType)
                    case 'mat'
                        % Added 2013.04.07 to handle 3-D gray 
                        x = self.imageData;
                        x = mean(x,3);
                        self.internalGrayData = mat2gray(x);
                        
                    case 'gray'
                        self.internalGrayData = self.imageData;
                        
                    case 'rgb'
                        self.internalGrayData = rgb2gray(self.imageData);
                        
                    case {'hsv', 'lab', 'yuv'}
                        self.internalGrayData = rgb2gray(self.rgb); % Force conversion to rgb then to gray
                        
                    otherwise 
                        error('prtDataTypeImage:invalidSpec','The specified image format was not valid');
                end
            end
            g = self.internalGrayData;
        end
        
        function r = get.rgb(self)
            if isempty(self.internalRgbData)
                switch lower(self.imageType)
                    case 'mat'
                        self.internalRgbData = repmat(self.gray,[1 1 3]); % Convert to gray, then repmat for 3 color dims
                    case 'gray'
                        self.internalRgbData = repmat(self.imageData,[1 1 3]); % then repmat for 3 color dims
                    case 'rgb'
                        self.internalRgbData = self.imageData;
                    case 'hsv'
                        self.internalRgbData = hsv2rgb(self.imageData);
                    case 'lab'
                        if isempty(self.internalLabToRgbConverter)
                            self.internalLabToRgbConverter = makecform('lab2srgb');
                        end
                        self.internalRgbData = applycform(self.imageData, self.internalLabToRgbConverter);
                    case 'yuv'
                        self.internalRgbData = ycbcr2rgb(self.imageData);
                        
                    otherwise 
                        error('prtDataTypeImage:invalidSpec','The specified image format was not valid');
                end
            end     
            r = self.internalRgbData;
        end
        
        function h = get.hsv(self)
            if isempty(self.internalHsvData)
                switch lower(self.imageType)
                    case {'mat' 'gray' 'lab' 'yuv'} % Convert to RGB then to hsv
                        self.internalHsvData = rgb2hsv(self.rgb); 
                        
                    case 'rgb'
                        self.internalHsvData = rgb2hsv(self.imageData);
                        
                    case 'hsv'
                        self.internalHsvData = self.imageData;
                        
                    otherwise 
                        error('prtDataTypeImage:invalidSpec','The specified image format was not valid');
                end
            end 
            h = self.internalHsvData;
        end
        
        function y = get.yuv(self)
            if isempty(self.internalYuvData)
                switch lower(self.imageType)
                    case {'mat' 'gray' 'lab' 'hsv'} % Convert to RGB then to yuv
                        self.internalYuvData = rgb2ycbcr(self.rgb);
                        
                    case 'rgb'
                        self.internalYuvData = rgb2ycbcr(self.imageData);
                        
                    case 'yuv'
                        self.internalYuvData = self.imageData;
                        
                    otherwise
                        error('prtDataTypeImage:invalidSpec','The specified image format was not valid');
                end
            end
            y = self.internalYuvData;
        end
        
        function y = get.lab(self)
            if isempty(self.internalLabData)
                switch lower(self.imageType)
                    case {'mat' 'gray' 'rgb' 'hsv' 'yuv'} % Convert to RGB then to lab
                        if isempty(self.internalRgbToLabConverter)
                            self.internalRgbToLabConverter = makecform('srgb2lab');
                        end
                        self.internalLabData = applycform(self.rgb, self.internalRgbToLabConverter);
                        
                    case 'lab'
                        self.internalLabData = self.imageData;
                        
                    otherwise
                        error('prtDataTypeImage:invalidSpec','The specified image format was not valid');
                end
            end
            y = self.internalLabData;
        end
        
          
        function [patches,fullPatch] = extractKeypointPatches(self,patchSize,theKeypoints)
            %[patches,fullPatch] = extractKeypointPatches(self,patchSize)
            if nargin < 3
                theKeypoints = self.keypoints;
            end
            patches = cell(size(theKeypoints,1),1);
            switch self.patchExtractionMode
                case 'gray'
                    theData = self.gray;
                    patch3 = [];
                case 'rgb'
                    theData = self.rgb;
                    patch3 = 3;
                otherwise
                    error('invalid patchExtractionMode');
            end
            %             patchSize = fliplr(patchSize);
            for keyIndex = 1:size(theKeypoints,1)
                cropRect = [theKeypoints(keyIndex,:)-ceil(patchSize/2),patchSize-1];
                patches{keyIndex} = imcrop(theData,cropRect);
            end
            fullPatch = cellfun(@(x) isequal(size(x),[fliplr(patchSize),patch3]), patches);
        end
        
        function [self,points] = extractKeypoints(self,varargin)
            %[self,points] = extractKeypoints(self,varargin)
            %  Call this like you would "corner"
            % to do: add scales
            points = corner(self.gray,varargin{:});
        end
        
        function self = greyWorldNormalize(self)
            
            theData = double(self.rgb);
            for ch = 1:3;
                c = theData(:,:,ch);
                theData(:,:,ch) = c./mean(c(:));
            end
            self = prtDataTypeImage('imageData',theData,'imageType','mat');
        end
            
    end
end
