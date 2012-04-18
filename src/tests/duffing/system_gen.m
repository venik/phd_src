% 15-Feb-2011, it6, www.mgupi.ru  
% 1621 - Control in technical systems
% Linear System design and visualization tool
% usage: system_gen()
% dependencies: Control System Toolbox
% this function produces diff. equation on the 
% TEX-compatible form and store it into clipboard
% -&*-
function system_gen(varargin)
if nargin==0
    main() ;
elseif nargin==1
    if varargin{1}==1
        OnPoleZerosClick() ;
    end
elseif  nargin==2
    if varargin{1}==2
        OnToolBarButton_InputMode(varargin{2})
    elseif varargin{1}==3
        OnToolBarButton_InputType(varargin{2})
    end
else
    printf('system_gen usage: system_gen()\n') ;
end

function main()
clc ;
szTitle = 'Linear System design and visualization tool, v1.0, (c) MGUPI, 2011' ;
fprintf([szTitle, '\n']) ;
v = ver('control') ;
fprintf('%s. Version:%s Release: %s Date:%s\n', v.Name, v.Version, v.Release, v.Date ) ;
fig = figure(1) ;
set(fig,'Name',szTitle) ;
set(fig,'NumberTitle','off') ;
clf ;
figPos = get(fig,'Position') ;
figPos(3) = 800 ;
figPos(4) = 500 ;
set(fig,'Position',figPos) ;
obj.axes_polezeros = axes() ;
set(obj.axes_polezeros,'Position',[0.03 0.5 0.43 0.45],'ButtonDownFcn','system_gen(1)') ;
xlim([-10 2]) ;
ylim([-15 15]) ;
text(-15,2,'Click here','FontSize',14) ;
title('Pole-zero plot') ;
plot_zeropoles_axes() ;
line([0 0],[-10 10],'LineStyle',':','Color',[0.1 0.1 0.1],'LineWidth',2) ;
grid on;
set(gca,'XColor',[.3 .3 .3], 'YColor',[.3 .3 .3])
set(gca,'FontSize',8) ;
obj.axes_sr = axes() ;
set(obj.axes_sr,'Position',[0.51 0.5 0.47 0.47]) ;
grid on;
step(1,[1 2]) ;
obj.axes_fr = axes() ;
set(obj.axes_fr,'Position',[0.03 0.05 0.43 0.36]) ;
grid on;
set(gca,'XColor',[.3 .3 .3], 'YColor',[.3 .3 .3])
set(gca,'FontSize',8) ;
title('Frequency response') ;

obj.axes_ir = axes() ;
set(obj.axes_ir,'Position',[0.52 0.05 0.46 0.36]) ;
grid on;
set(gca,'XColor',[.3 .3 .3], 'YColor',[.3 .3 .3])
set(gca,'FontSize',8) ;
title('impulse response') ;

obj.poles = [] ;
obj.zeros = [] ;
obj.inputMode = 0 ;
obj.inputType = 1 ;

% add buttons into figure's toolbar
if isempty(get(gcf,'UserData'))
    tbh = findall(gcf,'Type','uitoolbar') ;
    
    obj.toolbar_buttons = zeros(6,1) ;
    obj.toolbar_buttons(1) = uitoggletool(tbh,'CData',toolbar_image(1),...
                'Separator','on','TooltipString','Change pole',...
                'HandleVisibility','off', 'ClickedCallback', 'system_gen(2,0)' ) ;
    obj.toolbar_buttons(2) = uitoggletool(tbh,'CData',toolbar_image(2),...
                'Separator','off',...
                'HandleVisibility','off', 'ClickedCallback', 'system_gen(2,1)' ) ;
    obj.toolbar_buttons(3) = uitoggletool(tbh,'CData',toolbar_image(3),...
                'Separator','off',...
                'HandleVisibility','off', 'ClickedCallback', 'system_gen(2,2)' ) ;
    obj.toolbar_buttons(4) = uitoggletool(tbh,'CData',toolbar_image(4),...
                'Separator','off',...
                'HandleVisibility','off', 'ClickedCallback', 'system_gen(2,3)' ) ;

    obj.toolbar_buttons(5) = uitoggletool(tbh,'CData',toolbar_image(5),...
                'Separator','on','TooltipString','Change pole',...
                'HandleVisibility','off', 'ClickedCallback', 'system_gen(3,1)' ) ;
    obj.toolbar_buttons(6) = uitoggletool(tbh,'CData',toolbar_image(6),...
                'Separator','off',...
                'HandleVisibility','off', 'ClickedCallback', 'system_gen(3,2)' ) ;
end
        
set(gcf,'UserData',obj) ;

