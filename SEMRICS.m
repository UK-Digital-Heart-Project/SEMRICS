function varargout = SEMRICS(varargin)
% PFT_CONTRASTSIMULATIONGUI MATLAB code for pft_ContrastSimulationGUI.fig
%      PFT_CONTRASTSIMULATIONGUI, by itself, creates a new PFT_CONTRASTSIMULATIONGUI or raises the existing
%      singleton*.
%
%      H = PFT_CONTRASTSIMULATIONGUI returns the handle to a new PFT_CONTRASTSIMULATIONGUI or the handle to
%      the existing singleton*.
%
%      PFT_CONTRASTSIMULATIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PFT_CONTRASTSIMULATIONGUI.M with the given input arguments.
%
%      PFT_CONTRASTSIMULATIONGUI('Property','Value',...) creates a new PFT_CONTRASTSIMULATIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pft_ContrastSimulationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pft_ContrastSimulationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pft_ContrastSimulationGUI

% Last Modified by GUIDE v2.5 07-Aug-2019 17:23:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pft_ContrastSimulationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @pft_ContrastSimulationGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before pft_ContrastSimulationGUI is made visible.
function pft_ContrastSimulationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pft_ContrastSimulationGUI (see VARARGIN)

% Choose default command line output for pft_ContrastSimulationGUI
handles.output = hObject;

% Centralize the main figure on the screen
ScreenSize = get(0, 'ScreenSize');

X0 = ScreenSize(1);
Y0 = ScreenSize(2);
WD = ScreenSize(3);
HT = ScreenSize(4);

FigureSize = get(hObject, 'Position');

x0 = FigureSize(1);
y0 = FigureSize(2);
wd = FigureSize(3);
ht = FigureSize(4);

NewX0 = (WD - wd)/2;
NewY0 = (HT - ht)/2;

NewPosition = [ NewX0, NewY0, wd, ht ];

set(hObject, 'Position', NewPosition);

% Read in the parameter maps 
handles.ReadPickle = fullfile(pwd, 'Source Data', 'HV009a.mat');
handles.SaveFolder = fullfile(pwd, 'Results', 'HV009a');

p = strfind(handles.ReadPickle, filesep);
q = p(end);
r = q + 1;

Leaf = handles.ReadPickle(r:end);

p = strfind(Leaf, '.');
q = p(end);
r = q - 1;

Leaf = Leaf(1:r);

set(handles.EditReadPickle, 'String', Leaf);

handles.SaveFolder = fullfile(pwd, 'Results', Leaf);

load(handles.ReadPickle);

handles.MoMap  = MoData;
handles.MoInfo = MoInfo;
handles.MoDims = MoDims;

handles.T1Map  = T1Data;
handles.T1Info = T1Info;
handles.T1Dims = T1Dims;

handles.T2Map  = T2Data;
handles.T2Info = T2Info;
handles.T2Dims = T2Dims;

clearvars MoMap MoInfo MoDims 
clearvars T1Map T1Info T1Dims 
clearvars T2Map T2Info T2Dims

handles.MoMap = squeeze(handles.MoMap);
handles.T1Map = squeeze(handles.T2Map);
handles.T1Map = squeeze(handles.T2Map);

handles.MoMin = min(handles.MoMap(:));
handles.MoMax = max(handles.MoMap(:));
handles.T1Min = min(handles.T1Map(:));
handles.T1Max = max(handles.T1Map(:));
handles.T2Min = min(handles.T2Map(:));
handles.T2Max = max(handles.T2Map(:));

% Read in the starting slider values
handles.MoLower = get(handles.SliderMoLower, 'Value');
handles.MoUpper = get(handles.SliderMoUpper, 'Value');
handles.T1Lower = get(handles.SliderT1Lower, 'Value');
handles.T1Upper = get(handles.SliderT1Upper, 'Value');
handles.T2Lower = get(handles.SliderT2Lower, 'Value');
handles.T2Upper = get(handles.SliderT2Upper, 'Value');
handles.WILower = get(handles.SliderWILower, 'Value');
handles.WIUpper = get(handles.SliderWIUpper, 'Value');

% Fetch the image dimensions and set the slider step for the common slice accordingly
[ handles.NROWS, handles.NCOLS, handles.NPLNS ] = size(handles.MoMap);

handles.CommonSlice = floor((handles.NPLNS + 1)/2);

set(handles.SliderCommonSlice, 'Min', 1);
set(handles.SliderCommonSlice, 'Max', handles.NPLNS);
set(handles.SliderCommonSlice, 'SliderStep', [ 1.0/double(handles.NPLNS - 1), 1.0/double(handles.NPLNS - 1)]);
set(handles.SliderCommonSlice, 'Value', handles.CommonSlice);
set(handles.EditCommonSlice, 'String', sprintf('Slice: %1d', handles.CommonSlice));

% Display the current slice of each parameter map
handles.CommonSlice = get(handles.SliderCommonSlice, 'Value');

handles.MoSlice = handles.CommonSlice;
handles.T1Slice = handles.CommonSlice;
handles.T2Slice = handles.CommonSlice;

handles.MoPart = squeeze(handles.MoMap(:, :, handles.MoSlice));
handles.T1Part = squeeze(handles.T1Map(:, :, handles.T1Slice));
handles.T2Part = squeeze(handles.T2Map(:, :, handles.T2Slice));

imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);
imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);
imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);

% Calculate a PD weighted image and display it in its proper axes - also, make backups of the current TR and TE
handles.TR      = 5000.0;
handles.TE      = 50.0;
handles.NoisePC = 0.0;

handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

handles.WILower = 0;
handles.WIUpper = 2000.0;

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);

handles.OldCustomTR = handles.TR;
handles.OldCustomTE = handles.TE;

% Update the colormaps for the different axes
fid = fopen('Colormaps.txt', 'rt');
Strings = textscan(fid, '%s');
fclose(fid);

handles.ColormapNames = Strings{1};

set(handles.ListColormapMo, 'String', handles.ColormapNames);
M = find(strcmpi(handles.ColormapNames, 'gray'), 1, 'first');
set(handles.ListColormapMo, 'Value', M);

set(handles.ListColormapT1, 'String', handles.ColormapNames);
M = find(strcmpi(handles.ColormapNames, 'parula'), 1, 'first');
set(handles.ListColormapT1, 'Value', M);

set(handles.ListColormapT2, 'String', handles.ColormapNames);
M = find(strcmpi(handles.ColormapNames, 'hot'), 1, 'first');
set(handles.ListColormapT2, 'Value', M);

set(handles.ListColormapWI, 'String', handles.ColormapNames);
M = find(strcmpi(handles.ColormapNames, 'gray'), 1, 'first');
set(handles.ListColormapWI, 'Value', M);

handles.ColormapNameMo = 'gray';
handles.ColormapNameT1 = 'parula';
handles.ColormapNameT2 = 'hot';
handles.ColormapNameWI = 'gray';

handles.ColormapMo = gray(256);
handles.ColormapT1 = parula(256);
handles.ColormapT2 = hot(256);
handles.ColormapWI = gray(256);

colormap(handles.AxesMo, handles.ColormapMo);
colormap(handles.AxesT1, handles.ColormapT1);
colormap(handles.AxesT2, handles.ColormapT2);
colormap(handles.AxesWI, handles.ColormapWI);

% Note that caption display is enabled
handles.ShowCaptions = true;

% Fetch the list of caption colours and set the initial value
handles.CaptionColors = cellstr(get(handles.ListCaptionColor, 'String'));
M = find(strcmpi(handles.CaptionColors, 'Cyan'), 1, 'first');
set(handles.ListCaptionColor, 'Value', M);

