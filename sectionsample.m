%% generate samples for Figure 2

fluimg1=uint8(fluimg);
% figure, imagesc(fluimg1)
% axis image
% xlims=get(gca,'xlim')
% ylims=get(gca,'ylim');
% xlims=round(xlims);
% ylims=round(ylims);
Fsample=fluimg1(ylims(1):ylims(2),xlims(1):xlims(2),:);
figure, imagesc(Fsample)
% bluemask=Fsample(:,:,3)>100;
% Fsample1=Fsample;
% Fsample1(:,:,3)=Fsample1(:,:,3)+uint8(bluemask*255);
imwrite(Fsample,[fileid,'_LGNpul.tif'],'tif')
%%
clear regionpoly
for i=[2:5,10]
regionpoly{i}=polyshape(regiondata{i});
end
figure, hold on
for i=[2:5,10]
plot(regionpoly{i})
end
axis image
axis ij
alpha 1
axis off
print([fileid,'_LGNpul.eps'],'-deps')