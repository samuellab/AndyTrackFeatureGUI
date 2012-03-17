%Get INformation
basefilename='F:\DualMag\20120314\lim4_1_2\lim4_1_2t';
digits=4;
extension='.tif';
channelPrefix='c'
greenChIs1=true;

minRange=1;
maxRange=2000;

findNeuronsInRed=true;


loadFrame=getLoadFrameHandleForAlternatingIllum(basefilename,extension,...
    channelPrefix,digits,findNeuronsInRed,greenChIs1,minRange,maxRange);

findFeatures=getFindFeatureCandidatesHandle(5);

[point,~]=BrightObjectTracker(loadFrame,findFeatures,minRange,maxRange);


