clc,clear
addpath(genpath('DPABI_V6.0_210501/'));
tfcecorrected_save_path = ''; %to save tfcemap corrected result
[Datam, VoxelSizem, FileListm, Headerm] = y_ReadAll('mask.nii');
mask_index = find(Datam(:));
tfce_perm_path = '';
files = dir(tfce_perm_path);
max_tfce = [];
all_tfce = [];
for i = 4:length(files)
    filename = files(i).name;
    [Data, VoxelSize, FileList, Header] = y_ReadAll([tfce_perm_path filesep filename]);
    max_value = max(Data(:));
    max_tfce = [max_tfce;max_value];
    tfce = Data(mask_index);
    all_tfce = [all_tfce;tfce'];
end
[Datat, VoxelSizet, FileListt, Headert] = y_ReadAll([tfce_perm_path filesep 'tfce_per0.nii']);
tfce_value = Datat(mask_index);
max(tfce_value)
p_vec_tfce = [];
p_vec_untfce = [];
for pix = 1:length(tfce_value)
    p_tfce = length(find(tfce_value(pix) < max_tfce))/length(max_tfce);
    p_untfce = length(find(tfce_value(pix) < all_tfce(:,pix)))/size(all_tfce,1);
    p_vec_tfce = [p_vec_tfce;p_tfce];
    p_vec_untfce = [p_vec_untfce;p_untfce];
end
tfce_p = Datat;
tfce_p(:) = 0;
tfce_p(mask_index) = p_vec_tfce;
y_Write(tfce_p,Headert,[tfcecorrected_save_path filesep 'p_tfce_corrected.nii'])
tfce_p2 = Datat;
tfce_p2(:) = 0;
tfce_p2(mask_index) = 1-p_vec_tfce;
y_Write(tfce_p2,Headert,[tfcecorrected_save_path filesep 'p2_tfce_corrected.nii'])
tfce_un = Datat;
tfce_un(:) = 0;
tfce_un(mask_index) = p_vec_untfce;
y_Write(tfce_un,Headert,[tfcecorrected_save_path filesep 'p_tfce_uncorrected.nii'])
