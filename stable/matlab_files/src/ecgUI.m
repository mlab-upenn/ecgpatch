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

% Last Modified by GUIDE v2.5 13-Dec-2011 10:30:12

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


set(hObject,'toolbar','figure');

%-----------------------------Global Variables-----------------------------
global flag;
global dataWrite;
cla(handles.text20,'reset');

[a,map]=imread('stop_heart.png');
[r,c,d]=size(a); 
x=ceil(r/30); 
y=ceil(c/30); 
g=a(1:x:end,1:y:end,:);
g(g==255)=5.5*255;
set(handles.pushbutton2,'CData',g);

[a,map]=imread('play_heart.png');
[r,c,d]=size(a); 
x=ceil(r/30); 
y=ceil(c/30); 
g=a(1:x:end,1:y:end,:);
g(g==255)=5.5*255;
set(handles.pushbutton3,'CData',g);

[a,map]=imread('write_to_file.jpg');
[r,c,d]=size(a); 
x=ceil(r/35); 
y=ceil(c/35); 
g=a(1:x:end,1:y:end,:);
g(g==255)=5.5*255;
set(handles.pushbutton5,'CData',g);

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
global flag;
flag=0;
% % fclose(board)
delete(INSTRFIND);
% % cla(handles.axes1,'reset');
guidata(hObject,handles);



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global flag;
flag = 1;
cla(handles.axes1,'reset');
cla(handles.axes2,'reset');
cla(handles.axes3,'reset');

axes(handles.axes1)
xlim([1 1000])
ylim([-4*10^4 4*10^4])
% title('Node 1')
ylabel('ADC Output')

axes(handles.axes2)
xlim([1 1000])
ylim([-4*10^4 4*10^4])
% title('Node 2')
ylabel('ADC Output')

axes(handles.axes3)
xlim([1 1000])
ylim([-4*10^4 4*10^4])
ylabel('ADC Output')
% title('Node 3')
%x=1:30
%y=1:30
%ECG_random();
%plot(x,y);
tic;

ECG_trial('/dev/ttyUSB0',handles);
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
global dataWrite;
global filename;

filename = strcat(get(handles.edit2,'String'),'.txt')
fid = fopen(filename,'w')
fprintf(fid,'%d \n',dataWrite);
fclose(fid)


function ECG_trial(port,handles)
%----------------------Global Variables------------------------------------
global flag;
global dataWrite;
global filename;

%% Opens the serial port
board = serial(port,'BaudRate',115200);
fopen(board);

%% Begin Asynchronous
board.ReadAsyncMode = 'continuous';
readasync(board);

%% Opens the figure for the plot
% % xlabel('Time [1s/100]')
% % ylabel('ADC Output')

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
% % flag = 1;
index1 = [];
index2 = [];
index3 = [];

% % node1 = [];
% % node2 = [];
node3 = [];
data1= [];
data2 = [];
data3 = [];

i1 = [];
i2 = [];
i3 = [];

long_data1 = [];
dataWrite = zeros(1,3);
                            
b = fir1(98,0.04,'high');           % high pass filter

