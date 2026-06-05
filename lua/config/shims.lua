-- Workarounds for older 0.12.0-dev builds (remove when on 0.12 stable).
vim.list = vim.list or {
  unique = function(l)
    local seen, out = {}, {}
    for _, v in ipairs(l) do
      if not seen[v] then
        seen[v] = true
        out[#out + 1] = v
      end
    end
    return out
  end,
}
