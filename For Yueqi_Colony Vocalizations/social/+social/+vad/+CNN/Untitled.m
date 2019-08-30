for i = 3 : 3
    im = zeros(224,224,3);
    
    im(:,:,1) = imresize(social.vad.CNN.minmax(boxes(i).par, 0, 255), [224,224]);
    im(:,:,2) = imresize(social.vad.CNN.minmax(boxes(i).ref, 0, 255), [224,224]);
    im(:,:,3) = mapminmax(im(:,:,1) - im(:,:,2), 0, 255);
    
    im = uint8(im);
    imwrite(im,'trill.jpg');
    imagesc(im);
%     subplot(3,1,1)
%     imagesc(box(i).par);
%     title(box(i).label);
%     subplot(3,1,2)
%     imagesc(box(i).ref);
%     subplot(3,1,3)
%     imagesc(box(i).par - box(i).ref);
%     pause
end
   
 