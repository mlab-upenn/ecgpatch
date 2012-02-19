function varargout = Etiqbutton(varargin)
% ETIQBUTTON M-file for Etiqbutton.fig
%      ETIQBUTTON, by itself, creates a new ETIQBUTTON or raises the existing
%      singleton*.
%
%      H = ETIQBUTTON returns the handle to a new ETIQBUTTON or the handle to
%      the existing singleton*.
%
%      ETIQBUTTON('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETIQBUTTON.M with the given input arguments.
%
%      ETIQBUTTON('Property','Value',...) creates a new ETIQBUTTON or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Etiqbutton_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Etiqbutton_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help Etiqbutton

% Last Modified by GUIDE v2.5 11-Dec-2011 21:54:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Etiqbutton_OpeningFcn, ...
                   'gui_OutputFcn',  @Etiqbutton_OutputFcn, ...
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


% --- Executes just before Etiqbutton is made visible.
function Etiqbutton_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Etiqbutton (see VARARGIN)

%Carga la imagen de fondo (opcional)
%[x,map]=imread('hammerfall.jpg','jpg');
%image(x),colormap(map),axis off,hold on

set(hObject,'toolbar','figure');

% % %Coloca una imagen en cada botón
% % [a,map]=imread('vol.jpg');
% % [r,c,d]=size(a); 
% % x=ceil(r/30); 
% % y=ceil(c/30); 
% % g=a(1:x:end,1:y:end,:);
% % g(g==255)=5.5*255;
% % set(handles.pushbutton1,'CData',g);

[a,map]=imread('stop.jpg');
[r,c,d]=size(a); 
x=ceil(r/30); 
y=ceil(c/30); 
g=a(1:x:end,1:y:end,:);
g(g==255)=5.5*255;
set(handles.pushbutton2,'CData',g);

[a,map]=imread('play.jpg');
[r,c,d]=size(a); 
x=ceil(r/30); 
y=ceil(c/30); 
g=a(1:x:end,1:y:end,:);
g(g==255)=5.5*255;
set(handles.pushbutton3,'CData',g);

% % [a,map]=imread('open_files.jpg');
% % [r,c,d]=size(a); 
% % x=ceil(r/30); 
% % y=ceil(c/30); 
% % g=a(1:x:end,1:y:end,:);
% % g(g==255)=5.5*255;
% % set(handles.pushbutton4,'CData',g);

[a,map]=imread('cd_eject.jpg');
[r,c,d]=size(a); 
x=ceil(r/35); 
y=ceil(c/35); 
g=a(1:x:end,1:y:end,:);
g(g==255)=5.5*255;
set(handles.pushbutton5,'CData',g);

% % [a,map]=imread('pause.jpg');
% % [r,c,d]=size(a); 
% % x=ceil(r/100); 
% % y=ceil(c/80); 
% % g=a(1:x:end,1:y:end,:);
% % g(g==255)=5.5*255;
% % set(handles.pushbutton6,'CData',g);

% % [a,map]=imread('mute2.jpg');
% % [r,c,d]=size(a); 
% % x=ceil(r/30); 
% % y=ceil(c/30); 
% % g=a(1:x:end,1:y:end,:);
% % g(g==255)=5.5*255;
% % set(handles.pushbutton7,'CData',g);


axes(handles.axes1)
title('ECG Plot');
xlabel('Time [ms]')
ylabel('ADC Output')

%% Initializations
global time;
global data_2_write;
global flag;
global board;
global filename;
global t;
global board;

% Choose default command line output for Etiqbutton
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Etiqbutton wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Etiqbutton_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
flag=0
delete(INSTRFIND);
% % cla(handles.axes1,'reset');
guidata(hObject,handles);



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.axes1,'reset');
cla(handles.axes2,'reset');
cla(handles.axes3,'reset');
axes(handles.axes1)
xlim([1 1000])
ylim([-4*10^4 4*10^4])

