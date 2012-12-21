function [objPt, frameIndx] = BrightObjectTracker(loadfun,findFeaturesFun,minFrame,maxFrame)
% Load in a frame at a time and allows the user to navigate between frames.  
%
% This is the main code for tracking objects. It includes the code to
% create the GUI. 
%
% For programming and development see sample.m in the same folder. That
% provides a testbed to run this function.
%
% Andrew Leifer
% leifer@fas.harvard.edu
% 13 March 2012

% Define State Variables
frame=minFrame; %Current frame
I=[]; %Current Image
status=''; %Are we out of range?
currPts=[]; %current Extracted features
manPt=[]; %current manually entered pt.
dispFeat=true; %display features?
record=true; %record features
featRadius=15;
currFeat=1; %current Feature (brightest, 2nd brightest, occluded, manual, etc..)

    %A note about current features... the following table determines the
    %value of current feature:
    % -2: Not yet analyzed
    % -1: Occluded
    % 0: Manually Specificed Value
    % 1: Brightest Feature
    % 2: 2nd Brightest
    % 3: 3rd Brightest
    % 4: 4th Brighest
    % .
    % .
    % .

mutEx=[]; %array of mutually exclusive toggle button handles (one for occluded, one for brightest, etc..)
brightVsPosHandle=[]; %Array of handles to the two mutually exclusive 
                        %buttons for finding each frame based on the same 
                        %relative brightness as the previous frame or based
                        %on the closest position to the previous frame.
    BRIGHTNESS=1;
    POSITION=2;
    
featReccomendMode=BRIGHTNESS; %This is the feature location recommendation mode
                              %Brightness is the default mode.
statusTextHandle=[]; %Handle to text object

% Feature Data
frameIndx=minFrame:maxFrame; %index of frames
featureType=-2.*ones(size(frameIndx)); %type of feature for each frame
featureLoc=ones(length(frameIndx),2).*-1; %Location of the feature 
                                          %each row corresponds a frame in
                                          %IndxFrame and the first column
                                          %is x, the second column is y



% Initialize System
fig = figure('KeyPressFcn',@keyHandler,'CloseRequestFcn',@closeTracker);

LoadExtractAndDisplayEverything(frame);

%Draw the Gui
drawgui;

%Pause the UI and wait for the user to close
uiwait(fig);

% Exit