handles.CurrentCaptionColor = handles.CaptionColors{M};

handles.TextColor = [0 1 1];

% Note the weighting modes
handles.OldWeightingMode = 'Custom';
handles.NewWeightingMode = 'Custom';

% Annotate the images
if (handles.ShowCaptions == true)
  text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

% Note the data saving options
handles.SaveMapSlices  = true;
handles.SaveMapStacks  = true;
handles.SaveWISlice    = true;
handles.SaveWIStack    = true;
handles.SaveDicomStack = true;

% Create listeners for the sliders to allow a continuous response
hSliderMoUpperListener = addlistener(handles.SliderMoUpper, 'ContinuousValueChange', @CB_SliderMoUpper_Listener);
setappdata(handles.SliderMoUpper, 'MyListener', hSliderMoUpperListener);

hSliderMoLowerListener = addlistener(handles.SliderMoLower, 'ContinuousValueChange', @CB_SliderMoLower_Listener);
setappdata(handles.SliderMoLower, 'MyListener', hSliderMoLowerListener);

hSliderT1UpperListener = addlistener(handles.SliderT1Upper, 'ContinuousValueChange', @CB_SliderT1Upper_Listener);
setappdata(handles.SliderT1Upper, 'MyListener', hSliderT1UpperListener);

hSliderT1LowerListener = addlistener(handles.SliderT1Lower, 'ContinuousValueChange', @CB_SliderT1Lower_Listener);
setappdata(handles.SliderT1Lower, 'MyListener', hSliderT1LowerListener);

hSliderT2UpperListener = addlistener(handles.SliderT2Upper, 'ContinuousValueChange', @CB_SliderT2Upper_Listener);
setappdata(handles.SliderT2Upper, 'MyListener', hSliderT2UpperListener);

hSliderT2LowerListener = addlistener(handles.SliderT2Lower, 'ContinuousValueChange', @CB_SliderT2Lower_Listener);
setappdata(handles.SliderT2Lower, 'MyListener', hSliderT2LowerListener);

hSliderCommonSliceListener = addlistener(handles.SliderCommonSlice, 'ContinuousValueChange', @CB_SliderCommonSlice_Listener);
setappdata(handles.SliderCommonSlice, 'MyListener', hSliderCommonSliceListener);

hSliderWIUpperListener = addlistener(handles.SliderWIUpper, 'ContinuousValueChange', @CB_SliderWIUpper_Listener);
setappdata(handles.SliderWIUpper, 'MyListener', hSliderWIUpperListener);

hSliderWILowerListener = addlistener(handles.SliderWILower, 'ContinuousValueChange', @CB_SliderWILower_Listener);
setappdata(handles.SliderWILower, 'MyListener', hSliderWILowerListener);

hSliderTRListener = addlistener(handles.SliderTR, 'ContinuousValueChange', @CB_SliderTR_Listener);
setappdata(handles.SliderTR, 'MyListener', hSliderTRListener);

hSliderTEListener = addlistener(handles.SliderTE, 'ContinuousValueChange', @CB_SliderTE_Listener);
setappdata(handles.SliderTE, 'MyListener', hSliderTEListener);

hSliderNoisePCListener = addlistener(handles.SliderNoisePC, 'ContinuousValueChange', @CB_SliderNoisePC_Listener);
setappdata(handles.SliderNoisePC, 'MyListener', hSliderNoisePCListener);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pft_ContrastSimulationGUI wait for user response (see UIRESUME)
% uiwait(handles.ContrastSimulationFigure);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Outputs from this function are returned to the command line.
function varargout = pft_ContrastSimulationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderMoUpper_Callback(hObject, eventdata, handles)

handles.MoUpper = round(get(hObject, 'Value'));

set(handles.EditMoUpper, 'String', sprintf('Upper: %1d', handles.MoUpper));

if (handles.MoUpper - handles.MoLower < 100.0)
  handles.MoLower = handles.MoUpper - 100.0;
  set(handles.SliderMoLower, 'Value', handles.MoLower);
  set(handles.EditMoLower, 'String', sprintf('Lower: %1d', handles.MoLower));
end

imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);

colormap(handles.AxesMo, handles.ColormapMo);

if (handles.ShowCaptions == true)
  text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

function CB_SliderMoUpper_Listener(hObject, eventdata, handles)

% This was necessary in MATLAB 2013b
if ~(exist('handles', 'var'))
  handles = guidata(hObject);  
end

handles.MoUpper = round(get(hObject, 'Value'));

set(handles.EditMoUpper, 'String', sprintf('Upper: %1d', handles.MoUpper));

if (handles.MoUpper - handles.MoLower < 100.0)
  handles.MoLower = handles.MoUpper - 100.0;
  set(handles.SliderMoLower, 'Value', handles.MoLower);
  set(handles.EditMoLower, 'String', sprintf('Lower: %1d', handles.MoLower));
end

imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);

colormap(handles.AxesMo, handles.ColormapMo);

if (handles.ShowCaptions == true)
  text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderMoUpper_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderMoLower_Callback(hObject, eventdata, handles)

handles.MoLower = round(get(hObject, 'Value'));

set(handles.EditMoLower, 'String', sprintf('Lower: %1d', handles.MoLower));

if (handles.MoUpper - handles.MoLower < 100.0)
  handles.MoUpper = handles.MoLower + 100.0;
  set(handles.SliderMoUpper, 'Value', handles.MoUpper);
  set(handles.EditMoUpper, 'String', sprintf('Upper: %1d', handles.MoUpper));
end

imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);

colormap(handles.AxesMo, handles.ColormapMo);

if (handles.ShowCaptions == true)
  text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

function CB_SliderMoLower_Listener(hObject, eventdata, handles)

% This was necessary in MATLAB 2013b
if ~(exist('handles', 'var'))
  handles = guidata(hObject);  
end

handles.MoLower = round(get(hObject, 'Value'));

set(handles.EditMoLower, 'String', sprintf('Lower: %1d', handles.MoLower));

if (handles.MoUpper - handles.MoLower < 100.0)
  handles.MoUpper = handles.MoLower + 100.0;
  set(handles.SliderMoUpper, 'Value', handles.MoUpper);
  set(handles.EditMoUpper, 'String', sprintf('Upper: %1d', handles.MoUpper));
end

imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);

colormap(handles.AxesMo, handles.ColormapMo);

if (handles.ShowCaptions == true)
  text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderMoLower_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditMoUpper_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditMoUpper_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditMoLower_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditMoLower_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditT1Upper_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditT1Upper_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderT1Upper_Callback(hObject, eventdata, handles)

handles.T1Upper = round(get(hObject, 'Value'));

set(handles.EditT1Upper, 'String', sprintf('Upper: %1d ms', handles.T1Upper));

if (handles.T1Upper - handles.T1Lower < 100.0)
  handles.T1Lower = handles.T1Upper - 100.0;
  set(handles.SliderT1Lower, 'Value', handles.T1Lower);
  set(handles.EditT1Lower, 'String', sprintf('Lower: %1d', handles.T1Lower));
end

imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);

colormap(handles.AxesT1, handles.ColormapT1);

if (handles.ShowCaptions == true)
  text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

function CB_SliderT1Upper_Listener(hObject, eventdata, handles)

% This was necessary in MATLAB 2013b
if ~(exist('handles', 'var'))
  handles = guidata(hObject);  
end

handles.T1Upper = round(get(hObject, 'Value'));

