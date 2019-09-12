function []=cell2Nissltransform()
myCluster = parcluster('local'); % cores on compute node to be "local"
addpath(genpath('~/'))
poolobj=parpool(myCluster, 12);
% brainids={'m820';'m822'};
brainids={'m920'};
% secinds={[86,89:96,98:101,103:112];[93,96:98,100,101]}; % files of interest
secinds={[104:120]};
D=length(brainids);
for d=1:D
    brainid=brainids{d};
    % Identify sections
    secind=secinds{d};
    jp2dir=['/nfs/mitraweb2/mnt/disk123/main/marmosetTEMP/JP2/',brainid,'/']; % go to the temporary directory of JP2 on M24
    % jp2dir=['/nfs/mitraweb2/mnt/disk125/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/'];
    %
    cd(jp2dir)
    filelist=jp2lsread;
    Nfiles=length(secind);
    cellcoordtf=cell(Nfiles,1);
    for f=1:Nfiles
        [~,fileid]=jp2ind(filelist,['F',num2str(secind(f))]);
        if ~isempty(fileid)
            % get cell coordinates
            cellimgfile=['~/',brainid,'/',upper(brainid),'_cells/cell2Nissl/fullcell',fileid(end-7:end-4),'.tif'];
            if exist(cellimgfile,'file')
                cellimg=imread(cellimgfile);
                if sum(sum(cellimg>10))>0
                    bw=imregionalmax(cellimg);
                    [cellx,celly]=find(bw);
                    cellcoordtf{f}=[celly,cellx];
                else
                    cellcoordtf{f}=[];
                end
            end
        end
    end
    save(['~/',brainid,'/',upper(brainid),'_cells/cell2Nissl/cellcoord.mat'],'cellcoordtf')
    
end