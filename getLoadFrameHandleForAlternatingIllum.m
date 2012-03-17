function h=getLoadFrameHandleForAlternatingIllum(basefilename,extension,channelPrefix,filenameDigits,findNeuronsInRed,greenChIs1,FirstImNum,LastImNum)
%Returns a function handle to a function that loads in a frame. This is
%currently qritten for dual-view images. Simply write your own loadFrame
%function here and you should be good to go. 
h=@loadFrame;


    function [I, ret]=loadFrame(num)
        %ret is zero (false) when things worked
        %ret is one (true) when out of range
        currPts='';

        ret=false;
                
        if num<FirstImNum || num>LastImNum
            %Out of Range
            ret=true;
        else
            
            if greenChIs1
                green=1;
                red=2;
            else
                green=2;
                red=1;
            end
            
            if findNeuronsInRed
                channel=red;
            else
                channel=green;
            end

            
            %Load in a frame
            I=imread(getFileName(num,basefilename,[ channelPrefix num2str(channel) extension],filenameDigits));

            ret=false; %We are in range
        end
        
    end

    


end