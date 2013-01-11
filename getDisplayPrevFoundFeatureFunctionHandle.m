function h= getDisplayPrevFoundFeatureFunctionHandle(predictedLocation)
% This is complicated.
%
% The BrightObjectTracker.m framework was designed to be modular, so that
% you can plug in any findFeature function you want. Normally this would be
% to do some image processing on an image and display features for the user
% to choose from. 
%
% The goal now is to co-opt the BrightObjectTracker.m and use that as a way
% for the user to check to see if previously calculated features are
% actually correct. This is a way for the user to merely review the
% predicted locations of a neuron and to only occasionally manually correct
% it. 
%
% So instead of finding features based on the image, I want this function
% merely to look up the previously predicted location. 

h=@findFeatureCandidates;

    function currPts=findFeatureCandidates(~,~,frame)
            
            %Return the predicted location for this frame.
            currPts=predictedLocation(frame,:);
    end
end
