function [eye1 eye2] = eyeMap(Im, facemask)

image = im2uint8(Im);
%[mouthmap mouthCord] = mouthMap(Im);



ycbcrmap = rgb2ycbcr(image);

Y = ycbcrmap(:,:,1);
Cb = ycbcrmap(:,:,2);
Cr = ycbcrmap(:,:,3);


%normCb = double(Cb)./max(max(double(Cb)));
%normCbPow = power(normCb,2);
%CbPow = normCbPow.*255;
dCb = double(Cb);
CbPow = power(dCb,2);

normCbPow = CbPow./max(max(CbPow));
CbPow = normCbPow.*255;


CrNeg = 255 - Cr;
%normCrNeg = double(CrNeg)./max(max(double(CrNeg)));
%CrNegPow = power(normCrNeg,2);
%CrNegPow = CrNegPow .*255;
dCrNeg = double(CrNeg);
CrNegPow = power(dCrNeg,2);

normCrNegPow = CrNegPow./max(max(CrNegPow));
CrNegPow = normCrNegPow.*255;

CbDivCr = double(Cb)./double(Cr);

normCbDCr = CbDivCr./max(max(CbDivCr));
CbDCrFinal = normCbDCr.*255;

eyeMapC = (1/3).*CbPow + (1/3).*CrNegPow + (1/3).*CbDCrFinal;

eyeMapC = histeq(uint8(eyeMapC));

SE = strel('sphere',20);

erosion = imerode(Y,SE);
erosion = erosion + 1;
dilation = imdilate(Y,SE);

eyeMapL = double(dilation)./double(erosion);

eyeMapLN = eyeMapL./max(max(eyeMapL));

eyeMapLFinal = uint8(eyeMapLN.*255);

eyeMapFinal = imfuse(eyeMapLFinal, eyeMapC, 'blend');

SE2 = strel('sphere',15);
eyeMapFinal = imdilate(eyeMapFinal, SE2);

eyeMapFinal = 255.*double(eyeMapFinal)./max(max(double(eyeMapFinal)));

[rows, cols] = size(eyeMapFinal);


for row = 1:rows
    for col = 1:cols
        if(eyeMapFinal(row,col) > 220)
            eyeMapFinal(row,col) = 255;
        else
            eyeMapFinal(row,col) = 0;
        end
    end
end

BW = logical(eyeMapFinal);
eyemap = immultiply(BW,logical(facemask));



mm = bwareafilt(eyemap,2);% Selecting 2 largest object of image

labeledImage = bwlabel(mm);
 measurements = regionprops(labeledImage, mm, 'Centroid');
 [a b] = size(measurements);
 if(a > 1)
 centroid1 = measurements(1).Centroid;
 centroid2 = measurements(2).Centroid;
 
 centroid1 = round(centroid1);
 centroid2 = round(centroid2);
 
% 
 mm(centroid1(2),centroid1(1),:) = 0;
 mm(centroid2(2),centroid2(1),:) = 0;
 
 eye1 = centroid1;
 eye2 = centroid2;
 
 else
     eye1 = [0, 0];
     eye2 = [0, 0];
 
 end


end