set(handles.EditT1Upper, 'String', sprintf('Upper: %1d ms', handles.T1Upper));

if (handles.T1Upper - handles.T1Lower < 100.0)
  handles.T1Lower = handles.T1Upper - 100.0;
  set(handles.SliderT1Lower, 'Value', handles.T1Lower);
  set(handles.EditT1Lower, 'String', sprintf('Lower: %1d', handles.T1Lower));
end

imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);

colormap(handles.AxesT1, handles.ColormapT1);

if (handles.ShowCaptions == true)
  text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderT1Upper_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditT1Lower_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditT1Lower_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderT1Lower_Callback(hObject, eventdata, handles)

handles.T1Lower = round(get(hObject, 'Value'));

set(handles.EditT1Lower, 'String', sprintf('Lower: %1d ms', handles.T1Lower));

if (handles.T1Upper - handles.T1Lower < 100.0)
  handles.T1Upper = handles.T1Lower + 100.0;
  set(handles.SliderT1Upper, 'Value', handles.T1Upper);
  set(handles.EditT1Upper, 'String', sprintf('Upper: %1d', handles.T1Upper));
end

imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);

colormap(handles.AxesT1, handles.ColormapT1);

if (handles.ShowCaptions == true)
  text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

function CB_SliderT1Lower_Listener(hObject, eventdata, handles)

% This was necessary in MATLAB 2013b
if ~(exist('handles', 'var'))
  handles = guidata(hObject);  
end

handles.T1Lower = round(get(hObject, 'Value'));

set(handles.EditT1Lower, 'String', sprintf('Lower: %1d ms', handles.T1Lower));

if (handles.T1Upper - handles.T1Lower < 100.0)
  handles.T1Upper = handles.T1Lower + 100.0;
  set(handles.SliderT1Upper, 'Value', handles.T1Upper);
  set(handles.EditT1Upper, 'String', sprintf('Upper: %1d', handles.T1Upper));
end

imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);

colormap(handles.AxesT1, handles.ColormapT1);

if (handles.ShowCaptions == true)
  text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderT1Lower_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditT2Upper_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditT2Upper_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditT2Lower_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditT2Lower_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderT2Upper_Callback(hObject, eventdata, handles)

handles.T2Upper = round(get(hObject, 'Value'));

set(handles.EditT2Upper, 'String', sprintf('Upper: %1d ms', handles.T2Upper));

if (handles.T2Upper - handles.T2Lower < 25.0)
  handles.T2Lower = handles.T2Upper - 25.0;
  set(handles.SliderT2Lower, 'Value', handles.T2Lower);
  set(handles.EditT2Lower, 'String', sprintf('Lower: %1d', handles.T2Lower));
end

imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);

colormap(handles.AxesT2, handles.ColormapT2);

if (handles.ShowCaptions == true)
  text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

function CB_SliderT2Upper_Listener(hObject, eventdata, handles)

% This was necessary in MATLAB 2013b
if ~(exist('handles', 'var'))
  handles = guidata(hObject);  
end

handles.T2Upper = round(get(hObject, 'Value'));

set(handles.EditT2Upper, 'String', sprintf('Upper: %1d ms', handles.T2Upper));

if (handles.T2Upper - handles.T2Lower < 25.0)
  handles.T2Lower = handles.T2Upper - 25.0;
  set(handles.SliderT2Lower, 'Value', handles.T2Lower);
  set(handles.EditT2Lower, 'String', sprintf('Lower: %1d', handles.T2Lower));
end

imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);

colormap(handles.AxesT2, handles.ColormapT2);

if (handles.ShowCaptions == true)
  text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderT2Upper_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderT2Lower_Callback(hObject, eventdata, handles)

handles.T2Lower = round(get(hObject, 'Value'));

set(handles.EditT2Lower, 'String', sprintf('Lower: %1d ms', handles.T2Lower));

if (handles.T2Upper - handles.T2Lower < 25.0)
  handles.T2Upper = handles.T2Lower + 25.0;
  set(handles.SliderT2Upper, 'Value', handles.T2Upper);
  set(handles.EditT2Upper, 'String', sprintf('Upper: %1d', handles.T2Upper));
end

imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);

colormap(handles.AxesT2, handles.ColormapT2);

if (handles.ShowCaptions == true)
  text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

function CB_SliderT2Lower_Listener(hObject, eventdata, handles)

% This was necessary in MATLAB 2013b
if ~(exist('handles', 'var'))
  handles = guidata(hObject);  
end

handles.T2Lower = round(get(hObject, 'Value'));

set(handles.EditT2Lower, 'String', sprintf('Lower: %1d ms', handles.T2Lower));

if (handles.T2Upper - handles.T2Lower < 25.0)
  handles.T2Upper = handles.T2Lower + 25.0;
  set(handles.SliderT2Upper, 'Value', handles.T2Upper);
  set(handles.EditT2Upper, 'String', sprintf('Upper: %1d', handles.T2Upper));
end

imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);

colormap(handles.AxesT2, handles.ColormapT2);

if (handles.ShowCaptions == true)
  text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderT2Lower_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderCommonSlice_Callback(hObject, eventdata, handles)

handles.CommonSlice = round(get(hObject, 'Value'));

set(handles.SliderCommonSlice, 'Value', handles.CommonSlice);

set(handles.EditCommonSlice, 'String', sprintf('Slice: %1d', handles.CommonSlice));

handles.MoSlice = handles.CommonSlice;
handles.T1Slice = handles.CommonSlice;
handles.T2Slice = handles.CommonSlice;

handles.MoPart = squeeze(handles.MoMap(:, :, handles.MoSlice));
handles.T1Part = squeeze(handles.T1Map(:, :, handles.T1Slice));
handles.T2Part = squeeze(handles.T2Map(:, :, handles.T2Slice));

handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);
colormap(handles.AxesMo, handles.ColormapMo);

imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);
colormap(handles.AxesT1, handles.ColormapT1);

imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);
colormap(handles.AxesT2, handles.ColormapT2);

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);
colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

function CB_SliderCommonSlice_Listener(hObject, eventdata, handles)

% This was necessary in MATLAB 2013b
if ~(exist('handles', 'var'))
  handles = guidata(hObject);  
end

handles.CommonSlice = round(get(hObject, 'Value'));

set(handles.SliderCommonSlice, 'Value', handles.CommonSlice);

set(handles.EditCommonSlice, 'String', sprintf('Slice: %1d', handles.CommonSlice));

handles.MoSlice = handles.CommonSlice;
handles.T1Slice = handles.CommonSlice;
handles.T2Slice = handles.CommonSlice;

handles.MoPart = squeeze(handles.MoMap(:, :, handles.MoSlice));
handles.T1Part = squeeze(handles.T1Map(:, :, handles.T1Slice));
handles.T2Part = squeeze(handles.T2Map(:, :, handles.T2Slice));

handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);
colormap(handles.AxesMo, handles.ColormapMo);

imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);
colormap(handles.AxesT1, handles.ColormapT1);

imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);
colormap(handles.AxesT2, handles.ColormapT2);

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);
colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderCommonSlice_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditCommonSlice_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditCommonSlice_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ListColormapMo_Callback(hObject, eventdata, handles)

% Find the position of the colormap name in the list
V = get(hObject, 'Value');

handles.ColormapNameMo = handles.ColormapNames{V};

% Check for the one exceptional case which does not take a size parameter
if strcmpi(handles.ColormapNameMo, 'vga')
  handles.ColormapMo = vga;
