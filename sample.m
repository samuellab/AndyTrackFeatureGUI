%Get INformation
basefilename='F:\DualMag\20120126\cex1_3_3\cex1_3_3t';
digits=4;
extension='.tif';
featureRadius=4;

minRange=1;
maxRange=2000;

findNeuronsInRed=true;

%Load in the image info
load([basefilename '_analysis.mat']);
imInfo=output.imInfo;

loadFrame=getLoadFrameHandle(basefilename,extension,digits,imInfo,findNeuronsInRed,minRange,maxRange);

findFeatures=getFindFeatureCandidatesHandle(5,featureRadius);

BrightObjectTracker(loadFrame,findFeatures)