function OnPoleZerosClick()
% handle event
obj = get(gcf,'UserData') ;
j = sqrt(-1) ;
cp = get(obj.axes_polezeros,'CurrentPoint') ;
x = round(cp(1,1)*2)/2 ;
y = round(cp(1,2)*2)/2 ;
switch obj.inputMode
    case 0
        if (obj.inputType==2) || isempty(obj.poles)
            obj.poles = [obj.poles,0] ;
        end
        obj.poles(end) = x ;
    case 1
        if (obj.inputType==2) || length(obj.poles)<2
            obj.poles = [obj.poles,0,0] ;
        end
        obj.poles(end-1:end) = [x+j*y, x-j*y] ;
    case 2
        if (obj.inputType==2) || isempty(obj.zeros)
            obj.zeros = [obj.zeros,0] ;
        end
        obj.zeros(end) = x ;
    case 3
        if (obj.inputType==2) || length(obj.zeros)<2
            obj.zeros = [obj.zeros,0,0] ;
        end
        obj.zeros(end-1:end) = [x+j*y, x-j*y] ;
end        
%obj.zeros
% prepare polynoms
A_s = poly(obj.zeros) ;
B_s = poly(obj.poles) ;
set(gcf,'UserData',obj) ;

% Visualize system
cla ;
plot_zeropoles_axes() ;
line(real(obj.poles),imag(obj.poles),'LineStyle','x','MarkerSize',10,'LineWidth',2,'HitTest','off') ;
line(real(obj.zeros),imag(obj.zeros),'LineStyle','o','MarkerSize',10,'LineWidth',2,'HitTest','off') ;
tfo = tf(A_s,B_s) ;
axes(obj.axes_sr), step(tfo) ;
axes(obj.axes_ir), impulse(tfo) ;
axes(obj.axes_fr) ;
f = 0:.1:30 ;
fr = freqs(A_s,B_s,f) ;
%plot(f,fr.*conj(fr),'Color',[0 0 1], 'LineWidth',1), grid on ;
%title('Frequency response') ;
rlocus(A_s,B_s) ;
% copy dif. equation to clipboard
str = [print_polynom(B_s,'x(t)'),'=',print_polynom(A_s,'f(t)')] ;
clipboard('copy', str ) ;


function plot_zeropoles_axes()
rectangle('Position',[0.02,-15,2,30],'FaceColor',[0.9 .5 .5],...
    'EraseMode','Xor','HitTest','off') ;
line([0 0],[-15 15],'LineStyle','-','Color',[0.1 0.1 0.1],'LineWidth',2,'HitTest','off') ;
line([-20 10],[0 0],'LineStyle','-','Color',[0.1 0.1 0.1],'LineWidth',2,'HitTest','off') ;

function OnToolBarButton_InputMode(newMode)
obj = get(gcf,'UserData') ;
obj.inputMode = newMode ;
set(obj.toolbar_buttons(1:4),'State','off') ;
set(obj.toolbar_buttons(newMode+1),'State','on') ;
set(gcf,'UserData',obj) ;

function OnToolBarButton_InputType(newType)
obj = get(gcf,'UserData') ;
set(obj.toolbar_buttons(5:6),'State','off') ;
set(obj.toolbar_buttons(4+newType),'State','on') ;
obj.inputType = newType ;
set(gcf,'UserData',obj) ;

function str_equation = print_polynom(A_s,strFunc)
str_equation = '' ;
for k=1:length(A_s)
    n = length(A_s)-k ;
    strKoef = '' ;
    if A_s(k)~=1
        strKoef = sprintf('%5.3f',A_s(k)) ;
    end
    strDiff = '' ;
    if n>1
        strDiff = sprintf('\\frac{d^%1d}{dt^%1d}',n,n) ;
    elseif n==1
        strDiff = sprintf('\\frac{d}{dt}') ;
    end
    if k==1
        str_equation = [strKoef,strDiff,strFunc] ;
    else
        str_equation = [str_equation,'+',strKoef,strDiff,strFunc] ;
    end
end

function img = get_o_img(n)
img = ones(n,n,3)*.85 ;
img(1,2:n-1,:) = 0 ;
img(n,2:n-1,:) = 0 ;
img(2:n-1,1,:) = 0 ;
img(2:n-1,n,:) = 0 ;

function img = get_x_img(n)
img = ones(n,n,3)*.85 ;
for k=1:n
    img(k,k,:) = 0 ;
    img(k,n-k+1,:) = 0 ;
end

function img = get_add_img(n)
img = ones(n,n,3)*.85 ;
img(4:end-4,round(n/2),:) = 0 ;
img(round(n/2),4:end-4,:) = 0 ;
img(4:end-4,round(n/2)-1,:) = 0 ;
img(round(n/2)-1,4:end-4,:) = 0 ;
img(4:end-4,round(n/2)+1,:) = 0 ;
img(round(n/2)+1,4:end-4,:) = 0 ;

function img = get_change_img(n)
img = ones(n,n,3)*.85 ;
img(round(n/2),4:end-4,:) = 0 ;

function img = toolbar_image(n)
img = ones(20,20,3)*0.85 ;
switch n
    case 1
        x = get_x_img(7) ;
        img(7:13,7:13,:) = x ;
    case 2
        x = get_x_img(7) ;
        img(3:9,7:13,:) = x ;
        img(11:17,7:13,:) = x ;
    case 3
        x = get_o_img(7) ;
        img(7:13,7:13,:) = x ;
    case 4
        x = get_o_img(7) ;
        img(3:9,7:13,:) = x ;
        img(11:17,7:13,:) = x ;
     case 5
         img = get_change_img(20) ;
     case 6
         img = get_add_img(20) ;
end
