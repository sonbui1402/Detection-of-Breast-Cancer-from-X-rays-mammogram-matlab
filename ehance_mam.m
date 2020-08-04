function b= enhance_mam(a); 
[r,c]=size(a);
k=fspecial('gaussian',[3 3],5); % loc thong thap gaussian
f=imfilter(a,k); %loc anh theo nhieu huong
m11=min(min(f)); %lay gia tri pixel min
m1=max(max(f));%lay gia tri pixel max
f2=a-f; %lay duong vien
m12=min(min(f2));
m2=max(max(f2));
mid1=abs(m12+m2)/2;
%tang cuong anh duong vien
[r,c]=size(f2);
g1=10;
%g1=7
g2=400;
%g2=0.4
for i=1:r
    for j=1:c
        if abs(f2(i,j))<mid1
            f2(i,j)=g1*f2(i,j);
        else if abs(f2(i,j))>=mid1
                f2(i,j)=g2*f2(i,j);
            end
        end
    end
end
f3=f2;
se=strel('disk',5);%tao cau truc phan tu
%bien doi top-hat
b1=imerode(f,se); %lam mo
b11=imdilate(b1,se); % mo rong thang xam
b=imsubtract(f,b11); 
%bien doi bottom-hat
b11=imdilate(f,se); %mo rong thang xam
b1=imerode(b11,se); %lam mo
c=imsubtract(b1,f);
e=f+b-c; % lam ro tuong phan giua cac vat the. anh goc + tophat - bottomhat
f6=f2+e; % anh goc + anh lam duong vien
%%%%%%%%%%%%%wavelet decomposition%%%%%%%%%%%%%%
% phan tach ham thanh cac thanh phan cau truc doc, ngang va cheo
[c,s]=wavedec2(f6,2,'bior1.1');

ca2=appcoef2(c,s,'bior1.1',2);
ca1=appcoef2(c,s,'bior1.1',1);

[cH2,cV2,cD2]=detcoef2('all',c,s,2);
[cH1,cV1,cD1]=detcoef2('all',c,s,1);
%%%%%%%%%%%Thresholding Calculation%%%%%%%%%%

    MH=max(max(cH1));
    MH=log2(MH);
    MHL=100000;
    %MHL=0.5
    TH=MH*MHL;
       
    MV=max(max(cV1));
     MV=log2(MV);
    MVL=0.5;
    TV=MV*MVL;
    
    MD=max(max(cD1));
     MD=log2(MD);
    MDL=0.5;
    TD=MD*MDL;
    
%     C1=2;
    MH2=max(max(cH2));
     MH2=log2(MH2);
    MHL2=1;
    TH2=MH2*MHL2;
    
    
    MV2=max(max(cV2));
     MV2=log2(MV2);
    MVL2=1;
    TV2=MV*MVL2;
    
    MD2=max(max(cD2));
     MD2=log2(MD2);
    MDL2=1;
    TD2=MD2*MDL2;
    
ch1 =wthresh(cH1,'s',TH);
cv1= wthresh(cV1,'s',TV);
cd1= wthresh(cD1,'s',TD);
ch2= wthresh(cH2,'s',TH2);
cv2= wthresh(cV2,'s',TV2);
cd2= wthresh(cD2,'s',TD2);
%%%%%%%%%%%%%%%reconstruction%%%%%%%%%%%%%%%
%tai tao lai anh
ca2=ca2(:)';
ch2=ch2(:)';
cv2=cv2(:)';
cd2=cd2(:)';
ch1=ch1(:)';
cv1=cv1(:)';
cd1=cd1(:)';
d=[ca2 ch2 cv2 cd2];
t=[ch1 cv1 cd1];
C=[d t];
b=waverec2(C,s,'bior1.1');
b=uint8(b); %ep kieu du lieu tu double sang uint8 cho b
