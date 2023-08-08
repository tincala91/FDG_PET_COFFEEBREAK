function files = E_STAT_script_addon(spm_mat_file, render, template)
  %declaring useful variables
  global JOB_DIR

  [pth, ~, ~] = fileparts(spm_mat_file);
  cur_dir = pwd();

  % List of open inputs
  % Results Report: Select SPM.mat - cfg_files
  nrun = 1; % enter the number of runs here
  jobfile = cellstr(fullfile(JOB_DIR, 'STAT_script_addon_job.m'));
  jobs = repmat(jobfile, 1, nrun);
  inputs = cell(1, nrun);
  for crun = 1:nrun
    inputs{1, crun} = cellstr(spm_mat_file); % Results Report: Select SPM.mat - cfg_files
  end
  spm('defaults', 'PET');
  spm_jobman('run', jobs, inputs{:});


  cd(pth);
  export_fig 'Pres.jpg'

  %spm_render_DOC(struct('XYZ', xSPM.XYZ, 't',xSPM.Z,'mat', xSPM.M,'dim', xSPM.DIM), 1, render, 0);
  spm_render_DOC(get_renderer(), 1, render, 0);
  export_fig 'Render_pres_new.jpg'; %saves render as jpeg (get current figure!)

  %spm_render_DOC(struct('XYZ', xSPM.XYZ, 't',xSPM.Z,'mat', xSPM.M,'dim', xSPM.DIM), nan, render);
  spm_render_DOC(get_renderer(), nan, render);
  export_fig 'Render_pres_old.jpg'

  hypo_nii = 'spmT_0001_Hypo.nii';
  pres_nii = 'spmT_0002_Pres.nii';

  %inputs should be char, but not possible to concatenate chars of different
  %length; creating a matrix containing cells first, and then converting to
  %char

  SaveAxialPlot(template, hypo_nii, pres_nii);
  
  cd(cur_dir);

end