else
  handles.ColormapMo = eval(sprintf('%s(256)', handles.ColormapNameMo));
end

% Apply the colormap to the image axes
colormap(handles.AxesMo, handles.ColormapMo);

% Update the handles structure
guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ListColormapMo_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ListColormapT1_Callback(hObject, eventdata, handles)

% Find the position of the colormap name in the list
V = get(hObject, 'Value');

handles.ColormapNameT1 = handles.ColormapNames{V};

% Check for the one exceptional case which does not take a size parameter
if strcmpi(handles.ColormapNameT1, 'vga')
  handles.ColormapT1 = vga;
else
  handles.ColormapT1 = eval(sprintf('%s(256)', handles.ColormapNameT1));
end

% Apply the colormap to the image axes
colormap(handles.AxesT1, handles.ColormapT1);

% Update the handles structure
guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ListColormapT1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ListColormapT2_Callback(hObject, eventdata, handles)

% Find the position of the colormap name in the list
V = get(hObject, 'Value');

handles.ColormapNameT2 = handles.ColormapNames{V};

% Check for the one exceptional case which does not take a size parameter
if strcmpi(handles.ColormapNameT2, 'vga')
  handles.ColormapT2 = vga;
else
  handles.ColormapT2 = eval(sprintf('%s(256)', handles.ColormapNameT2));
end

% Apply the colormap to the image axes
colormap(handles.AxesT2, handles.ColormapT2);

% Update the handles structure
guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ListColormapT2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditColormapMo_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditColormapMo_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditColormapT1_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditColormapT1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditColormapT2_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditColormapT2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CheckMapSlices_Callback(hObject, eventdata, handles)

handles.SaveMapSlices = logical(get(hObject, 'Value'));

% Update the handles structure
guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CheckMapStack_Callback(hObject, eventdata, handles)

handles.SaveMapStacks = logical(get(hObject, 'Value'));

% Update the handles structure
guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CheckWISlice_Callback(hObject, eventdata, handles)

handles.SaveWISlice = logical(get(hObject, 'Value'));

% Update the handles structure
guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CheckWIStack_Callback(hObject, eventdata, handles)

handles.SaveWIStack = logical(get(hObject, 'Value'));

% Update the handles structure
guidata(hObject, handles); 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CheckWIDicomStack_Callback(hObject, eventdata, handles)

handles.SaveDicomStack = logical(get(hObject, 'Value'));

% Update the handles structure
guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ButtonGroupWeighting_SelectionChangedFcn(hObject, eventdata, handles)

% Fetch the old and new values of the weighting mode
handles.OldWeightingMode = get(eventdata.OldValue, 'String');
handles.NewWeightingMode = get(eventdata.NewValue, 'String');

% Back up the custom values if another mode is chosen
if strcmpi(handles.OldWeightingMode, 'Custom') && ~strcmpi(handles.NewWeightingMode, 'Custom')
  handles.OldCustomTR = handles.TR;
  handles.OldCustomTE = handles.TE;
end

% Update the TR and TE accordingly
switch handles.NewWeightingMode
  case 'Custom'
    handles.TR = handles.OldCustomTR;
    handles.TE = handles.OldCustomTE;
  case 'Proton Density'     
    handles.TR = 5000.0;
    handles.TE = 5.0;
  case 'T1W'
    handles.TR = 100.0;
    handles.TE = 5.0;
  case 'T2W'
    handles.TR = 5000.0;
    handles.TE = 50.0;
  case 'Mixed'
    handles.TR = 300.0;
    handles.TE = 50.0;
end

% Update the sliders and the edit windows
set(handles.SliderTR, 'Value', handles.TR);
set(handles.EditTR, 'String', sprintf('TR: %1d ms', handles.TR));

set(handles.SliderTE, 'Value', handles.TE);
set(handles.EditTE, 'String', sprintf('TE: %1d ms', handles.TE));

% Set the state of the TR and TE edit boxes and sliders appropriately
if strcmpi(handles.NewWeightingMode, 'Custom')
  set(handles.EditTR, 'Enable', 'on');
  set(handles.SliderTR, 'Enable', 'on');

  set(handles.EditTE, 'Enable', 'on');
  set(handles.SliderTE, 'Enable', 'on');
else
  set(handles.EditTR, 'Enable', 'inactive');
  set(handles.SliderTR, 'Enable', 'off');

  set(handles.EditTE, 'Enable', 'inactive');
  set(handles.SliderTE, 'Enable', 'off');
end

% Calculate and display the weighted image
handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);

colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

% Update the handles structure
guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditWIUpper_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditWIUpper_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditWILower_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditWILower_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderWIUpper_Callback(hObject, eventdata, handles)

handles.WIUpper = round(get(hObject, 'Value'));

set(handles.EditWIUpper, 'String', sprintf('Upper: %1d', handles.WIUpper));

if (handles.WIUpper - handles.WILower < 100.0)
  handles.WILower = handles.WIUpper - 100.0;
  set(handles.SliderWILower, 'Value', handles.WILower);
  set(handles.EditWILower, 'String', sprintf('Lower: %1d', handles.WILower));
end

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);

colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

function CB_SliderWIUpper_Listener(hObject, eventdata, handles)

% This was necessary in MATLAB 2013b
if ~(exist('handles', 'var'))
  handles = guidata(hObject);  
end

handles.WIUpper = round(get(hObject, 'Value'));

set(handles.EditWIUpper, 'String', sprintf('Upper: %1d', handles.WIUpper));

if (handles.WIUpper - handles.WILower < 100.0)
  handles.WILower = handles.WIUpper - 100.0;
  set(handles.SliderWILower, 'Value', handles.WILower);
  set(handles.EditWILower, 'String', sprintf('Lower: %1d', handles.WILower));
end

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);

colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderWIUpper_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderWILower_Callback(hObject, eventdata, handles)

handles.WILower = round(get(hObject, 'Value'));

set(handles.EditWILower, 'String', sprintf('Lower: %1d', handles.WILower));

if (handles.WIUpper - handles.WILower < 100.0)
  handles.WIUpper = handles.WILower + 100.0;
  set(handles.SliderWIUpper, 'Value', handles.WIUpper);
  set(handles.EditWIUpper, 'String', sprintf('Upper: %1d', handles.WIUpper));
end

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);
colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

function CB_SliderWILower_Listener(hObject, eventdata, handles)

% This was necessary in MATLAB 2013b
if ~(exist('handles', 'var'))
  handles = guidata(hObject);  
end

handles.WILower = round(get(hObject, 'Value'));

set(handles.EditWILower, 'String', sprintf('Lower: %1d', handles.WILower));

if (handles.WIUpper - handles.WILower < 100.0)
  handles.WIUpper = handles.WILower + 100.0;
  set(handles.SliderWIUpper, 'Value', handles.WIUpper);
  set(handles.EditWIUpper, 'String', sprintf('Upper: %1d', handles.WIUpper));
end

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);
colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderWILower_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ListColormapWI_Callback(hObject, eventdata, handles)

% Find the position of the colormap name in the list
V = get(hObject, 'Value');

handles.ColormapNameWI = handles.ColormapNames{V};

% Check for the one exceptional case which does not take a size parameter
if strcmpi(handles.ColormapNameWI, 'vga')
  handles.ColormapWI = vga;
else
  handles.ColormapWI = eval(sprintf('%s(256)', handles.ColormapNameWI));
end

% Apply the colormap to the image axes
colormap(handles.AxesWI, handles.ColormapWI);

