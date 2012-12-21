%This script is a sandbox for testing the TrackFeatureGUI

%Get INformation
basefilename='G:\DualMag\20111027\102711lgc55gc3_1_1_20111102_55046 PM\102711lgc55gc3_1_1_t';
digits=4;
extension='.tif';

minRange=1;
maxRange=2000;

findNeuronsInRed=true;
radiusSmooth=4;

%Load in the image info
load([basefilename '_analysis.mat']);
imInfo=output.imInfo;

loadFrame=getLoadFrameHandle(basefilename,extension,digits,imInfo,findNeuronsInRed,minRange,maxRange);

findFeatures=getFindFeatureCandidatesHandle(5,radiusSmooth);

[point,~]=BrightObjectTracker(loadFrame,findFeatures,minRange,maxRange);


