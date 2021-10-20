function files = E_STAT_script(files, render, mask, controls)
  %declaring useful variables
  global JOB_DIR
  global xSPM

  files = cellstr(files);
  controls = cellstr(controls);

  [pth, ~, ~] = fileparts(files{1});

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
  export_fig 'Hypo.jpg';

  params.XYZ = xSPM.XYZ;
  params.t = xSPM.Z;
  params.mat = xSPM.M;
  params.dim = xSPM.DIM;
  spm_render_DOC(params, 1, render, 1);
  %saveas(gcf, 'Render_hypo_new.jpg');
  export_fig 'Render_hypo_new.jpg';

  spm_render_DOC(params, nan, render);
  spm_figure('colormap','gray-cool');
  %saveas(gcf, 'Render_hypo_old.jpg');
  export_fig 'Render_hypo_old.jpg';
end