objPt=featureLoc; %Copy featureLoc to function output
status=1;
    
    %% Display and Plot the current Image (& Draw Gui)
    function RefreshDisplayAndPlot
        gcf;  clf
               
        drawgui;
        
        %plot the image
        imagesc(I);
        
    
        
        
        if currFeat == 0 %if we are in manual entry
           clear('manPt');
           manPt=ginput(1); %have the user select a point
           plotCurrentPts(manPt,currFeat); % display that point
        elseif dispFeat %Plot Current Pts  
            plotCurrentPts(currPts,currFeat)
        end        

    end


    %% Load in a frame, Find Features, Display Image, Plot Points 
    function LoadExtractAndDisplayEverything(frame)

        %Set the desired frame
        set(gcf,'Name',['Frame: ' num2str(frame)]);

        [I,status]=loadfun(frame); %Load in the frames
        currPts=findFeaturesFun(I,featRadius); %Find the first N candidate features
        
        %If we are in position mode, we should select the current feature 
        % by finding the one closes to the previous frame. 
        if featReccomendMode==POSITION
            currFeat=findFeatClosestToPrevFrame(currPts,frame,featureLoc);
        end
        
        RefreshDisplayAndPlot;     
    end

    function closestFeat=findFeatClosestToPrevFrame(currPts,frame,featureLoc);
        
        %If the last frame had an occluded point or is out of bounds,
        % keep the currently recommended feature brightness level 
        %(e.g. occluded, or diamond or whatever)
        
        closestFeat=currFeat; %Keep current recommendation

       %If  frame-1 exists 
       if  (frame-1>0) 
                     prevFrameLoc=featureLoc(frame-1,:); %Get Location from Prev Frame
            %If the frame isn't empty and isn't occluded
            if ~isempty(featureLoc(frame-1,:))&& ~all( prevFrameLoc<1)
                %find the feature whose location is nearest to the one from the previous frame.

                %Calculate cartesion distance between each currPt and the
                %previous frame location
                distForEachFeat=sqrt(sum((currPts-repMat(prevFrameLoc,size(currPts,1),1)).^2,2)); 
                
                %Find min
                [~,minDistFeat]=min(distForEachFeat); %Find the index of the minimum(s)
                closestFeat=minDistFeat(1); %overwrite the closest feawture
            end
        end

        
    end


    %% Figure Close Function
    function closeTracker(src,evnt)
        button = questdlg('Are you sure you are finished?','Finished?','Exit!','Return to data entry','Return to data entry');
       if strcmp(button,'Exit!')
        uiresume(gcbf);
           delete(gcf);
       end
       ReleaseFocus(gcbf);
       
    end

    %% CLick Increment / Decrement the Frame
    function clickIncrement(src,evnt)
        recordFeature;
        ReleaseFocus(gcbf);
           incrementFrame;
    end
    function clickDecrement(src,evnt)
        recordFeature;
    	ReleaseFocus(gcbf);
        decrementFrame;
    end

    %% Decrement Frame
    function decrementFrame
        if frame-1>=minFrame
            frame=frame-1;
            disp('Backward')
            
        %Load & Display Everything
        LoadExtractAndDisplayEverything(frame)     
            
        else
            disp('Out of range');
        end
    end

    %% Increment Frame
    function incrementFrame
        if frame+1<=maxFrame
            frame=frame+1;
            disp('Forward')
        
        %Load & Display Everything
        LoadExtractAndDisplayEverything(frame)       
        
        else
            disp('Out of range');
        end
    end

    %% Record Feature for this Frame
    function recordFeature
       if record
           featureType(frame)=currFeat;
            if currFeat ~=0 && currFeat >-2 %not manual & is valid
                if currFeat>0 %if not occluded
                    featureLoc(frame,:)=currPts(currFeat,:);
                else
                    featureLoc(frame,:)=[-1,-1];
                end
                
            else
                %Manual
                featureLoc(frame,:)=manPt;
            end
       end
       %Record is turned off so don't do anythning
        
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
        
        
        %Forward
        if strcmp(evnt.Key,'space') || strcmp(evnt.Key,'rightarrow')
            recordFeature;
            incrementFrame;
            
        %Backward
        elseif strcmp(evnt.Key,'backspace') || strcmp(evnt.Key,'leftarrow')
            recordFeature;
            decrementFrame;
        
        elseif strcmp(evnt.Character,'h')
            dispFeat=~dispFeat;
            RefreshDisplayAndPlot;
            disp('Hide/Show Features');
        end
         
        %Ignore the key stroke
 
    end


    %% Toggle Feature Record Callback
    function RecordCallback(src,evnt)
        record=logical(get(gcbo,'Value'));
        ReleaseFocus(gcbf);
    end

    %% mutEx Button Callbacks
    function mutExButtonCallback(src,evnt,feature)
        %When a mutually exclusive toggle button is clicked, record the
        %currently clicked button and then untoggle all the others.
        
        thisButton=gcbo;
        set(thisButton,'Value',1); %Depressed
        
        %Turn off all the other mutually excluded feature buttons
        for k=1:length(mutEx)
            if thisButton~=mutEx(k)
                set(mutEx(k),'Value',0); %Not Depressed
            end
        end
        
        
        %Set the current Feature
        currFeat=feature;
        
        ReleaseFocus(gcbf);
        RefreshDisplayAndPlot;
    end

    %% Toggle between find same brightness mode or find same position mode
    function flipBrightnessVsPosition(src,evnt)
        %This handles clicking in the brigthness mode or the position mode
        %button. The two are mutually exclusive. One instructs the software
        %to default to the point that has the same brigthness as the
        %previou frame's. The other defaults to choosing the point that is
        %closest to the previous frames.
        
        thisButton=gcbo;
        set(thisButton,'Value',1); %Depress the current button
        
        assert(thisButton==brightVsPosHandle(POSITION)|| thisButton==brightVsPosHandle(BRIGHTNESS));
        
        %Unpress the other button
        if thisButton==brightVsPosHandle(BRIGHTNESS)
            set(brightVsPosHandle(POSITION),'Value',0); 
            featReccomendMode=BRIGHTNESS; %Set mode to Brigthness
        else
            set(brightVsPosHandle(BRIGHTNESS),'Value',0);
            featReccomendMode=POSITION; %Set Mode to Position

        end
        
                ReleaseFocus(gcbf);
        RefreshDisplayAndPlot;
        
    end
    
    %% Get Status Text To Display
    function text=getStatusText

        if record
            
            if currFeat==-1
                text=['RECORDING Feature: Occluded']
            elseif currFeat==0
                text=['RECORDING Feature: ' num2str(currFeat) ...
                    ' Loc: (' num2str(manPt) ')'  ] ;
            elseif currFeat >0 
                text=['RECORDING Feature: ' num2str(currFeat) ...
                    ' Loc: (' num2str(currPts(currFeat,:)) ')'  ] ;
            else
                text=['This feature is not supported'];
            end

        else
            text=['Viewing Feature: ' num2str(featureType(frame)) ...
                ' Loc: (' num2str(featureLoc(frame,:)) ')'  ] ;

        end
        
    end

    %Set the Feature Radius
    function setFeatRadius(svc,evnt)
        featRadius=round(get(gcbo,'Value'));
        set(findobj('Tag','featRadiusText'),'String',num2str(featRadius));
        LoadExtractAndDisplayEverything(frame)  ;
        
    end

    %% GUI
    function drawgui
        
        leftPosOfButtons=.72;
        btnWidth=.27;
        
        set(gca,'Position',[0.01,0.01,0.7,1]);       
        gcf;
        

    
        %Overwriting
        recordButton=uicontrol('Style','togglebutton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .93 btnWidth .06],...
        'String','Record ON/OFF',...
        'Value',record,...
        'CallBack',@RecordCallback);
    
    %Status Text Handle
            statusTextHandle=uicontrol('Style','text',...
            'Units','Normalized',...
            'Position',[leftPosOfButtons .875 btnWidth .055],...
            'String',getStatusText);    
        
        
        
           %Use Same Brightness vs Same Position
        brightVsPosHandle(1)=uicontrol('Style','PushButton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons  .79 .13 .08],...
        'String','Brightness',...
        'Value',featReccomendMode==BRIGHTNESS,...
        'CallBack',@flipBrightnessVsPosition);
         
        brightVsPosHandle(2)=uicontrol('Style','PushButton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons+.135 .79 .13 .08],...
        'String','Position',...
        'Value',featReccomendMode==POSITION,...
        'CallBack',@flipBrightnessVsPosition);
    

    
        %Brightest
        mutEx(2)=uicontrol('Style','togglebutton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .71 btnWidth .07],...
        'String','1st (Diamond)',...
        'Value',currFeat==1,... 
        'CallBack',{@mutExButtonCallback,1});
    
    
        %2nd Brightest
        mutEx(3)=uicontrol('Style','togglebutton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .63 btnWidth .07],...
        'String','2nd (Circle)',...
        'Value',currFeat==2,... 
        'CallBack',{@mutExButtonCallback,2});
    
        %3rd Brightest
        mutEx(4)=uicontrol('Style','togglebutton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .55 btnWidth .07],...
        'String','3rd (Square)',...
        'Value',currFeat==3,... 
        'CallBack',{@mutExButtonCallback,3});

        %4th Brightest
        mutEx(5)=uicontrol('Style','togglebutton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .47 btnWidth .07],...
        'String','4th (+)',...
        'Value',currFeat==4,... 
        'CallBack',{@mutExButtonCallback,4});   
    
         %5th Brightest
         mutEx(6)=uicontrol('Style','togglebutton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .39 btnWidth .07],...
        'String','5th (*)',...
        'Value',currFeat==5,... 
        'CallBack',{@mutExButtonCallback,5});    

    
    
    
    
    
        %STatus Text

        
        %Left and Right Buttons
        
         uicontrol('Style','PushButton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .27 .13 .1],...
        'String','<-',...
        'CallBack',@clickDecrement);
         
        uicontrol('Style','PushButton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons+.135 .27 .13 .1],...
        'String','->',...
        'CallBack',@clickIncrement);
    
    
            %Occluded
        mutEx(1)=uicontrol('Style','togglebutton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .19 btnWidth .07],...
        'String','Occluded',...
        'Value',currFeat==-1,... 
        'CallBack',{@mutExButtonCallback,-1});
    
           
        %Manual
        mutEx(7)=uicontrol('Style','togglebutton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .11 btnWidth .07],...
        'String','Manual Entry',...
        'Value',currFeat==0,... 
        'CallBack',{@mutExButtonCallback,0});    
    
    
        %Feature Size Control
        uicontrol('Style','slider',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .06 .23 .03],...
        'String','FeatureSize',...
        'Min',1, 'Max',50,...
        'Value',featRadius,... 
        'SliderStep',[.1 1/50],...
        'CallBack',@setFeatRadius);    
        
        %Feature Size Control Text!
        uicontrol('Style','text',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons+.22, .06,  .06, .03],...
        'String',num2Str(featRadius),...
        'Tag','featRadiusText');    
    
            %Done
        doneButton = uicontrol('Style','PushButton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .01 btnWidth .04],...
        'String','Done',...
        'CallBack',@closeTracker);
        
    
    
    
    
    end


    %% Plot Current Points
        function plotCurrentPts(currPts,currFeat)
        
            shapeList={'d','o','s','+','*','^','<','>'};
            defaultColor='w';
            defaultWidth=1;
            
            specialColor='r';
            specialWidth=2;
            

            gcf;
            hold on; 
            
            
            if currFeat ~=0 %If we aren't doing manual data entry
                
                %Plot the brightest points
                for k=1:size(currPts,1)
                    if k==currFeat
                        %use special values
                        c=specialColor;
                        w=specialWidth;
                    else
                        %use default values
                        c=defaultColor;
                        w=defaultWidth;

                    end

                    plot(currPts(k,1), currPts(k,2),shapeList{k},...
                        'MarkerEdgeColor',c,'MarkerSize',8,'LineWidth',w)                

                end
            else
                
                plot(currPts(1), currPts(2),'o',...
                        'MarkerEdgeColor',specialColor,'MarkerSize',8,'LineWidth',specialWidth)
            end
            
            

    end


end