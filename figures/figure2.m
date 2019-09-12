brainid='m919';
M=64;
filelist=jp2lsread;
secid=input('Please select a test section: ','s'); % sec 200 for m919
[f,jp2file]=jp2ind(filelist,secid);
fluoroimg=imread(jp2file);
fluoroimg1=uint8(fluoroimg);
figure, imagesc(fluoroimg1)
axis off
axis image
%%
h=gca;
xlims=get(h,'xlim');
ylims=get(h,'ylim');
fluimg=fluoroimg1(ylims(1):ylims(2),xlims(1):xlims(2),:);
figure, imagesc(fluimg)
%%
load('background_standard.mat')
tiffile=['../',upper(brainid),'F-STIF/',jp2file(1:end-4),'.tif'];
% load mask
maskfile=['imgmasks/imgmaskdata_',num2str(f)];
[brainimg,bgimgmed]=bgmean3(tiffile,maskfile);
[rows,cols,~]=size(fluimg);
adjmat=ones(rows,cols,3);
adjmat=single(adjmat);
for c=1:3
adjmat(:,:,c)=adjmat(:,:,c)*(bgimgmed(c)-bgimgmed0(c));
end
fluimg1=single(fluimg)-adjmat;
figure, imagesc(uint8(fluimg1))
%%
% imwrite(uint8(fluimg1),[jp2file(1:end-4),'_LGNpul.tif'],'tif')
imwrite(uint8(fluimg),[jp2file(1:end-4),'_LGNpul.tif'],'tif')