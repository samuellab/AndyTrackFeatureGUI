%This script is a sandbox for testing the TrackFeatureGUI


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

    
    %Load only the red channels
    loadFrameRed=getLoadFrameHandleForAlternatingIllum(basefilename,...
        extension,channelPrefix,digits,...
        ~greenChIs1,greenChIs1,minRange,...
        maxRange);
    
    %Load on the green channels
    loadFrameGreen=getLoadFrameHandleForAlternatingIllum(basefilename,...
        extension,channelPrefix,digits,...
        greenChIs1,greenChIs1,minRange,...
        maxRange);
    
findFeatures=getFindFeatureCandidatesHandle(5,radiusSmooth);

[pointGreen,~]=BrightObjectTracker(loadFrameGreen,findFeatures,minRange,maxRange);


[pointRed,~]=BrightObjectTracker(loadFrameRed,findFeatures,minRange,maxRange,pointGreen);

