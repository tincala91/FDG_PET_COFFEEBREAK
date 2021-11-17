function mat_file = E_STAT_script(files, render, mask, controls)
  %declaring useful variables
  global JOB_DIR
  global xSPM

  files = cellstr(files);
  controls = cellstr(controls);

  [pth, ~, ~] = fileparts(files{1});
  cur_dir = pwd();

  % List of open inputs
  % Factorial design specification: Directory - cfg_files
  % Factorial design specification: Group 1 scans - cfg_files
  nrun = 1; % enter the number of runs here
  jobfile = cellstr(fullfile(JOB_DIR, 'STAT_script_job.m'));
  jobs = repmat(jobfile, 1, nrun);
  inputs = cell(4, nrun);
  for crun = 1:nrun
    inputs{1, crun} = cellstr(pth); % Factorial design specification: Directory - cfg_files
    inputs{2, crun} = files; % Factorial design specification: Group 1 scans - cfg_files
    inputs{3, crun} = controls; %Factorial design specification: Group 2 scans - cfg_files
    inputs{4, crun} = cellstr(mask); %Factorial design specification: mask - cfg_files
  end
  spm('defaults', 'PET');
  spm_jobman('run', jobs, inputs{:});

  mat_file = fullfile(pth, 'SPM.mat');

  cd(pth);
  export_fig 'Hypo.jpg';

  spm_render_DOC(struct('XYZ', xSPM.XYZ, 't',xSPM.Z,'mat', xSPM.M,'dim', xSPM.DIM), 1, render, 1);
  %saveas(gcf, 'Render_hypo_new.jpg');
  export_fig 'Render_hypo_new.jpg';

  spm_render_DOC(struct('XYZ', xSPM.XYZ, 't',xSPM.Z,'mat', xSPM.M,'dim', xSPM.DIM), nan, render);
  spm_figure('colormap','gray-cool');
  %saveas(gcf, 'Render_hypo_old.jpg');
  export_fig 'Render_hypo_old.jpg';

  cd(cur_dir);
end
