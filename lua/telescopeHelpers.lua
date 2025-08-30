local builtin = require('telescope.builtin')
local actionState = require("telescope.actions.state")
local util = require('util')

local M = {}

local SHOW_HIDDEN = false
local RESPECT_IGNORE = true

local function toggleIgnore() 
  RESPECT_IGNORE = not RESPECT_IGNORE
end

local function toggleHidden() 
  SHOW_HIDDEN = not SHOW_HIDDEN
end


M.findFilesToggleHidden = function(args) 
  toggleHidden()
  local currentText = actionState.get_current_line()
  M.findFiles(util.merge(args, {default_text=currentText}))
end

M.findFilesToggleIgnore = function(args) 
  toggleIgnore()
  local currentText = actionState.get_current_line()
  M.findFiles(util.merge(args, {default_text=currentText}))
end

M.liveGrepToggleHidden = function(args) 
  toggleHidden()
  local currentText = actionState.get_current_line()
  M.liveGrep(util.merge(args, {default_text=currentText}))
end

M.liveGrepToggleIgnore = function(args) 
  toggleIgnore()
  local currentText = actionState.get_current_line()
  M.liveGrep(util.merge(args, {default_text=currentText}))
end


M.findFiles = function(args) 
  args = args or {}
  if args.hidden == nil then
    args.hidden = SHOW_HIDDEN
  end
  if args.no_ignore == nil then
    args.no_ignore = not RESPECT_IGNORE
  end
  builtin.find_files(args)
end

M.liveGrep = function(args) 
  args = args or {}
  local additional_args = args.additional_args or {}
  if SHOW_HIDDEN then 
    additional_args[#additional_args+1] = "--hidden"
  end
  if not RESPECT_IGNORE then 
    additional_args[#additional_args+1] = "--no-ignore"
  end
  args.additional_args = additional_args
  print(vim.inspect(args.additional_args))
  builtin.live_grep(args)
end

return M