while(flag)
    
    data = fscanf(board,'%d,%d');   % Incoming data from serial port
    index = data(2);
    
    %------------------------------------node2-----------------------------
    if index == 2

        %--------------new stuff-------------------------------------------
        data_2_write1 = [data_2_write1 data(1)];       
        if isempty(index1)                       % If n is empty, initializes the vector
            index1 = 1;
        else
            index1 = [index1 (index1(end)+1)];
        end      
        
        if length(data_2_write1) > 99
            sum_i = index1(end):-1:index1(end-98);
            data1 = [data1 data_2_write1(sum_i)*b'];
            long_data1 = [long_data1 data_2_write1(sum_i)*b'];
           if isempty(n1)
               n1 = 1;
               i1 = 1;
           else
               n1 = [n1 (n1(end)+1)];
               i1 = [i1 (i1(end)+1)];
           end
        
           dataWrite(n1,1) = data1;
           
        modvalue = mod(n1(end),precision);  
        if modvalue == 0
            hold on
        
            axes(handles.axes1)
            
            xlim([1 1000])
            ylim([-4*10^4 4*10^4])

            plot(n1,data1,'r','LineWidth',1.5)                % Plot every set of 5 data points
            drawnow();
        
            ylabel('ADC Output')
%             title('Node 1')
            
            if i1(end) >= 500
                %-------BPM Output---------------------
                BPM = ProcessSignal(long_data1,0,0,i1,0,0);
            
                bpm = num2str(BPM);
                set(handles.text20,'String',bpm);
%                 guidata(hObject,handles);
                i1 = 1;
                long_data1 = long_data1(end);
            end
    
            data1 = data1(end);
            n1 = n1(end);
            
            if n1(end) >= 1000
                n1 = 1;
                cla(handles.axes1,'reset');
            end
        end
        end
    %---------------------node3--------------------------------
    elseif index == 3
        %--------------new stuff-------------------------------------------
        data_2_write2 = [data_2_write2 data(1)];       
        if isempty(index2)                       % If n is empty, initializes the vector
            index2 = 1;
        else
            index2 = [index2 (index2(end)+1)];
        end
        
        
        if length(data_2_write2) > 99
            sum_i = index2(end):-1:index2(end-98);
            data2 = [data2 data_2_write2(sum_i)*b'];
           if isempty(n2)
               n2 = 1;
           else
               n2 = [n2 (n2(end)+1)];
           end
           
           dataWrite(n2,2) = data2;
        
        modvalue = mod(n2(end),precision);  
        if modvalue == 0
            hold on
        
            axes(handles.axes2)
            
            xlim([1 1000])
            ylim([-4*10^4 4*10^4])

            plot(n2,data2,'b','LineWidth',1.5)                % Plot every set of 5 data points
            drawnow();
        
            ylabel('ADC Output')
%       ``w       title('Node 2')
    
            data2 = data2(end);
            n2 = n2(end);
            
            if n2(end) >= 1000
                n2 = 1;
                cla(handles.axes2,'reset');
            end
        end
        end
   %-----------------------------------node4----------------------------------- 
    elseif index == 4
        node3 = [node3 data(1)];
%         data_2_write3 = [data_2_write3 node3];
        if isempty(n3)
            n3 = 1;
        else                  
            n3 = [n3 (n3(end)+1)];
        end
        
        dataWrite(n3,3) = node3;
        
        modvalue = mod(n3(end),precision);
        if modvalue == 0
            hold on
                 
            axes(handles.axes3)
            
            xlim([1 1000])
            ylim([-4*10^4 4*10^4])
            
            plot(n3,node3,'g','LineWidth',1.5)                % Plot every set of 5 data points
            drawnow();
        
            xlabel('Time [1s/100]')
            ylabel('ADC Output')
%             title('Node 3')
        
            node3 = node3(end);
            n3 = n3(end);
            
            if n3(end) >= 1000
                n3 = 1;
                cla(handles.axes3,'reset');
            end
        end
    end
% % 
% %     
% %     dataWrite(time,:) = [data1(1) data2(1) node3];
    time = time+1;
    
end
    
    
    
    
    
    


% % % --- Executes on button press in checkbox1.
% % function checkbox1_Callback(hObject, eventdata, handles)
% % % hObject    handle to checkbox1 (see GCBO)
% % % eventdata  reserved - to be defined in a future version of MATLAB
% % % handles    structure with handles and user data (see GUIDATA)
% % 
% % % Hint: get(hObject,'Value') returns toggle state of checkbox1


% % % --- Executes on button press in checkbox3.
% % function checkbox3_Callback(hObject, eventdata, handles)
% % % hObject    handle to checkbox3 (see GCBO)
% % % eventdata  reserved - to be defined in a future version of MATLAB
% % % handles    structure with handles and user data (see GUIDATA)
% % 
% % % Hint: get(hObject,'Value') returns toggle state of checkbox3
% % 
% % 
% % % --- Executes on button press in checkbox4.
% % function checkbox4_Callback(hObject, eventdata, handles)
% % % hObject    handle to checkbox4 (see GCBO)
% % % eventdata  reserved - to be defined in a future version of MATLAB
% % % handles    structure with handles and user data (see GUIDATA)
% % 
% % % Hint: get(hObject,'Value') returns toggle state of checkbox4
% % 
% % 
% % % --- Executes on button press in checkbox5.
% % function checkbox5_Callback(hObject, eventdata, handles)
% % % hObject    handle to checkbox5 (see GCBO)
% % % eventdata  reserved - to be defined in a future version of MATLAB
% % % handles    structure with handles and user data (see GUIDATA)
% % 
% % % Hint: get(hObject,'Value') returns toggle state of checkbox5



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
global filename;
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


