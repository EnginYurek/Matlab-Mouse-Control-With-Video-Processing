greenThresh = 0.055;

imshow(rgbFrame)
figure

imshow(rgb2gray(rgbFrame))

figure
imshow(diffFrameGreen)


medfilt2(diffFrameGreen, [3 3])

figure
imshow(diffFrameGreen)

binFrameGreen = im2bw(diffFrameGreen, greenThresh); 

figure
imshow(binFrameGreen)


