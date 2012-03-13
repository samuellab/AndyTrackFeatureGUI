function [objPt, status] = BrightObjectTracker(loadfun,findFeaturesFun,minFrame,maxFrame)
% Load in a frame at a time and allows the user to navigate between frames.  
%
% Andrew Leifer
% leifer@fas.harvard.edu
% 13 March 2012

% Define State Variables
frame=minFrame; %Current frame
I=[]; %Current Image
status=''; %Are we out of range?
currPts=[]; %current Extracted features
dispFeat=true; %display features?
record=true; %record features
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
disp('exiting')
objPt='yo mamma';
status='yo';
    
    %% Display and Plot the current Image (& Draw Gui)
    function RefreshDisplayAndPlot
        gcf;  clf
               
        drawgui;
        
        %plot the image
        imagesc(I);
        
        %Plot Current Pts        
        if dispFeat
            plotCurrentPts(currPts,currFeat)
        end        

    end


    %% Load in a frame, Find Features, Display Image, Plot Points 
    function LoadExtractAndDisplayEverything(frame)

        %Set the desired frame
        set(gcf,'Name',['Frame: ' num2str(frame)]);

        [I,status]=loadfun(frame);
        currPts=findFeaturesFun(I);
        
        RefreshDisplayAndPlot;
     
                
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

    %% Decrement Frame
    function decrementFrame
        if frame-1>=minFrame
            frame=frame-1;
            disp('Backward')
        else
            disp('Out of range');
        end
    end

    %% Increment Frame
    function incrementFrame
        if frame+1<=maxFrame
            frame=frame+1;
            disp('Forward')
        else
            disp('Out of range');
        end
    end

    %% Record Feature for this Frame
    function recordFeature
       if record
            if currFeat ~=0 && currFeat >-2 %not manual & is valid
                featureType(frame)=currFeat;
                if currFeat~=0 %if not occluded
                    featureLoc(:,framed)=currPts(:,currFeat);
                else
                    featureLoc(:,frame)=[-1,-1];
                end
                
            else
                %Manual
                disp('This functionality not present yet...');
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
            incrementFrame;
            
        %Backward
        elseif strcmp(evnt.Key,'backspace') || strcmp(evnt.Key,'leftarrow')
            decrementFrame;
        
        elseif strcmp(evnt.Character,'h')
            dispFeat=~dispFeat;
            disp('Hide/Show Features');
        end
        
        
        
        disp(frame)
        
        %Load & Display Everything
        LoadExtractAndDisplayEverything(frame)        
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
        set(thisButton,'Value',1);
        
        %Turn off all the other mutually excluded feature buttons
        for k=1:length(mutEx)
            if thisButton~=mutEx(k)
                set(mutEx(k),'Value',0);
            end
        end
        
        
        %Set the current Feature
        currFeat=feature;
        
        ReleaseFocus(gcbf);
        RefreshDisplayAndPlot;
    end

    %% GUI
    function drawgui
        
        leftPosOfButtons=.72;
        
        set(gca,'Position',[0.01,0.01,0.7,1]);       
        gcf;
        
        %Done
        doneButton = uicontrol('Style','PushButton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .01 .27 .04],...
        'String','Done',...
        'CallBack',@closeTracker);
    
        %Occluded
        mutEx(1)=uicontrol('Style','togglebutton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .31 .27 .07],...
        'String','Occluded',...
        'Value',currFeat==-1,... 
        'CallBack',{@mutExButtonCallback,-1});
    
        %Brightest
        mutEx(2)=uicontrol('Style','togglebutton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .73 .27 .07],...
        'String','1st (Diamond)',...
        'Value',currFeat==1,... 
        'CallBack',{@mutExButtonCallback,1});
    
    
        %2nd Brightest
        mutEx(3)=uicontrol('Style','togglebutton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .65 .27 .07],...
        'String','2nd (Circle)',...
        'Value',currFeat==2,... 
        'CallBack',{@mutExButtonCallback,2});
    
        %3rd Brightest
        mutEx(4)=uicontrol('Style','togglebutton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .57 .27 .07],...
        'String','3rd (Square)',...
        'Value',currFeat==3,... 
        'CallBack',{@mutExButtonCallback,3});



        %Overwriting
        recordButton=uicontrol('Style','togglebutton',...
        'Units','Normalized',...
        'Position',[leftPosOfButtons .92 .27 .07],...
        'String','Record ON/OFF',...
        'Value',record,...
        'CallBack',@RecordCallback);
    
    end


    %% Plot Current Points
        function plotCurrentPts(currPts,currFeat)
        
            shapeList={'d','o','s','+','*','^','<','>'};
            defaultColor='w';
            defaultWidth=1;
            
            specialColor='r';
            specialWidth=2;
            

            %Plot the brightest points
            gcf;
            hold on; 
            
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
            

    end


end