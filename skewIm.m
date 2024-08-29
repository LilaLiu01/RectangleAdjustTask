function skImg = skewIm(Img,skew)

trans = [skew    skew-1;
         skew-1  skew];
     
tform = maketform("affine",[trans(1,1) trans(1,2) 0; trans(2,1) trans(2,2) 0; 0 0 1]);
skImg = imtransform(Img,tform);

end

