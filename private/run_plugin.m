function run_plugin(index, varargin)
  % Simple wrapper to run function from Plugins directory
  % with same letter index and given parameters
  %
  % The plugin script must have same name as folder, including the index

  cur_dir = pwd();
  paths = path();
  cleanup = onCleanup(@()restorePaths(paths, cur_dir));

  pth = fileparts(mfilename('fullpath'));
  plugins_path = fullfile(pth, '..', 'Plugins');

  plugins = dir(fullfile(plugins_path, [index, '_*']));

  if numel(plugins) == 0
    return;
  end

  if numel(plugins) > 1
    warning('Plugin %s: Found several plugins, will run only first', index);
  end

  plugin_path = fullfile(plugins(1).folder, plugins(1).name);
  plugin_script = fullfile(plugin_path, 'plugin.m');
  if ~exist(plugin_script, 'file')
    warning('Plugin %s: Can''t find script plugin.m', index);
    return;
  end

  fprintf('Plugin %s: Running from %s\n', index, plugin_path);

  addpath(plugin_path);
  plugin(varargin{:});

end


function restorePaths(search_paths, current_path)
  path(search_paths);
  cd(current_path);
end
