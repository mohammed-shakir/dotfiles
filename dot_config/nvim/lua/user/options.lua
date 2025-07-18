return function(local_vim)
  -- force Vimscript set with a safely-quoted literal
  local_vim.cmd "set whichwrap+=<,>,h,l,[,]"
  return local_vim
end
