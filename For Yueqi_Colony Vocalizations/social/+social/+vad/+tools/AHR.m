function [ AHR, vm ] = AHR( oneCut, band )
    m       =   max(oneCut(band(1):end,:),[],1);
    aw      =   3;
    oneCut1 =   medfilt2(oneCut,[aw,1]);
    v       =   mean(abs(oneCut1 - oneCut),1);
    vm      =   m./v;
    AHR     =   mean(vm);
    A       =   fspecial('average',[1,10]);
    vm      =   filter2(A, vm);
end

