animalids={'m820';'m822'}; % animals of interest
secinds={[86,89:96,98:101,103:112];[93,96:98,100,101]}; % files of interest
cropranges={[1,1500,301,1800];[101,1800,201,2000]};
wkdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Rosa/';
%%
for d=2
    cd(wkdir)
    animalid=animalids{d};
    secind=secinds{d};
    croprange=cropranges{d};
    cd(animalid)
    % read cell coordinates
    load([animalid,'_cells/cell2Nissl/celltfcoord.mat'])
    % read 8X downsampled nissl image
    % run Nissladj.m first
    fid=fopen('nisslfilenames.txt');
    filelist=textscan(fid,'%q');
    fclose(fid);
    filelist=filelist{1};
    Nfiles=length(secind);
    for f=1:Nfiles
        clear cellind1
        % adjust Nissl
        [~,fileid]=jp2ind(filelist,['N',num2str(secind(f))]);
        nisslimg=imread([animalid,'nissl/down8tf',fileid(end-7:end-4),'.jp2']);
        nisslpart=nisslimg(croprange(3):croprange(4),croprange(1):croprange(2),:);
        % visualize
        figure, imagesc(nisslpart)
        axis image
        axis ij
        % project cells
        cellind=cellcoordtf{f};
        ncells=size(cellind,1);
        if ncells>0
            cellind1(:,1)=cellind(:,1)/8-croprange(1)*ones(ncells,1);
            cellind1(:,2)=cellind(:,2)/8-croprange(3)*ones(ncells,1);
            hold on, scatter(cellind1(:,1),cellind1(:,2),'mo','filled','MarkerEdgeColor','m','linewidth',1)
        end
        axis off
        saveas(gca,[animalid,'_cells/cell2Nissl/',fileid])
        close
    end
end