clear all
close all
animalids={'m820';'m822'}; % animals of interest
secinds={[86,89:96,98:101,103:112];[93,96:98,100,101]}; % files of interest
wkdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Rosa/';
M=64; % downsample factor
load([wkdir,'regionlookup.mat'])
%%
% for d=1:2
%     cd(wkdir) % set working directory
%     animalid=animalids{d};
%     secind=secinds{d};
%     % get file names
%     cd([animalid,'/',upper(animalid),'F-STIF/'])
%     filelist=filelsread('*.tif');
%     cd([wkdir,animalid])
%     S=length(secind);
%     fileind=zeros(S,1);
%     fileid=cell(S,1);
%     for s=1:S
%         [fileind(s),fileid{s}]=jp2ind(filelist,['F',num2str(secind(s))]);
%
%     % 1. load cell coordinates
%     cellcoord=readcellcoord([animalid,'_cells/',fileid{s}(1:end-4),'.jp2']);
%     %         downsample
%     cellcoordds=round(cellcoord/M);
%     % 2. generate cell mask
%     tifinfo=imfinfo([upper(animalid),'F-STIF/',fileid{s}(1:end-4)],'tif');
%     cellmask=zeros(tifinfo.Height*M,tifinfo.Width*M); % same size as the STIF
%     for c=1:size(cellcoordds,1)
%         cellmask(cellcoordds(c,2),cellcoordds(c,1))=255;
%     end
%     % 3. save cell mask
%     imwrite(cellmask,[animalid,'_cells/',fileid{s}(1:end-4),'_cellmask.tif'])
%     end
%     save('cellfileind','fileind','fileid')
% end
% %% run on BNB
% % python ~/scripts/LGNPulvinarProj/2_fluocell2nissl/applySTSCompositeTransform_fluo_marmoset_BH.py M820 136 161 304 311
% % python ~/scripts/LGNPulvinarProj/2_fluocell2nissl/applySTSCompositeTransform_fluo_marmoset_BH.py M822 178 186 320 351
%
% % generate Nissl series
% % python ~/scripts/LGNPulvinarProj/applySTSCompositeTransform_nisslatlas_BH.py M820 132 159 304 311
% % python ~/scripts/LGNPulvinarProj/applySTSCompositeTransform_nisslatlas_BH.py M822 182 190 320 351
% % % transfer files back
%%
annoinds={182+(86-secinds{1});[244;241;240;239;237;236]};
for d=2
    cd(wkdir) % set working directory
    animalid=animalids{d};
    annostack=load_nii([animalid,'/',upper(animalid),'_annotation.img']);
    %     nisslstack=load_nii([animalid,'/',upper(animalid),'_orig_target_STS.img']);
    secind=secinds{d};
    S=length(secind);
%     regioninds=cell(S,1);
    load([animalid,'/',animalid,'_cells/cellfileind.mat'])
    load([animalid,'/cellregionout.mat'])
    for s=1:S
        annoimg=squeeze(annostack.img(:,annoinds{d}(s),:));
        %         annoimgRH=annoimg>9000;
        %         annoimg=annoimg-annoimgRH*10000;
        % get cell coordinates
        cellimg=imread([animalid,'/',animalid,'_cells/cellmask2Nissl/cell',fileid{s}(end-7:end)]);
        % generate mask
        tfimg=imread([animalid,'/',animalid,'F2N/tf',fileid{s}(end-7:end)]);
        secmask=tfimg>0;
        se=strel('disk',5);
        secmask=imerode(secmask,se);
        secmask(:,1:5)=0;
        secmask(1:5,:)=0;
        % crop the image
        cellimg=cellimg.*secmask;
        % find cell centers
        if sum(sum(cellimg>10))>0
            bw=imregionalmax(cellimg.*(cellimg>10));
            [cellx,celly]=find(bw);
            % overlay with Nissl
            nisslimg=imread([animalid,'/',animalid,'nissl/tf',fileid{s}(end-7:end)]);
            figure, imagesc(uint8(nisslimg))
            axis image
            axis ij
            % overlay cells
            hold on, scatter(celly,cellx,'m.')
            axis off
%             saveas(gca,[animalid,'/',animalid,'_cells/cell2Nissl/',fileid{s}])
            % find region numbers
            regionind=regioninds{s};
%             for i=1:length(cellx)
%                 cellregions(i)=annoimg(cellx(i),celly(i));
%             end
%             % plot regions
%             regionind=unique(cellregions); % identify brain regions
%             if sum(regionind==0)>0
%                 % manual identification
%                 regionind=nonzeros(regionind);
%                 figure, imagesc(annoimg)
%                 hold on, scatter(celly,cellx,'m.')
% %                 axis([0 70 70 200]) % m820
%                 axis([20 100 60 160])
%                 caxis([70 90])
%                 [x,y]=getpts(gca);
%                 x=round(x);
%                 y=round(y);
%                 for xi=1:length(x)
%                     regionind=[regionind;annoimg(y(xi),x(xi))];
%                 end
%                 close
%             end
%             regionind=unique(regionind);
%             regioninds{s}=regionind;
            legendid={'cell'};
            for r=1:length(regionind)
                contour=bwboundaries(annoimg==regionind(r));
                contourX=[];
                contourY=[];
                for c=1:length(contour)
                    if length(contour{c})>2
                        contourX=[contourX,{contour{c}(:,2)}];
                        contourY=[contourY,{contour{c}(:,1)}];
                    end
                end
                
                regionpoly=polyshape(contourX,contourY);
                plot(regionpoly)
                regionind_ind=find(regionindsalli==regionind(r));
                legendid{r+1}=regiontable{regionind_ind};
            end
            legend(legendid)
            saveas(gca,[animalid,'/cell2atlas/',fileid{s}])
%             alpha 1
            
%             saveas(gca,[animalid,'/cell2atlas/',fileid{s}(1:end-4),'.eps'])
            close
        else
%             regioninds{s}=[];
        end
    end
    save([animalid,'/cellregionout'],'regioninds')
end