% Update the handles structure
guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ListColormapWI_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditColormapWI_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditColormapWI_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MenuFile_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MenuOpenDataSet_Callback(hObject, eventdata, handles)

% Prompt for a data folder
[ FileName, PathName, FilterIndex ] = uigetfile(fullfile(pwd, 'Source Data', '*.mat'), 'Select a packaged data set');

if (FilterIndex == 0)
  guidata(hObject, handles);
  
  return;
else
  Pickle = fullfile(PathName, FileName);  
    
  handles.ReadPickle = Pickle;
  
  p = strfind(handles.ReadPickle, filesep);
  q = p(end);
  r = q + 1;

  Leaf = handles.ReadPickle(r:end);
  
  p = strfind(Leaf, '.');
  q = p(end);
  r = q - 1;
  
  Leaf = Leaf(1:r);
  
  set(handles.EditReadPickle, 'String', Leaf);
  
  handles.SaveFolder = fullfile(pwd, 'Results', Leaf);
end

load(handles.ReadPickle);

handles.MoMap  = MoData;
handles.MoInfo = MoInfo;
handles.MoDims = MoDims;

handles.T1Map  = T1Data;
handles.T1Info = T1Info;
handles.T1Dims = T1Dims;

handles.T2Map  = T2Data;
handles.T2Info = T2Info;
handles.T2Dims = T2Dims;

clearvars MoMap MoInfo MoDims 
clearvars T1Map T1Info T1Dims 
clearvars T2Map T2Info T2Dims

handles.MoMap = squeeze(handles.MoMap);
handles.T1Map = squeeze(handles.T2Map);
handles.T1Map = squeeze(handles.T2Map);

handles.MoMap = squeeze(handles.MoMap);
handles.T1Map = squeeze(handles.T2Map);
handles.T1Map = squeeze(handles.T2Map);

% Fetch the image dimensions and set the slider step for the common slice accordingly
[ handles.NROWS, handles.NCOLS, handles.NPLNS ] = size(handles.MoMap);

if (handles.CommonSlice > handles.NPLNS)
  handles.CommonSlice = floor((handles.NPLNS + 1)/2);
end

set(handles.SliderCommonSlice, 'Min', 1);
set(handles.SliderCommonSlice, 'Max', handles.NPLNS);
set(handles.SliderCommonSlice, 'SliderStep', [ 1.0/double(handles.NPLNS - 1), 1.0/double(handles.NPLNS - 1)]);
set(handles.SliderCommonSlice, 'Value', handles.CommonSlice);
set(handles.EditCommonSlice, 'String', sprintf('Slice: %1d', handles.CommonSlice));

% Display the current slice of each parameter map - calculate the WI en passant
handles.CommonSlice = get(handles.SliderCommonSlice, 'Value');

handles.MoSlice = handles.CommonSlice;
handles.T1Slice = handles.CommonSlice;
handles.T2Slice = handles.CommonSlice;

handles.MoPart = squeeze(handles.MoMap(:, :, handles.MoSlice));
handles.T1Part = squeeze(handles.T1Map(:, :, handles.T1Slice));
handles.T2Part = squeeze(handles.T2Map(:, :, handles.T2Slice));

handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);
imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);
imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);
imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);

colormap(handles.AxesMo, handles.ColormapMo);
colormap(handles.AxesT1, handles.ColormapT1);
colormap(handles.AxesT2, handles.ColormapT2);
colormap(handles.AxesWI, handles.ColormapWI);

% Annotate the images
if (handles.ShowCaptions == true)
  text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MenuSaveResults_Callback(hObject, eventdata, handles)

% Exit early if there is nothing to do
Valid = handles.SaveMapSlices || handles.SaveMapStacks || handles.SaveWISlice || handles.SaveWIStack || handles.SaveDicomStack;

if (Valid == false)
  h = pft_MsgBox({ 'Nothing to save !'; ''; 'Set some Export options.'; '' }, 'Cancel', 'modal');
  uiwait(h);
  delete(h);
  
  guidata(hObject, handles);
  
  return;
end  

% Create an XL header
Head = { 'Mo LL', 'Mo UL', 'Mo colormap', ...
         'T1 LL/ms', 'T1 UL/ms', 'T1 colormap', ...
         'T2 LL/ms', 'T2 UL.ms', 'T2 colormap', ...
         'WI LL', 'WI UL', 'WI colormap', ...
         'Slice', ...
         'Image weighting mode', ...
         'TR/ms', 'TE/ms', 'Noise/PC' };
     
% Now the corresponding data     
Data = { handles.MoLower, handles.MoUpper, handles.ColormapNameMo, ...
         handles.T1Lower, handles.T1Upper, handles.ColormapNameT1, ...
         handles.T2Lower, handles.T2Upper, handles.ColormapNameT2, ...
         handles.WILower, handles.WIUpper, handles.ColormapNameWI, ...
         handles.CommonSlice, ...
         handles.NewWeightingMode, ...
         handles.TR, handles.TE, handles.NoisePC };
     
% Combine them into one cell array     
Full = vertcat(Head, Data);

% Create the o/p folder if it doesn't exist
if (exist(handles.SaveFolder, 'dir') ~= 7)
  mkdir(handles.SaveFolder);
end

% List the files in the default o/p folder by prefix and find the most recent - parameter files will always be saved with other o/p
Listing = dir(fullfile(handles.SaveFolder, '*.xlsx'));
Folders = [ Listing.isdir ];
Entries = { Listing.name };
Entries = Entries(~Folders);
Entries = sort(Entries);
Entries = Entries';

if isempty(Entries)
  Prefix = sprintf('%06d', 1);
else
  String = cellfun(@(c) c(1:6), Entries, 'UniformOutput', false);

  Number = str2num(String{end}) + 1;
  
  Prefix = sprintf('%06d', Number);
end

% Nominate a destination for the parameter file
[ FileName, PathName, FilterIndex ] = uiputfile(fullfile(handles.SaveFolder, '*.xlsx'), ...
                                               'First Save Parameter File As', ...
                                                fullfile(handles.SaveFolder, sprintf('%s-Parameters.xlsx', Prefix)));

if (FilterIndex == 0)
  guidata(hObject, handles);
  
  return;
else
  xlswrite(fullfile(PathName, FileName), Full, 'Simulation Parameters');
end

% Save the current parameter map slices on request
if (handles.SaveMapSlices == true)
  X = getframe(handles.AxesMo);
  C = X.cdata;
  T = fullfile(handles.SaveFolder, sprintf('%s-Mo-Map-Slice-%1d.png', Prefix, handles.CommonSlice));
  imwrite(C, T);

  X = getframe(handles.AxesT1);
  C = X.cdata;
  T = fullfile(handles.SaveFolder, sprintf('%s-T1-Map-Slice-%1d.png', Prefix, handles.CommonSlice));
  imwrite(C, T);
  
  X = getframe(handles.AxesT2);
  C = X.cdata;
  T = fullfile(handles.SaveFolder, sprintf('%s-T2-Map-Slice-%1d.png', Prefix, handles.CommonSlice));
  imwrite(C, T);
end

% Save the current weighted image on request
if (handles.SaveWISlice == true)
  X = getframe(handles.AxesWI);
  C = X.cdata;
  T = fullfile(handles.SaveFolder, sprintf('%s-WI-Slice-%1d.png', Prefix, handles.CommonSlice));
  imwrite(C, T);
end

