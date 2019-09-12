function []=Nissladj()
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
    %
    cd(jp2dir)
    filelist=jp2lsread;
    Nfiles=length(secind);
    parfor f=1:Nfiles
        %         clear nisslimg1
        [~,fileid]=jp2ind(filelist,['N',num2str(secind(f))]);
        if ~isempty(fileid)
            dsfile=['~/',brainid,'/',brainid,'nissl/down8tf',fileid(end-7:end)];
            if ~exist(dsfile,'file')
                nisslimg=imread(['~/',brainid,'/',brainid,'nissl/fulltf',fileid(end-7:end)]);
                [rows,cols,c]=size(nisslimg);
                nisslimg1=uint8(zeros(ceil(rows/8),ceil(cols/8),c));
                for c=1:3
                    nisslimg1(:,:,c)=downsample_mean(nisslimg(:,:,c),8);
                end
                imwrite(nisslimg1,dsfile,'jp2')
            end
        end
    end
end