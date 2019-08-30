Len = 1000;
bank = zeros(24,floor(Len/2)+1);
startStop = [1,20;
             10,50;
             20,80;
             50,110;
             100,115;
             110,125;
             120,135;
             130,145;
             140,155;
             150,165;
             160,175;
             170,185;
             180,195;
             190,205;
             200,215;
             210,225;
             220,235;
             230,245;
             240,270;
             260,320;
             300,360;
             340,400;
             380,460;
             440,500];
k = Len/1000;          
for i = 1 : 24
    bank(i,:) = social.vad.win_triangle(ceil(startStop(i,1)*k),ceil(startStop(i,2)*k),floor(Len/2)+1,1);
end
save MFCCBank bank