axes(handles.axes2)
xlim([1 1000])
ylim([-4*10^4 4*10^4])

axes(handles.axes3)
xlim([1 1000])
ylim([-4*10^4 4*10^4])

%x=1:30
%y=1:30
%ECG_random();
%plot(x,y);
tic;

ECG_trial('COM3',handles);
guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = strcat(get(handles.edit2,'String'),'.txt');
fid = fopen(filename);
fprintf(fid,'%d \n',data_2_write);
fclose(fid)


function ECG_trial(port,handles)
%% Opens the serial port
board = serial(port,'BaudRate',115200);
fopen(board);

%% Begin Asynchronous
board.ReadAsyncMode = 'continuous';
readasync(board);

%% Opens the figure for the plot
xlabel('Time [ms]')
ylabel('ADC Output')

%% Initializations
n1 = [];
n2 = [];
n3 = [];

data = [];
time = 0;


data_2_write1 = [];
data_2_write2 = [];
data_2_write3 = [];

precision=25;
flag = 1;

node1 = [];
node2 = [];
node3 = [];

% reset the figure
cla(handles.axes1,'reset');

while(flag)
    
    data = fscanf(board,'%d,%d');   % Incoming data from serial port
    index = data(2);
    
    %------------------------------------node2------------------------------
    if index == 2
        node1 = [node1 data(1)];
        data_2_write1 = [data_2_write1 node1];
        if isempty(n1)                       % If n is empty, initializes the vector
            n1 = 1;
        else
            n1 = [n1 (n1(end)+1)];
        end
        
        modvalue = mod(n1(end),precision);  
        if modvalue == 0
            hold on
        
            axes(handles.axes1)
            
            xlim([1 1000])
            ylim([-4*10^4 4*10^4])

            plot(n1,node1,'r','LineWidth',1.5)                % Plot every set of 5 data points
            drawnow();
        
            ylabel('ADC Output')
    
            node1 = node1(end);
            n1 = n1(end);
            
            if n1(end) >= 1000
                n1 = 1;
                cla(handles.axes1,'reset');
            end
    end
    %---------------------node3--------------------------------
    elseif index == 3
        node2 = [node2 data(1)];
        data_2_write2 = [data_2_write2 node2];
        if isempty(n2)
            n2 = 1;
        else
            n2 = [n2 (n2(end)+1)];
        end
        
        modvalue = mod(n2(end),precision);
        if modvalue == 0
            hold on
        
            axes(handles.axes2)
            
            xlim([1 1000])
            ylim([-4*10^4 4*10^4])

            plot(n2,node2,'b','LineWidth',1.5)                % Plot every set of 5 data points
            drawnow();
        
            ylabel('ADC Output')
        
            node2 = node2(end);
            n2 = n2(end);
            
            if n2(end) >= 1000
                n2 = 1;
                cla(handles.axes2,'reset');
            end
    end
   %-----------------------------------node4----------------------------------- 
    elseif index == 4
        node3 = [node3 data(1)];
        data_2_write3 = [data_2_write3 node3];
        if isempty(n3)
            n3 = 1;
        else                  
            n3 = [n3 (n3(end)+1)];
        end
        modvalue = mod(n3(end),precision);
        if modvalue == 0
            hold on
                 
            axes(handles.axes3)
            
            xlim([1 1000])
            ylim([-4*10^4 4*10^4])
            
            plot(n3,node3,'g','LineWidth',1.5)                % Plot every set of 5 data points
            drawnow();
        
            xlabel('Time [ms]')
            ylabel('ADC Output')
        
            node3 = node3(end);
            n3 = n3(end);
            
            if n3(end) >= 1000
                n3 = 1;
                cla(handles.axes3,'reset');
            end
    end
end
    
    
    time = time+1
end
    
    
    
    
    
    


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
filename = strcat(get(handles.edit2,'String'),'.txt');


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
