if vim.g.NO_LSP then
  print('Neglecting to turn on jdtls - LSP is disabled globally')
  return
end

local bufnr = vim.api.nvim_get_current_buf()
local buffer_uri = vim.uri_from_bufnr(bufnr)
if not vim.startswith(buffer_uri, 'file://') then
  return
end
local buffer_path = vim.uri_to_fname(buffer_uri)

local root_markers = {
  'gradlew',
  'mvnw',
  'pom.xml',
  'build.gradle',
  'build.gradle.kts',
  'settings.gradle',
  'settings.gradle.kts',
  '.git',
}
local root_dir = vim.fs.root(bufnr, root_markers) or vim.fs.dirname(buffer_path)
if not root_dir then
  return
end
local project_name = vim.fs.basename(root_dir):gsub('[^%w._-]', '_')
if project_name == '' then
  project_name = 'project'
end
local workspace_name = ('%s-%s'):format(project_name, vim.fn.sha256(root_dir):sub(1, 8))
local workspace_dir = vim.fs.joinpath(vim.fn.stdpath('cache'), 'jdtls', workspace_name)

local config = {
    cmd = {'jdtls', '-data', workspace_dir},
    root_dir = root_dir,
    filetypes = {'java'},
    settings = {
      java = {
        configuration = {
          -- runtimes = {
          --   {
          --     name = 'JavaSE-1.8',
          --     -- path = os.getenv('HOME') .. '/AppData/local/Programs/Eclipse Adoptium/jdk-8.0.462.8-hotspot/'
          --     path = os.getenv('HOME') .. '/AppData/local/Programs/Eclipse Adoptium/jdk-8.0.462.8-hotspot/'
          --   }
          -- }
        }
      }
    },
}

print('Attaching jdtls')
require('jdtls').start_or_attach(config)
