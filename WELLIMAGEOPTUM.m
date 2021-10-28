function USERIMAGE = WELLIMAGEOPTUM(OGIMAGE,WELLIMAGES,OPTUM_TYPE)
%WELLIMAGEOPTUM receives a 16 bit microscope image (OGIMAGE) created by 
%imread of a file and the WELLIMAGES object (this function is exclusively
%called WITHIN a WELLIMAGES class method)
%creates a USERIMAGE based on OPTUM_TYPE
%OPTUM_TYPE = 1: 8 bit contrast-enhanced greyscale
%OPTUM_TYPE = 2: 8 bit contrast-enhanced color (see
%             redscale,greenscale,bluescale varaibles below) with delta enhancement
%             (difference between beginning and end of stimulus window)

%Set pixel value scale for improved visibility
%get range of values
minpixelvalue=min(min(OGIMAGE));
maxpixelvalue=max(max(OGIMAGE));
%Scale factor to go from 16 bit to 8 bit values
SCALEFACTOR=round((maxpixelvalue-minpixelvalue)/256);

%Get frame dimensions
[VHEIGHT,VWIDTH]=size(OGIMAGE);

%%%%Create blank array(s) for creating scaled-value image(s)
%Greyscale Array Blank
if OPTUM_TYPE==1
    %create array with 1 color channel (greyscale)
    THRESHOLD_IMG=zeros(VHEIGHT,VWIDTH,1,'uint8');
end

%PsuedoColor Array blank
if OPTUM_TYPE==2
    %mess with color channel proportions HERE
    redscale=0.9;
    greenscale=0.6;
    bluescale=0.1;
    %create array with 3 color channels
    THRESHOLD_IMG=zeros(VHEIGHT,VWIDTH,3,'uint8');
end

%DELTA_IMG Array Blank and Subtraction
if OPTUM_TYPE==2
    %make DELTA_IMG - subtraction of raw pixel values from the end to
    %the start of the stimulus
    %getSTIMSTART frame
    FRAME1STIMSTART = imread(WELLIMAGES.present_video,'Index',WELLIMAGES.STIMSTART,'Info',WELLIMAGES.present_info);
    %getSTIMEND frame
    FRAME2STIMEND = imread(WELLIMAGES.present_video,'Index',WELLIMAGES.STIMEND,'Info',WELLIMAGES.present_info);
    %RAW 16bit PIXELS
    DELTA_IMG = FRAME2STIMEND-FRAME1STIMSTART;
    %CONVERT TO 8BIT
    DELTA_IMG=im2uint8(DELTA_IMG);
    COLORDELTA=zeros(VHEIGHT,VWIDTH,3,'uint8');
    %Find threshold values for deltamap
    minDvalue=min(min(DELTA_IMG));
    maxDvalue=max(max(DELTA_IMG));
end
%%%End of Array Set up

%Loop through all pixels in OGIMAGE to scale values
for X=1:1:VWIDTH
    for Y=1:1:VHEIGHT
        %Get OGIMAGE pixel value at X,Y
        IMGPIXEL=OGIMAGE(Y,X);
        
        %Basic GreyScale
        if OPTUM_TYPE==1
            THRESHOLD_IMG(Y,X,1)=uint8(round(IMGPIXEL/SCALEFACTOR));
        end
        
        %PsuedoColor with Delta
        if OPTUM_TYPE==2
            if IMGPIXEL<=minpixelvalue
                THRESHOLD_IMG(Y,X,1)=0;
            end
            if IMGPIXEL>minpixelvalue&&IMGPIXEL<=maxpixelvalue
                THRESHOLD_IMG(Y,X,1)=uint8(round((IMGPIXEL/SCALEFACTOR)*redscale));
                THRESHOLD_IMG(Y,X,2)=uint8(round((IMGPIXEL/SCALEFACTOR)*greenscale));
                THRESHOLD_IMG(Y,X,3)=uint8(round((IMGPIXEL/SCALEFACTOR)*bluescale));
            end
            %create a WHITE Deltamap to overlay
            DELTAPIXEL=DELTA_IMG(Y,X);
            if DELTAPIXEL<=minDvalue
                COLORDELTA(Y,X,1)=0;
                COLORDELTA(Y,X,2)=0;
                COLORDELTA(Y,X,3)=0;
            end
            if DELTAPIXEL>minDvalue&&DELTAPIXEL<=maxDvalue
                COLORDELTA(Y,X,1)=256;
                COLORDELTA(Y,X,2)=256;
                COLORDELTA(Y,X,3)=256;
            end
        end
        %end of OPTUM_TYPE processes  
    end
end
%end of image pixel loop

%RETURN USERIMAGE based on OPTUM_TYPE
if OPTUM_TYPE==1
    USERIMAGE = THRESHOLD_IMG;
end

if OPTUM_TYPE==2
    USERIMAGE=THRESHOLD_IMG+COLORDELTA;
end
%END OF FUNCTION
end

