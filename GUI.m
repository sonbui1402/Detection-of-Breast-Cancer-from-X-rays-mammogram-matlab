function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 17-Jul-2020 00:42:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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
function browser_Callback(hObject, eventdata, handles)
% hObject    handle to browser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 [name, pathname] = uigetfile('*.jpg', 'Pick a Image');
    
    I=strcat(pathname,name);
    I=imread(I);
    imwrite(I,'img.pgm')
    img= imread('img.pgm');
    mkdir ('C:\MatlabTmp'); %tao thu den thu muc c:\MatlabTmp
    imwrite(I, 'C:\MatlabTmp\org.bmp'); % tao ra tap tin 1.Original.bmp vao thu muc MatlabTmp
    axes(handles.axes2);
    imshow(I);
    handles.img=img;
    guidata(hObject, handles);
    
  
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using GUI.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        img=handles.img;
        %% tang cuong chat luong anh
        I = imread('C:\MatlabTmp\org.bmp');
        I = rgb2gray(I);
        BW2 = enhance_mam(I);
        
        %% bo loc trung v? v?i ma tr?n 15x15
        img_median=medfilt2(BW2,[15,15]);
        
        %% phan vùng anh voi he so threshold là 0.32
        max_pixel=max(max(img_median));
        min_pixel=min(min(img_median));
        new_max_pixel=210;
        new_min_pixel=60;
        temp= (new_max_pixel - new_min_pixel)/(max_pixel - min_pixel);
        normalize_img = (temp.*(img_median - min_pixel)) + new_min_pixel;  % normalize the image
        threshold= graythresh(normalize_img);
        bw_img= im2bw(normalize_img,(threshold + 0.32));
        
        %% bo loc Sobel
        BW = edge(bw_img,'sobel',0.5) ;
        %% --------------
axes(handles.axes1);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        imshow(BW2)
    case 2
        imshow(img_median);
        
    case 3
        imshow(bw_img);
        
    case 4
        imshow(BW);
       
    case 5
         %% chon vùng nghi ngo ton thuong
        final_img = bwselect(bw_img);  %select the component of threshold
        imshow(final_img);

        x = zeros(3,1); 


        I = normalize_img;  %set I as the normalized image
        final_img = imfill(final_img);

        for i=1:size(final_img,1)     % iterate through the black-white image and find the coordinates of the white portions
            for j=1:size(final_img,2)
               I(i,j) = 0;
               if final_img(i,j) == 1
                     final_img(i,j)
                    x(1,end+1) = i;
                    x(2,end) = j;
                end
            end
        end


        for j=2:size(x,2)
                x(3,j) = img(x(1,j),x(2,j));
                I(x(1,j),x(2,j)) = 60;

        end

        for j=2:size(x,2)
                I(x(1,j),x(2,j)) = x(3,j);

        end

        x1 = x(:,2:size(x,2));
        max_dim = max(x,[],2);
        min_dim = min(x1,[],2);

        x_max = max_dim(1);
        x_min = min_dim(1);
        y_max = max_dim(2);
        y_min = min_dim(2);

        I_old = I;

        for i=x_min:x_max
            for j=y_min:y_max
                I(i,j) = img(i,j);
            end
        end
       
        new_img = I(x_min:x_max,y_min:y_max);
        old_img = I_old(x_min:x_max,y_min:y_max);

        size(I)
        axes(handles.axes3);
        imshow(old_img)
        axes(handles.axes4);
        imshow(new_img)

end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {' tang cuong chat luong anh', 'Bo loc', 'Phan vung ton thuong', 'Phat hien duong bien', 'chon vung nghi ngo ton thuong' });


% --- Executes on button press in browser.

guidata(hObject, handles);



% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2
