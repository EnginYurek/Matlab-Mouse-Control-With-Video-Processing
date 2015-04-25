blueThresh = 0.07;

imshow(rgbFrame)
figure

imshow(rgb2gray(rgbFrame))

figure
imshow(diffFrameBlue)


medfilt2(diffFrameBlue, [3 3])

figure
imshow(diffFrameBlue)

binFrameBlue = im2bw(diffFrameBlue, blueThresh); 

figure
imshow(binFrameBlue)


