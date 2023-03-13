%export true tmap (per0) and permutation tmap (per1-1000)
clc,clear
result_path = '';
img_path = '';
covs_data_path = ''; %id,intrest_var,nointrest_vars,centers
num_covs = 8; %number of no interset varites
mask_path = 'brain_mask.nii';
[num_no_perm_centers,~,raw] = xlsread(covs_data_path,1);
centers = num_no_perm_centers(:,end);
cen = unique(centers);
for per = 1:1000
    mkdir([result_path filesep strcat('Tmap_per',num2str(per))])
    for c = 1:length(cen)
        cen_index = find(centers == cen(c));
        if length(cen_index) > num_covs
            mkdir([result_path filesep strcat('Tmap_per',num2str(per)) filesep strcat('Tmap_center',num2str(c))])
            num_no_perm = num_no_perm_centers(cen_index,:);
            %% %no permutataion image data
            img_files = dir(img_path);
            path_filenames = [];
            for img = 1:length(cen_index)
                filename = img_files(cen_index(img)+2).name;
                path_filename = strcat(img_path,filename,',1');
                path_filenames = [path_filenames;{path_filename}];
            end
            matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = path_filenames;
            %permutataion noimage data
            num = num_no_perm;
            if per ~= 0
                rng(per)
                perm_num = randperm(size(num,1));
                num = num_no_perm(perm_num,:);
            end
            %%
            result_path_per = [result_path filesep strcat('Tmap_per',num2str(per)) filesep strcat('Tmap_center',num2str(c))];
            matlabbatch{1}.spm.stats.factorial_design.dir = {result_path_per};
            %%
            for covs_noint = 1:num_covs
                cov_noint = num(:,covs_noint+2);
                cov_noint_name = cell2mat(raw(1,covs_noint+2));
                matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(covs_noint).c = cov_noint;
                matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(covs_noint).cname = cov_noint_name;
                matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(covs_noint).iCC = 1;
            end
            matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;
            %%
            cov_int = num(:,2);
            cov_int_name = cell2mat(raw(1,2));
            matlabbatch{1}.spm.stats.factorial_design.cov.c = cov_int;
            %%
            matlabbatch{1}.spm.stats.factorial_design.cov.cname = cov_int_name;
            matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1;
            matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1;
            matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
            matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
            matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
            matlabbatch{1}.spm.stats.factorial_design.masking.em = {strcat(mask_path, ',1')};
            matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
            matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
            matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
            matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
            matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
            matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
            matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'pos';
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [0 1];
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'neg';
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 -1];
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
            matlabbatch{3}.spm.stats.con.delete = 0;
            spm('defaults', 'FMRI');
            spm_jobman('run', matlabbatch);
        end
    end
end