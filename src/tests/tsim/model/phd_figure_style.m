function phd_figure_style(figHandle)
% set exportable image size
%figHandle = gcf ;
xSize = 640 ;
ySize = 480 ;
position = get(figHandle,'Position') ;
set(gcf,'Position', ...
    [position(1)+position(3)-xSize, position(2)+position(4)-ySize, ...
    xSize, ySize]) ;
figAxes = get(figHandle,'CurrentAxes') ;
set(figAxes(1),'LineWidth',2) ;
set(figAxes(1),'XGrid','on') ;
set(figAxes(1),'YGrid','on') ;
set(figAxes(1),'FontSize',18) ;

colorTbl = [0 0 0 ;.75 0.33 0.33 ; .33 0.33 0.75 ; .4 0.7 0.55 ; ...
            .7 0.7 0.2; .7 0.5 0.2] ;

figLines = findobj(figAxes(1),'Type','line') ;
for n=1:length(figLines)
    handl = figLines(n) ;
    set(handl,'Color',colorTbl(n,:)) ;
    set(handl,'LineWidth',2) ;
end

obj_list = findall(gca) ;
for n=1:length(obj_list)
    type = get(obj_list(n),'Type') ;
    if strcmpi(type,'text')
        set(obj_list(n),'FontSize',18) ;
    end
end

