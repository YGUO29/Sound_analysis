function [ oneSig ] = weightMatrix( oneSig, band )
    oneSig = abs(oneSig);
    oneSig(1:band(1),:) = 0;
    oneSig(band(2):end,:) = 0;
    se = strel('square',3);
    oneSig = imopen(oneSig,se);
    oneSig = imopen(oneSig,se);
end

