%Zmap from meta analysis transform to tfce-map for each permulation
clc,clear
addpath(genpath('DPABI_V6.0_210501/'));
t_path = ''; %t values path
tfcemap_save_path = ''; %to save tfcemap result
folders = dir(t_path);
[Datam, VoxelSizem, FileListm, Headerm] = y_ReadAll('brani_mask.nii');
mask = logical(Datam);

for i = 3:length(folders)
    foldername = folders(i).name;
    [Datat, VoxelSizet, FileListt, Headert] = y_ReadAll([t_path filesep foldername filesep 'meta_Zmap_stouffer.nii']);
    G = Datat(mask);
    D = double(Datam);
    D(mask) = G;
    dh = max(G(:))/100;
    tfcestat = zeros(size(D));
    for h = dh:dh:max(D(:))
        CC    = bwconncomp(D>=h,6); % 6/18/26
        integ = cellfun(@numel,CC.PixelIdxList).^0.5 * h^2; %E=0.5; H=2
        for c = 1:CC.NumObjects
            tfcestat(CC.PixelIdxList{c}) = ...
                tfcestat(CC.PixelIdxList{c}) + integ(c);
            maxvalue = max(tfcestat(:));
        end
    end
    tfcestat = tfcestat(mask);
    tfcestat = tfcestat(:)' * dh;
    Data_tfce = Datat;
    Data_tfce(:)=0;
    Data_tfce(mask)=tfcestat;
    y_Write(Data_tfce,Headert,[tfcemap_save_path filesep strcat('tfce_',foldername, '.nii')])
end