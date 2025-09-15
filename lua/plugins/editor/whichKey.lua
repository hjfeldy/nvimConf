-- keybinding display

return {
  "folke/which-key.nvim",
  opts = function() 
    return {
      delay=333,
      preset = 'modern',
      presets = {},
      filter = function(mapping)
        return mapping.noremap == 1
      end,
      triggers = {
        { "<leader>" , mode={"n", "v"}},
        { "g" , mode={"n", "v"}},
        { "q" , mode={"n", "v"}},
      },
      replace = {
        key = {
          function(key)
            if key == "<Space>" then
              return "Commands"
            end
            local out = require('which-key.view').format(key)
            if out ~= key then 
              -- print('Replacing "' .. key .. '" with "' .. out .. '"')
            end
          end
        }
      }
      --[[ filter = function(entry) 
        -- print('Filtering entry:\n' .. vim.inspect(entry))
      end ]]
    }
end
}
