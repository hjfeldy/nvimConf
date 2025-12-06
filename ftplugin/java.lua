local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

local config = {
    cmd = {'jdtls', project_name},
    -- root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw', 'pom.xml'}, { upward = true })[1]),
    root_dir = vim.fs.dirname(vim.fs.find({'.git', 'pom.xml'}, { upward = true })[1]),
    filetypes = {'java'},
    settings = {
      java = {
        configuration = {
          runtimes = {
            {
              name = 'JavaSE-1.8',
              path = '/Users/rc12664/AppData/local/Programs/Eclipse Adoptium/jdk-8.0.462.8-hotspot/'
            }
          }
        }
      }
    },
}

if vim.g.NO_LSP then
  print('Neglecting to turn on jdtls - LSP is disabled globally')
else
  print('Attaching jdtls')
  require('jdtls').start_or_attach(config)
end
