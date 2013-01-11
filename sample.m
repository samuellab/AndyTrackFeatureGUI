%This script is a sandbox for testing the TrackFeatureGUI

REVIEW_GREEN_CH=true;

%Get INformation
basefilename='G:\DualMag\20120220\lgc55_1_4\lgc55gc3_1_4t';
digits=4;
extension='.tif';

minRange=710;
maxRange=720;

findNeuronsInRed=true;
radiusSmooth=4;

%Load in the image info
load([basefilename '_analysis.mat']);

greenChIs1=true;
channelPrefix='c'
findNeuronsInRed=true;
    
    %Load only the red channels
    loadFrameRed=getLoadFrameHandleForAlternatingIllum(basefilename,...
        extension,channelPrefix,digits,...
        findNeuronsInRed,greenChIs1,minRange,...
        maxRange);
    
%Load only the green channels
        loadFrameGreen=getLoadFrameHandleForAlternatingIllum(basefilename,...
        extension,channelPrefix,digits,...
        not(findNeuronsInRed),greenChIs1,minRange,...
        maxRange);
    

    
findFeatures=getFindFeatureCandidatesHandle(5,radiusSmooth);




[pointRed,~]=BrightObjectTracker(loadFrameRed,findFeatures,minRange,maxRange);


    if REVIEW_GREEN_CH
        %Interpolate in time the locaiton of the red channel to predict
        %locations of the neuron in the green channel
        predictedGreen=interpolateCh(pointRed,greenChIs1,not(findNeuronsInRed));
        
        %Create a new function handle to be passed to the
        %BrightObjectTracker that finds objects in the frame, not by
        %brightness as before, but by merely reading the location of the
        %previously predicted neuron's location
                findFeatures=getDisplayPrevFoundFeatureFunctionHandle(predictedGreen);


    end


[pointGreen,~]=BrightObjectTracker(loadFrameGreen,findFeatures,minRange,maxRange,pointRed);



