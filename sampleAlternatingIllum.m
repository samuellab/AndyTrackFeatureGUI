%Get INformation
basefilename='F:\DualMag\20120220\lgc55_2_4\lgc55gc3_2_4t';
digits=4;
extension='.tif';
channelPrefix='c'
greenChIs1=true;

radius=4;
minRange=670;
maxRange=700;

findNeuronsInRed=true;


loadFrame=getLoadFrameHandleForAlternatingIllum(basefilename,extension,...
    channelPrefix,digits,findNeuronsInRed,greenChIs1,minRange,maxRange);

findFeatures=getFindFeatureCandidatesHandle(5,radius);

[point,~]=BrightObjectTracker(loadFrame,findFeatures,minRange,maxRange);


