redThresh = 0.05;

imshow(rgbFrame)
figure

imshow(rgb2gray(rgbFrame))

figure
imshow(diffFrameRed)


medfilt2(diffFrameRed, [3 3])

figure
imshow(diffFrameRed)

binFrameRed = im2bw(diffFrameRed, redThresh); 

figure
imshow(binFrameRed)


