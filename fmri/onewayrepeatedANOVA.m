function matlabbatch = onewayrepeatedANOVA(TOTDIR_con,scans,cov,MASK, threshold)
spm('defaults','fmri'); spm_jobman('initcfg');
%% model setup
matlabbatch{1}.spm.stats.factorial_design.dir = {TOTDIR_con};
Ncon = max(size(scans));
Nsub = length(scans{1});
for i_sub = 1: Nsub
    scans_sub = {};
    for icon = 1: Ncon
        scans_sub = [scans_sub; scans{icon}{i_sub}];
    end
    matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(i_sub).scans = scans_sub;
    matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(i_sub).conds = [1 2 3];
end
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anovaw.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = cov;
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {MASK};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;


%% model estimation
SPMDIR=[TOTDIR_con,'/SPM.mat'];
matlabbatch{2}.spm.stats.fmri_est.spmmat = {SPMDIR};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


%% define contrasts
matlabbatch{3}.spm.stats.con.spmmat = {SPMDIR};
matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'Repeated ANOVA F test - difference between any two visits';
matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [0.5 -0.25 -0.25
                                                        -0.25 0.5 -0.25
                                                        -0.25 -0.25 0.5];
matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = '0.5mg/kg vs Placebo';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [1 0 -1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Placebo vs 0.5mg/kg';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [-1 0 1];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = '0.5mk/kg vs 0.05mk/kg';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [1 -1];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = '0.05mk/kg vs 0.5mk/kg';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [-1 1];
matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = '0.05mk/kg vs Placebo';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 1 -1];
matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'Placebo vs 0.05mk/kg';
matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [0 -1 1];
matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.delete = 0;

%% result summary
if ~isempty(threshold)
    matlabbatch{4}.spm.stats.results.spmmat = {SPMDIR};
    matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
    matlabbatch{4}.spm.stats.results.conspec.contrasts = Inf;
    matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{4}.spm.stats.results.conspec.thresh = threshold{1};
    matlabbatch{4}.spm.stats.results.conspec.extent = 0;
    matlabbatch{4}.spm.stats.results.conspec.conjunction = 7;
    matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{4}.spm.stats.results.units = 1;
    matlabbatch{4}.spm.stats.results.export{1}.ps = true;
end

% spm_jobman('interactive', matlabbatch);
spm_jobman('run',matlabbatch);

