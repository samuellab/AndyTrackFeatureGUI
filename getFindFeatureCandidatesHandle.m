function h= getFindFeatureCandidatesHandle(numOfCandidates,radiusSmooth)
% Creates a findFeatureCandidates Function that accepts an image and
% returns a list of the current feature Candidate points.
h=@findFeatureCandidates;

    function currPts=findFeatureCandidates(I,radiusExclude)
                    %Find the n brightest regions    
            [x, y, blurred]=findNBrightest(I,radiusExclude,radiusSmooth,numOfCandidates);
            currPts=[x' y'];
    end
end