% Save a stack of parameter maps if requested - the logic here is nested, because the display is common to several saving options 
if (handles.SaveMapStacks == true) || (handles.SaveWIStack == true) || (handles.SaveDicomStack == true)
  handles.OriginalSlice = handles.CommonSlice;
  
  if (handles.SaveDicomStack == true)
    Dictionary = dicomdict('get');  
      
    handles.DicomSaveFolder = fullfile(handles.SaveFolder, sprintf('%s-DICOM', Prefix));
    
    if (exist(handles.DicomSaveFolder, 'dir') ~= 7)
      mkdir(handles.DicomSaveFolder);
    end
  end
  
  for s = 1:handles.NPLNS
    handles.CommonSlice = s;
    set(handles.SliderCommonSlice, 'Value', s);
    set(handles.EditCommonSlice, 'String', sprintf('Slice: %1d', s));

    handles.MoSlice = handles.CommonSlice;
    handles.T1Slice = handles.CommonSlice;
    handles.T2Slice = handles.CommonSlice;

    handles.MoPart = squeeze(handles.MoMap(:, :, handles.MoSlice));
    handles.T1Part = squeeze(handles.T1Map(:, :, handles.T1Slice));
    handles.T2Part = squeeze(handles.T2Map(:, :, handles.T2Slice));

    handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

    imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);
    colormap(handles.AxesMo, handles.ColormapMo);

    imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);
    colormap(handles.AxesT1, handles.ColormapT1);

    imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);
    colormap(handles.AxesT2, handles.ColormapT2);

    imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);
    colormap(handles.AxesWI, handles.ColormapWI);

    if (handles.ShowCaptions == true)
      text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
      text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
      text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
      text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
      text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
    end
    
    if (handles.SaveMapStacks == true)
      X = getframe(handles.AxesMo);
      C = X.cdata;
      T = fullfile(handles.SaveFolder, sprintf('%s-Mo-Map-Stack.tif', Prefix));
      imwrite(C, T, 'WriteMode', 'append');

      X = getframe(handles.AxesT1);
      C = X.cdata;
      T = fullfile(handles.SaveFolder, sprintf('%s-T1-Map-Stack.tif', Prefix));
      imwrite(C, T, 'WriteMode', 'append');
  
      X = getframe(handles.AxesT2);
      C = X.cdata;
      T = fullfile(handles.SaveFolder, sprintf('%s-T2-Map-Stack.tif', Prefix));
      imwrite(C, T, 'WriteMode', 'append');
    end
    
    if (handles.SaveWIStack == true)
      X = getframe(handles.AxesWI);
      C = X.cdata;
      T = fullfile(handles.SaveFolder, sprintf('%s-WI-Stack.tif', Prefix));
      imwrite(C, T, 'WriteMode', 'append');
    end
    
    if (handles.SaveDicomStack == true)
      pause(0.05);  
        
      Header = handles.MoInfo{s};
      Pixels = uint16(handles.WIPart);
      
      Header.RepetitionTime    = handles.TR;
      Header.EchoTime          = handles.TE;
      Header.SeriesDescription = 'RSS synthetic image';
      Header.ImageComments     = sprintf('%.2f PC added noise', handles.NoisePC);
      
      SaveFile = sprintf('Slice-%04d.dcm', s);
      SavePath = fullfile(handles.DicomSaveFolder, SaveFile);
      
      dicomwrite(Pixels, SavePath, Header, 'Dictionary', Dictionary, 'CreateMode', 'copy', 'WritePrivate', true);
    end    
  end          
 
  handles.CommonSlice = handles.OriginalSlice;
  set(handles.SliderCommonSlice, 'Value', handles.CommonSlice);
  set(handles.EditCommonSlice, 'String', sprintf('Slice: %1d', handles.CommonSlice));

  handles.MoSlice = handles.CommonSlice;
  handles.T1Slice = handles.CommonSlice;
  handles.T2Slice = handles.CommonSlice;

  handles.MoPart = squeeze(handles.MoMap(:, :, handles.MoSlice));
  handles.T1Part = squeeze(handles.T1Map(:, :, handles.T1Slice));
  handles.T2Part = squeeze(handles.T2Map(:, :, handles.T2Slice));

  handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

  imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);
  colormap(handles.AxesMo, handles.ColormapMo);

  imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);
  colormap(handles.AxesT1, handles.ColormapT1);

  imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);
  colormap(handles.AxesT2, handles.ColormapT2);

  imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);
  colormap(handles.AxesWI, handles.ColormapWI);

  if (handles.ShowCaptions == true)
    text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
    text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
    text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
    text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
    text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  end    
end

% Update the handles structure
guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MenuImportParameters_Callback(hObject, eventdata, handles)

% Prompt for an XLSX file - but return early if nothing is selected
[ FileName, PathName, FilterIndex ] = uigetfile(fullfile(handles.SaveFolder, '*.xlsx'), 'Select a Parameter File');

if (FilterIndex == 0)
  guidata(hObject, handles);
  
  return;
end

% Read in the parameters from the Sequence Parameters tab
[ Num, Txt, Raw ] = xlsread(fullfile(PathName, FileName), 'Simulation Parameters');

Head = Raw(1, :);
Data = Raw(2, :);

% Now apply the values to the controls and (disabled) edit windows, one by one
handles.MoLower = Data{1};                                                              % 1
set(handles.SliderMoLower, 'Value', handles.MoLower);
set(handles.EditMoLower, 'String', sprintf('Lower: %1d', handles.MoLower));     

handles.MoUpper = Data{2};
set(handles.SliderMoUpper, 'Value', handles.MoUpper);
set(handles.EditMoUpper, 'String', sprintf('Upper: %1d', handles.MoUpper));             % 2

handles.ColormapNameMo = Data{3};                                                       % 3
V = find(strcmpi(handles.ColormapNames, handles.ColormapNameMo), 1, 'first');
set(handles.ListColormapMo, 'Value', V);
if strcmpi(handles.ColormapNameMo, 'vga')
  handles.ColormapMo = vga;
else
  handles.ColormapMo = eval(sprintf('%s(256)', handles.ColormapNameMo));
end

handles.T1Lower = Data{4};                                                              % 4
set(handles.SliderT1Lower, 'Value', handles.T1Lower);
set(handles.EditT1Lower, 'String', sprintf('Lower: %1d ms', handles.T1Lower));     

handles.T1Upper = Data{5};
set(handles.SliderT1Upper, 'Value', handles.T1Upper);
set(handles.EditT1Upper, 'String', sprintf('Upper: %1d ms', handles.T1Upper));          % 5

handles.ColormapNameT1 = Data{6};                                                       % 6
V = find(strcmpi(handles.ColormapNames, handles.ColormapNameT1), 1, 'first');
set(handles.ListColormapT1, 'Value', V);
if strcmpi(handles.ColormapNameT1, 'vga')
  handles.ColormapT1 = vga;
else
  handles.ColormapT1 = eval(sprintf('%s(256)', handles.ColormapNameT1));
end

handles.T2Lower = Data{7};                                                              % 7
set(handles.SliderT2Lower, 'Value', handles.T2Lower);
set(handles.EditT2Lower, 'String', sprintf('Lower: %1d ms', handles.T2Lower));     

handles.T2Upper = Data{8};
set(handles.SliderT2Upper, 'Value', handles.T2Upper);
set(handles.EditT2Upper, 'String', sprintf('Upper: %1d ms', handles.T2Upper));          % 8

handles.ColormapNameT2 = Data{9};                                                       % 9
V = find(strcmpi(handles.ColormapNames, handles.ColormapNameT2), 1, 'first');
set(handles.ListColormapT2, 'Value', V);
if strcmpi(handles.ColormapNameT2, 'vga')
  handles.ColormapT2 = vga;
