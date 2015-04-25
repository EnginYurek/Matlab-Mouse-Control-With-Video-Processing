
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
mouse =Robot;
screenSize = get( groot, 'Screensize' );
greenThresh=0.017;
blueThresh=0.07;
redThresh=0.05;
vidDevice = imaq.VideoDevice('winvideo', 1, 'YUY2_640x480', ... % Acquire input video stream
                    'ROI', [1 1 640 480], ...
                    'ReturnedColorSpace', 'rgb');
vidInfo = imaqhwinfo(vidDevice);
hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
                                'CentroidOutputPort', true, ... 
                                'BoundingBoxOutputPort', true', ...
                                'MinimumBlobArea', 600, ...
                                'MaximumBlobArea', 3000, ...
                                'MaximumCount', 10);
 hshapeinsBox = vision.ShapeInserter('BorderColorSource', 'Input port', ... % Set box handling
                                        'Fill', true, ...
                                        'FillColorSource', 'Input port', ...
                                        'Opacity', 0.2);
                                    
 htextinsRed = vision.TextInserter('Text', 'Red   : %2d', ... % Set text for number of blobs
                                    'Location',  [5 2], ...
                                    'Color', [1 0 0], ... // red color
                                    'Font', 'Courier New', ...
                                    'FontSize', 14);
                                
htextinsGreen = vision.TextInserter('Text', 'Green : %2d', ... % Set text for number of blobs
                                    'Location',  [5 18], ...
                                    'Color', [0 1 0], ... // green color
                                    'Font', 'Courier New', ...
                                    'FontSize', 14);
   
htextinsBlue = vision.TextInserter('Text', 'Blue  : %2d', ... % Set text for number of blobs
                                    'Location',  [5 34], ...
                                    'Color', [0 0 1], ... // blue color
                                    'Font', 'Courier New', ...
                                    'FontSize', 14);

  htextinsCent = vision.TextInserter('Text', '+      X:%4d, Y:%4d', ... % set text for centroid
                                    'LocationSource', 'Input port', ...
                                    'Color', [1 1 0], ... // yellow color
                                    'Font', 'Courier New', ...
                                    'FontSize', 14);
  hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
                                'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
nFrame = 0;

while(nFrame < 2)
    
    rgbFrame = step(vidDevice);
     rgbFrame = flipdim(rgbFrame,2);
     frameSize=size(rgbFrame);
   
     redDensityOG=0;
     redDensityOB=0;
     greenDensitOR=0;
     greenDensityOB=0;
     blueDensityOR=0;
     blueDensityOG=0;
     
     
     for i=5:1:frameSize(1)
         for j=5:1:frameSize(2)
            
            redSum=0;
            greenSum=0;
            blueSum=0;
            
            for c=1:1:3
                for a=i-2:1:i+2
                    for b=j-2:1:j+2
                    
             if c==1
                redSum=redsum+rgbFrame(a,b,c);
             end
             if c==2 
                 greenSum=greenSum+rgb(a,b,c);
             end
             if c==3
                blueSum=blueSum+rgb(a,b,c);
             end
             
                    end
                end
            end
            
            if redSum /greenSum > redDensityOG && redSum/blueSum > redDensityOB
                
                redDensityOG=redSum/greenSum;
                redDensityOB=redSum/blueSum;
                
                mostRedPixel(1)=i;
                mostRedPixrl(2)=j;
                
            end
            
            if greenSum /redSum > greenDensityOR && greenSum/blueSum > greenDensityOB
                
                greenDensityOR=greenSum/redSum;
                greenDensityOB=greenSum/blueSum;
                
                mostGreenPixel(1)=i;
                mostGreenPixrl(2)=j;
                
            end
            
            if blueSum /redSum > blueDensityOR && blueSum/greenSum > greenDensityOG
                
                blueDensityOR=blueSum/redSum;
                blueDensityOG=blueSum/greenSum;
                
                mostBluePixel(1)=i;
                mostBluePixel(2)=j;
            end
            
            
         end
     end
     
    diffFrameGreen = imsubtract(rgbFrame(:,:,2), rgb2gray(rgbFrame));
    diffFrameGreen = medfilt2(diffFrameGreen, [3 3]);
   binFrameGreen = im2bw(diffFrameGreen, greenThresh); % Convert the image into binary image with the green objects as white
   
    diffFrameBlue = imsubtract(rgbFrame(:,:,3), rgb2gray(rgbFrame)); % Get blue component of the image
    diffFrameBlue = medfilt2(diffFrameBlue, [3 3]); % Filter out the noise by using median filter
    binFrameBlue = im2bw(diffFrameBlue, blueThresh); % Convert the image into binary image with the blue objects as white
    
     diffFrameRed = imsubtract(rgbFrame(:,:,1), rgb2gray(rgbFrame)); % Get red component of the image
    diffFrameRed = medfilt2(diffFrameRed, [3 3]); % Filter out the noise by using median filter
    binFrameRed = im2bw(diffFrameRed, redThresh); % Convert the image into binary image with the red objects as white
    
    
    hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
                                'CentroidOutputPort', true, ... 
                                'BoundingBoxOutputPort', true', ...
                                'MinimumBlobArea', 600, ...
                                'MaximumBlobArea', 3000, ...
                                'MaximumCount', 10);
