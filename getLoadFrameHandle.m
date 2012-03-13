function h=getLoadFrameHandle(basefilename,extension,filenameDigits,imInfo,findNeuronsInRed,FirstImNum,LastImNum)
h=@loadFrame;

    function ret=loadFrame(num)
        %ret is zero (false) when things worked
        %ret is one (true) when out of range

        ret=false;
                
        if num<FirstImNum || num>LastImNum
            %Out of Range
            ret=true;
        else
            
            %Load in a frame
            I=imread(getFileName(num,basefilename,extension,filenameDigits));

            %Split into two and align and such
            [Ig Ir]=splitImageIntoChannels(I,imInfo);
                
                
            if findNeuronsInRed==1
                splitI=Ir;
            else
                splitI=Ig;
            end
            

            %Clear the image and plot the current one
            clf;imagesc(splitI)
            
            %Find the n brightest regions    
            [x, y, blurred]=findNBrightest(splitI,4,5);
            
            %Plot the brightest points
            hold on; plot(x,y,'ow')
            
            ret=false; %We are in range
        end
        
    end

end