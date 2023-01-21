function matlabbatch = onesamplettest(totdir, scans, cov, MASK, threshold)
spm('defaults','fmri'); spm_jobman('initcfg');
matlabbatch{1}.spm.stats.factorial_design.dir = {totdir};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans =scans;
matlabbatch{1}.spm.stats.factorial_design.cov = cov;
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {MASK};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
SPMDIR=[totdir,'/SPM.mat'];
matlabbatch{2}.spm.stats.fmri_est.spmmat = {SPMDIR};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat = {SPMDIR};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Mean';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = ['Mean-'];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [-1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;

%% result summary
if ~isempty(threshold)
    matlabbatch{4}.spm.stats.results.spmmat = {SPMDIR};
    matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
    matlabbatch{4}.spm.stats.results.conspec.contrasts = Inf;
    matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{4}.spm.stats.results.conspec.thresh = threshold{1};
    matlabbatch{4}.spm.stats.results.conspec.extent = 0;
    matlabbatch{4}.spm.stats.results.conspec.conjunction = 2;
    matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{4}.spm.stats.results.units = 1;
    matlabbatch{4}.spm.stats.results.export{1}.ps = true;
end


% spm_jobman('interactive', matlabbatch);
spm_jobman('run',matlabbatch);