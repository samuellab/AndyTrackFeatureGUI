function h= getFindFeatureCandidatesHandle(numOfCandidates)
% Creates a findFeatureCandidates Function that accepts an image and
% returns a list of the current feature Candidate points.
h=@findFeatureCandidates;

    function currPts=findFeatureCandidates(I,FeatureRadius)
                    %Find the n brightest regions    
            [x, y, blurred]=findNBrightest(I,FeatureRadius,numOfCandidates);
            currPts=[x' y'];
    end
end
