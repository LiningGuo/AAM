%image based meta analysis
clc, clear, close all
addpath(genpath('DPABI_V6.0_210501/'));
meta_save_path = 'result_path'; %to save meta analysis result (Zmap, Pmap, 1-Pmap)
Datam = y_ReadAll('brain_mask.nii');
index_m = find(Datam(:));
tmap_cmap_path = 'Tmap';
folders_per = dir(tmap_cmap_path);
for p = 3:1001
    folder_p = folders_per(p).name;
    folders_cen = dir([tmap_cmap_path filesep folder_p]);
    t_mat = [];
    c_mat = [];
    for c = 3:length(folders_cen)
        folder_c = folders_cen(c).name;
        tar_path = [tmap_cmap_path filesep folder_p filesep folder_c];
        [Datat, VoxelSizet, FileListt, Headert] = y_ReadAll([tar_path filesep 'spmT_0001.nii']);       
        [Datac, VoxelSizec, FileListc, Headerc] = y_ReadAll([tar_path filesep 'con_0001.nii']);
        Datat_vec = Datat(index_m);
        Datac_vec = Datac(index_m);
        t_mat = [t_mat;Datat_vec'];
        c_mat = [c_mat;Datac_vec'];
        %for stouffer's z method
        tf_df_tmp = regexpi(Headert.descrip, '[SPM,REST,DPABI]{([TF])_\[(.*)\]}.*', 'tokens');
        df(c-2,1) = str2num(tf_df_tmp{1,1}{1,2});
        z_map(:,c-2) = spm_t2z(Datat(index_m),str2num(tf_df_tmp{1,1}{1,2}));
    end
    % stouffer's z analysis
    w_mat = repmat(sqrt(df),[1,length(index_m)]);
    Zfinal = sum(w_mat.*z_map')/sqrt(sum(df));
    Pfinal = 2*normcdf(abs(Zfinal),'upper');
    P2final = 1-Pfinal;
    mkdir([meta_save_path filesep folder_p(6:end)])
    Zmap = zeros(size(Datam));
    Zmap(index_m) = Zfinal;
    y_Write(abs(Zmap),Headert,[meta_save_path filesep folder_p(6:end) filesep 'meta_Zmap_stouffer.nii'])
    Pmap = zeros(size(Datam));
    Pmap(index_m) = Pfinal;
    y_Write(Pmap,Headert,[meta_save_path filesep folder_p(6:end) filesep 'meta_Pmap_stouffer.nii'])
    P2map = zeros(size(Datam));
    P2map(index_m) = P2final;
    y_Write(P2map,Headert,[meta_save_path filesep folder_p(6:end) filesep 'meta_P2map_stouffer.nii'])
end