[centroidGreen, bboxGreen] = step(hblob, binFrameGreen); % Get the centroids and bounding boxes of the green blobs
    centroidGreen = uint16(centroidGreen); % Convert the centroids into Integer for further steps 
   
     [centroidBlue, bboxBlue] = step(hblob, binFrameBlue); % Get the centroids and bounding boxes of the blue blobs
    centroidBlue = uint16(centroidBlue); % Convert the centroids into Integer for further steps 
    
     [centroidRed, bboxRed] = step(hblob, binFrameRed); % Get the centroids and bounding boxes of the red blobs
    centroidRed = uint16(centroidRed); % Convert the centroids into Integer for further steps 
    
    rgbFrame(1:50,1:90,:) = 0;
    vidIn = step(hshapeinsBox,  rgbFrame, bboxGreen, single([0 1 0])); % Instert the green box
   vidIn = step(hshapeinsBox, vidIn, bboxBlue, single([0 0 1])); % Instert the blue box
   vidIn = step(hshapeinsBox, rgbFrame, bboxRed, single([1 0 0])); % Instert the red box
    for object = 1:1:length(bboxRed(:,1)) % Write the corresponding centroids for red
        centXRed = centroidRed(object,1); centYRed = centroidRed(object,2);
        vidIn = step(htextinsCent, vidIn, [centXRed centYRed], [centXRed-6 centYRed-9]); 
    end
    for object = 1:1:length(bboxGreen(:,1)) % Write the corresponding centroids for green
        centXGreen = centroidGreen(object,1); centYGreen = centroidGreen(object,2);
        vidIn = step(htextinsCent, vidIn, [centXGreen centYGreen], [centXGreen-6 centYGreen-9]); 
    end
   
    for object = 1:1:length(bboxBlue(:,1)) % Write the corresponding centroids for blue
        centXBlue = centroidBlue(object,1); centYBlue = centroidBlue(object,2);
        vidIn = step(htextinsCent, vidIn, [centXBlue centYBlue], [centXBlue-6 centYBlue-9]); 
    end
    
     vidIn = step(htextinsGreen, vidIn, uint8(length(bboxGreen(:,1)))); % Count the number of green blobs
     vidIn = step(htextinsBlue, vidIn, uint8(length(bboxBlue(:,1)))); % Count the number of blue blobs
    vidIn = step(htextinsRed, vidIn, uint8(length(bboxRed(:,1)))); % Count the number of red blobs
    
     
     step(hVideoIn, vidIn); % Output video stream
    % mouse.mouseMove(centXGreen*(1366/480),centYGreen*(768/640));
     %mouse.delay(20);
     
    nFrame=nFrame+1;
    %% týklama yapacagýn degerleri loopun son satýrýnda sýfýrla ki ekrendan cýktýgýnda
    %% hala o degerleri görüp týklamaya çalýþmasýn. sonra bi if ile degerleri 
    %% karþýlastýr sýfýr degilse týklat,
    %% herhangi iki degeri karþýlastýr ve and le (yani iki degerde sayý içeriyorsa týklama yap gibi)
end
closepreview
release(hVideoIn); % Release all memory and buffer used
release(vidDevice);