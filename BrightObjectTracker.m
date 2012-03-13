function [objPt, status] = BrightObjectTracker(loadfun,findFeaturesFun)
% Press and release various key combinations in the figure.
% Values returned by the event structure are displayed
% in the command window.
%
% At each keypress it runs loadfun, which is a function that loads in the
% current frame. It must accept an integer for the frame number. The other
% parameters are set in a function "getLoadFrameHandle".
% 
%
%

%% Define Variables
frame=1; %Current frame
I=[]; %Current Image
status=''; %Are we out of range?
currPts=[]; %current Extracted features
dispFeat=true; %display features?


%% Initialize System
fig = figure('KeyPressFcn',@keyHandler,'CloseRequestFcn',@closeTracker);

LoadExtractAndDisplayEverything(frame);

%Pause the UI and wait for the user to close
uiwait(fig);


disp('exiting')
objPt='yo mamma';
status='yo';



   
    
    %% Load in a frame, Find Features, Display Image, Plot Points 
    function LoadExtractAndDisplayEverything(frame)

        %Set the desired frame
        set(gcf,'Name',['Frame: ' num2str(frame)]);

        [I,status]=loadfun(frame);
        currPts=findFeaturesFun(I);
        imagesc(I);
        %Plot Current Pts
        plotCurrentPts(currPts)
        
        %Draw the Gui
        drawgui;
        
                
    end


    %% Figure Close Function
    function closeTracker(src,evnt)
        button = questdlg('Are you sure you are finished?','Finished?','Exit!','Return to data entry','Return to data entry');
       if strcmp(button,'Exit!')
        uiresume(gcbf);
           delete(gcf);
       end
       
    end

    %% KeyHandler
    function keyHandler(src,evnt)
        
        if ~isempty(evnt.Modifier)
            for ii = 1:length(evnt.Modifier)
                out = sprintf('Character: %c\nModifier: %s\nKey: %s\n',evnt.Character,evnt.Modifier{ii},evnt.Key);
                disp(out)
            end
        else
            out = sprintf('Character: %c\nModifier: %s\nKey: %s\n',evnt.Character,'No modifier key',evnt.Key);
            disp(out)
        end
        
        
        
        if strcmp(evnt.Key,'space') || strcmp(evnt.Key,'rightarrow')
            disp('Forward')
            frame=frame+1;
        elseif strcmp(evnt.Key,'backspace') || strcmp(evnt.Key,'leftarrow')
            frame=frame-1;
            disp('Backward')
        end
        
        disp(frame)
        
        %Load & Display Everything
        LoadExtractAndDisplayEverything(frame)
        
    end


    %% GUI
    function drawgui
        
        leftPosOfButtons=.72;
        
        set(gca,'Position',[0.01,0.01,0.7,1]);       
        gcf;
        
        %Done
        p = uicontrol('Style','PushButton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .01 .27 .08],...
        'String','Done',...
        'CallBack',@closeTracker);
    
        %Occluded
        uicontrol('Style','PushButton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .31 .27 .08],...
        'String','Occluded',...
        'CallBack','disp(''Clicked Occluded'')');
    
        %Brightest
        uicontrol('Style','PushButton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .81 .27 .08],...
        'String','Brightest',...
        'CallBack','disp(''Clicked Brightest'')');

    end


    %% Plot Current Points
        function plotCurrentPts(currPts)
        
            %Plot the brightest points
            gcf;
            hold on; 
            plot(currPts(1,1), currPts(1,2),'dr','MarkerSize',8,'LineWidth',2 )
            
            if size(currPts,1)>1
                plot(currPts(2,1), currPts(2,2),'ow','MarkerSize',8,'LineWidth',1.5 )
            end
            
            
            if size(currPts,1)>2
                plot(currPts(3,1), currPts(3,2),'sw','MarkerSize',8,'LineWidth',1)
            end
            
            
            if size(currPts,1)>3
                plot(currPts(4,1), currPts(4,2),'+w','MarkerSize',8,'LineWidth',1)
            end
            
            if size(currPts,1)>4
                plot(currPts(5,1), currPts(5,2),'*w','MarkerSize',8,'LineWidth',1)
            end

    end


end