function bgImg = readBG(bgNum,d)
   bgImg = imread(['konklebgs/',d(bgNum).name]);
    bgImg = double(rgb2gray(bgImg));
    %Normalize background so its mean is 128- so everything is same average
    %brightness
    mn = mean(mean(bgImg));
    cImg = (bgImg-mn)./mn;
    cImg(cImg>1) = 1; cImg(cImg<-1) = -1;
    bgImg = uint8(round(cImg*128+127));