else
  handles.ColormapT2 = eval(sprintf('%s(256)', handles.ColormapNameT2));
end

handles.WILower = Data{10};                                                             % 10
set(handles.SliderWILower, 'Value', handles.WILower);
set(handles.EditWILower, 'String', sprintf('Lower: %1d', handles.WILower));     

handles.WIUpper = Data{11};
set(handles.SliderWIUpper, 'Value', handles.WIUpper);
set(handles.EditWIUpper, 'String', sprintf('Upper: %1d', handles.WIUpper));             % 11

handles.ColormapNameWI = Data{12};                                                      % 12
V = find(strcmpi(handles.ColormapNames, handles.ColormapNameWI), 1, 'first');
set(handles.ListColormapWI, 'Value', V);
if strcmpi(handles.ColormapNameWI, 'vga')
  handles.ColormapWI = vga;
else
  handles.ColormapWI = eval(sprintf('%s(256)', handles.ColormapNameWI));
end

handles.CommonSlice = Data{13};                                                         % 13
if (handles.CommonSlice > handles.NPLNS)
  handles.CommonSlice = floor((handles.NPLNS + 1)/2);
end
set(handles.SliderCommonSlice, 'Value', handles.CommonSlice);
set(handles.EditCommonSlice, 'String', sprintf('Slice: %1d', handles.CommonSlice));

handles.NewWeightingMode = Data{14};                                                    % 14
switch handles.NewWeightingMode
  case 'Custom'
    set(handles.ButtonGroupWeighting, 'SelectedObject', handles.RadioWeightingCustom);
  case 'Proton Density'
    set(handles.ButtonGroupWeighting, 'SelectedObject', handles.RadioWeightingProtonDensity);  
  case 'T1W'
    set(handles.ButtonGroupWeighting, 'SelectedObject', handles.RadioWeightingT1W);
  case 'T2W'
    set(handles.ButtonGroupWeighting, 'SelectedObject', handles.RadioWeightingT2W);
  case 'Mixed'
    set(handles.ButtonGroupWeighting, 'SelectedObject', handles.RadioWeightingMixed);
end
if strcmpi(handles.NewWeightingMode, 'Custom')
  set(handles.EditTR, 'Enable', 'on');
  set(handles.SliderTR, 'Enable', 'on');

  set(handles.EditTE, 'Enable', 'on');
  set(handles.SliderTE, 'Enable', 'on');
else
  set(handles.EditTR, 'Enable', 'inactive');
  set(handles.SliderTR, 'Enable', 'off');

  set(handles.EditTE, 'Enable', 'inactive');
  set(handles.SliderTE, 'Enable', 'off');
end

handles.TR = Data{15};                                                                  % 15
set(handles.SliderTR, 'Value', handles.TR);
set(handles.EditTR, 'String', sprintf('TR: %1d ms', handles.TR));

handles.TE = Data{16};                                                                  % 16
set(handles.SliderTE, 'Value', handles.TE);
set(handles.EditTE, 'String', sprintf('TE: %1d ms', handles.TE));

handles.NoisePC = Data{17};                                                             % 17
set(handles.SliderNoisePC, 'Value', handles.NoisePC);
set(handles.EditNoisePC, 'String', sprintf('Noise: %.2f %%', handles.NoisePC));

% Now re-display the images with the new parameters
handles.MoSlice = handles.CommonSlice;
handles.T1Slice = handles.CommonSlice;
handles.T2Slice = handles.CommonSlice;

handles.MoPart = squeeze(handles.MoMap(:, :, handles.MoSlice));
handles.T1Part = squeeze(handles.T1Map(:, :, handles.T1Slice));
handles.T2Part = squeeze(handles.T2Map(:, :, handles.T2Slice));

handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);
imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);
imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);
imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);

colormap(handles.AxesMo, handles.ColormapMo);
colormap(handles.AxesT1, handles.ColormapT1);
colormap(handles.AxesT2, handles.ColormapT2);
colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

% Update the handles structure
guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MenuSaveParameters_Callback(hObject, eventdata, handles)

% Create an XL header
Head = { 'Mo LL', 'Mo UL', 'Mo colormap', ...
         'T1 LL/ms', 'T1 UL/ms', 'T1 colormap', ...
         'T2 LL/ms', 'T2 UL.ms', 'T2 colormap', ...
         'WI LL', 'WI UL', 'WI colormap', ...
         'Slice', ...
         'Image weighting mode', ...
         'TR/ms', 'TE/ms', 'Noise/PC' };
     
% Now the corresponding data     
Data = { handles.MoLower, handles.MoUpper, handles.ColormapNameMo, ...
         handles.T1Lower, handles.T1Upper, handles.ColormapNameT1, ...
         handles.T2Lower, handles.T2Upper, handles.ColormapNameT2, ...
         handles.WILower, handles.WIUpper, handles.ColormapNameWI, ...
         handles.CommonSlice, ...
         handles.NewWeightingMode, ...
         handles.TR, handles.TE, handles.NoisePC };
     
% Combine them into one cell array     
Full = vertcat(Head, Data);

% Create the o/p folder if it doesn't exist
if (exist(handles.SaveFolder, 'dir') ~= 7)
  mkdir(handles.SaveFolder);
end

% List the files in the default o/p folder by prefix and find the most recent - parameter files will always be saved with other o/p
Listing = dir(fullfile(handles.SaveFolder, '*.xlsx'));
Folders = [ Listing.isdir ];
Entries = { Listing.name };
Entries = Entries(~Folders);
Entries = sort(Entries);
Entries = Entries';

if isempty(Entries)
  Prefix = sprintf('%06d', 1);
else
  String = cellfun(@(c) c(1:6), Entries, 'UniformOutput', false);

  Number = str2num(String{end}) + 1;
  
  Prefix = sprintf('%06d', Number);
end

% Nominate a destination for the parameter file
[ FileName, PathName, FilterIndex ] = uiputfile(fullfile(handles.SaveFolder, '*.xlsx'), ...
                                               'Save Parameters As', ...
                                                fullfile(handles.SaveFolder, sprintf('%s-Parameters.xlsx', Prefix)));

if (FilterIndex == 0)
  guidata(hObject, handles);
  
  return;
else
  xlswrite(fullfile(PathName, FileName), Full, 'Simulation Parameters');
end

% Update the handles structure
guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditTR_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditTR_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderTR_Callback(hObject, eventdata, handles)

handles.TR = round(get(hObject, 'Value'));

set(handles.EditTR, 'String', sprintf('TR: %1d ms', handles.TR));

if (handles.TR - handles.TE < 10.0)
  handles.TE = handles.TR - 10.0;
  set(handles.SliderTE, 'Value', handles.TE);
  set(handles.EditTE, 'String', sprintf('TE: %1d ms', handles.TE));
end

handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);

colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

function CB_SliderTR_Listener(hObject, eventdata, handles)

% This was necessary in MATLAB 2013b
if ~(exist('handles', 'var'))
  handles = guidata(hObject);  
end

handles.TR = round(get(hObject, 'Value'));

set(handles.EditTR, 'String', sprintf('TR: %1d ms', handles.TR));

if (handles.TR - handles.TE < 10.0)
  handles.TE = handles.TR - 10.0;
  set(handles.SliderTE, 'Value', handles.TE);
  set(handles.EditTE, 'String', sprintf('TE: %1d ms', handles.TE));
end

handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);

colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderTR_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditTE_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditTE_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderTE_Callback(hObject, eventdata, handles)

handles.TE = round(get(hObject, 'Value'));

set(handles.EditTE, 'String', sprintf('TE: %1d ms', handles.TE));

if (handles.TR - handles.TE < 10.0)
  handles.TR = handles.TE + 10.0;
  set(handles.SliderTR, 'Value', handles.TR);
  set(handles.EditTR, 'String', sprintf('TR: %1d ms', handles.TR));
end

handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);

colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

function CB_SliderTE_Listener(hObject, eventdata, handles)

% This was necessary in MATLAB 2013b
if ~(exist('handles', 'var'))
  handles = guidata(hObject);  
end

handles.TE = round(get(hObject, 'Value'));

set(handles.EditTE, 'String', sprintf('TE: %1d ms', handles.TE));

if (handles.TR - handles.TE < 10.0)
  handles.TR = handles.TE + 10.0;
  set(handles.SliderTR, 'Value', handles.TR);
  set(handles.EditTR, 'String', sprintf('TR: %1d ms', handles.TR));
end

handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);

colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderTE_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditNoisePC_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditNoisePC_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderNoisePC_Callback(hObject, eventdata, handles)

TOL = 1.0e-2;

handles.NoisePC = TOL*round(get(hObject, 'Value')/TOL);

set(handles.EditNoisePC, 'String', sprintf('Noise: %.2f %%', handles.NoisePC));

handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);

colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

function CB_SliderNoisePC_Listener(hObject, eventdata, handles)

% This was necessary in MATLAB 2013b
if ~(exist('handles', 'var'))
  handles = guidata(hObject);  
end

TOL = 1.0e-2;

handles.NoisePC = TOL*round(get(hObject, 'Value')/TOL);

set(handles.EditNoisePC, 'String', sprintf('Noise: %.2f %%', handles.NoisePC));

handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);

colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SliderNoisePC_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ButtonResetWindowing_Callback(hObject, eventdata, handles)

handles.MoUpper = 2000.0;
set(handles.SliderMoUpper, 'Value', handles.MoUpper);
set(handles.EditMoUpper, 'String', sprintf('Upper: %1d', handles.MoUpper));

handles.MoLower = 0.0;
set(handles.SliderMoLower, 'Value', handles.MoLower);
set(handles.EditMoLower, 'String', sprintf('Lower: %1d', handles.MoLower));

handles.T1Upper = 2000.0;
set(handles.SliderT1Upper, 'Value', handles.T1Upper);
set(handles.EditT1Upper, 'String', sprintf('Upper: %1d ms', handles.T1Upper));

handles.T1Lower = 0.0;
set(handles.SliderT1Lower, 'Value', handles.T1Lower);
set(handles.EditT1Lower, 'String', sprintf('Lower: %1d ms', handles.T1Lower));

handles.T2Upper = 1000.0;
set(handles.SliderT2Upper, 'Value', handles.T2Upper);
set(handles.EditT2Upper, 'String', sprintf('Upper: %1d ms', handles.T2Upper));

handles.T2Lower = 0.0;
set(handles.SliderT2Lower, 'Value', handles.T2Lower);
set(handles.EditT2Lower, 'String', sprintf('Lower: %1d ms', handles.T2Lower));

handles.WIUpper = 2000.0;
set(handles.SliderWIUpper, 'Value', handles.WIUpper);
set(handles.EditWIUpper, 'String', sprintf('Upper: %1d', handles.WIUpper));

handles.WILower = 0.0;
set(handles.SliderWILower, 'Value', handles.WILower);
set(handles.EditWILower, 'String', sprintf('Lower: %1d', handles.WILower));

imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);
colormap(handles.AxesMo, handles.ColormapMo);

imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);
colormap(handles.AxesT1, handles.ColormapT1);

imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);
colormap(handles.AxesT2, handles.ColormapT2);

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);
colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CheckShowCaptions_Callback(hObject, eventdata, handles)

handles.ShowCaptions = logical(get(hObject, 'Value')); 

handles.MoSlice = handles.CommonSlice;
handles.T1Slice = handles.CommonSlice;
handles.T2Slice = handles.CommonSlice;

handles.MoPart = squeeze(handles.MoMap(:, :, handles.MoSlice));
handles.T1Part = squeeze(handles.T1Map(:, :, handles.T1Slice));
handles.T2Part = squeeze(handles.T2Map(:, :, handles.T2Slice));

handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);
colormap(handles.AxesMo, handles.ColormapMo);

imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);
colormap(handles.AxesT1, handles.ColormapT1);

imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);
colormap(handles.AxesT2, handles.ColormapT2);

imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);
colormap(handles.AxesWI, handles.ColormapWI);

if (handles.ShowCaptions == true)
  text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ListCaptionColor_Callback(hObject, eventdata, handles)

M = get(hObject, 'Value');

handles.CurrentCaptionColor = handles.CaptionColors{M};

switch handles.CurrentCaptionColor
  case 'White'
    handles.TextColor = [1 1 1];
  case 'Black'
    handles.TextColor = [0 0 0];
  case 'Red'
    handles.TextColor = [1 0 0];
  case 'Green'
    handles.TextColor = [0 1 0];
  case 'Blue'
    handles.TextColor = [0 0 1];
  case 'Yellow'
    handles.TextColor = [1 1 0];
  case 'Cyan'
    handles.TextColor = [0 1 1];     
  case 'Magenta'
    handles.TextColor = [1 0 1];     
end

if (handles.ShowCaptions == true)
  handles.MoSlice = handles.CommonSlice;
  handles.T1Slice = handles.CommonSlice;
  handles.T2Slice = handles.CommonSlice;

  handles.MoPart = squeeze(handles.MoMap(:, :, handles.MoSlice));
  handles.T1Part = squeeze(handles.T1Map(:, :, handles.T1Slice));
  handles.T2Part = squeeze(handles.T2Map(:, :, handles.T2Slice));

  handles.WIPart = pft_WeightedImage(handles.MoPart, handles.T1Part, handles.T2Part, handles.TR, handles.TE, handles.NoisePC);

  imshow(handles.MoPart, [handles.MoLower, handles.MoUpper], 'Parent', handles.AxesMo);
  colormap(handles.AxesMo, handles.ColormapMo);

  imshow(handles.T1Part, [handles.T1Lower, handles.T1Upper], 'Parent', handles.AxesT1);
  colormap(handles.AxesT1, handles.ColormapT1);

  imshow(handles.T2Part, [handles.T2Lower, handles.T2Upper], 'Parent', handles.AxesT2);
  colormap(handles.AxesT2, handles.ColormapT2);

  imshow(handles.WIPart, [handles.WILower, handles.WIUpper], 'Parent', handles.AxesWI);
  colormap(handles.AxesWI, handles.ColormapWI);

  text(handles.AxesMo, 4, 14, sprintf('M_o: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT1, 4, 14, sprintf('T_1: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesT2, 4, 14, sprintf('T_2: %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, 14, sprintf('WI:  %1d/%1d', handles.CommonSlice, handles.NPLNS), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
  text(handles.AxesWI, 4, handles.NROWS - 14, sprintf('%s: TR/TE = %1d/%1d', handles.NewWeightingMode, handles.TR, handles.TE), 'Color', handles.TextColor, 'FontSize', 11, 'FontWeight', 'bold');
end

guidata(hObject, handles);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ListCaptionColor_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditReadPickle_Callback(hObject, eventdata, handles)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditReadPickle_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end
