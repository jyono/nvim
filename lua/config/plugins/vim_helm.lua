---@type LazySpec
return {
  {
    'towolf/vim-helm',
    event = 'BufReadPre',
    -- Sets filetype=helm (not yaml) for templates including .tpl
  },
}
