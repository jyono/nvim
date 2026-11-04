-- Specs (no passwords) live in stdpath('data')/dadbod_ui/k8s_postgres.json.
-- The URL, including the secret value, is built at connect time and kept in memory for this session only.

local M = {}

local session_urls = {}

local function specs_path() return vim.fs.joinpath(vim.fn.stdpath 'data', 'dadbod_ui', 'k8s_postgres.json') end

local function read_specs()
  local file = io.open(specs_path(), 'r')
  if not file then return {} end
  local text = file:read '*a'
  file:close()
  local ok, decoded = pcall(vim.json.decode, text)
  if not ok or type(decoded) ~= 'table' then return {} end
  local specs = {}
  for _, spec in ipairs(decoded) do
    if type(spec) == 'table' and type(spec.name) == 'string' then
      spec.context = spec.context or ''
      spec.namespace = spec.namespace or ''
      spec.secret = spec.secret or ''
      spec.password_key = spec.password_key or 'password'
      spec.user = spec.user or 'postgres'
      spec.user_key = spec.user_key or ''
      spec.database = spec.database or 'postgres'
      spec.port = tonumber(spec.port) or 5432
      specs[#specs + 1] = spec
    end
  end
  return specs
end

local function write_specs(specs)
  local path = specs_path()
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  local fd, open_err = vim.uv.fs_open(path, 'w', 384)
  if not fd then
    vim.notify('cannot write ' .. path .. ': ' .. tostring(open_err), vim.log.levels.ERROR)
    return false
  end
  local _, write_err = vim.uv.fs_write(fd, vim.json.encode(specs), 0)
  vim.uv.fs_close(fd)
  vim.uv.fs_chmod(path, 384)
  if write_err then
    vim.notify('cannot write ' .. path .. ': ' .. tostring(write_err), vim.log.levels.ERROR)
    return false
  end
  return true
end

---Run kubectl. args is the argv after the binary.
---@param args string[]
---@return string|nil, string|nil
local function kubectl(args)
  local cmd = { 'kubectl' }
  for _, arg in ipairs(args) do
    cmd[#cmd + 1] = arg
  end
  local result = vim.system(cmd, { text = true }):wait()
  if result.code ~= 0 then
    local err = vim.trim(result.stderr or '')
    if err == '' then err = vim.trim(result.stdout or '') end
    if err == '' then err = 'kubectl failed' end
    return nil, err
  end
  return result.stdout or '', nil
end

local function current_context()
  local stdout = kubectl { 'config', 'current-context' }
  if not stdout then return '' end
  return vim.trim(stdout)
end

local function current_namespace(context)
  local args = { 'config', 'view', '--minify' }
  if context ~= '' then
    args[#args + 1] = '--context'
    args[#args + 1] = context
  end
  args[#args + 1] = '-o'
  args[#args + 1] = 'jsonpath={..namespace}'
  local stdout = kubectl(args)
  if not stdout then return '' end
  return vim.trim(stdout)
end

local function secret_value(spec, key)
  local args = {}
  if spec.context ~= '' then
    args[#args + 1] = '--context'
    args[#args + 1] = spec.context
  end
  args[#args + 1] = 'get'
  args[#args + 1] = 'secret'
  args[#args + 1] = spec.secret
  args[#args + 1] = '-n'
  args[#args + 1] = spec.namespace
  args[#args + 1] = '-o'
  args[#args + 1] = 'go-template={{index .data ' .. string.format('%q', key) .. '}}'
  local stdout, err = kubectl(args)
  if not stdout then return nil, err end
  local b64 = stdout:gsub('%s', '')
  if b64 == '' or b64 == '<novalue>' then return nil, string.format('secret %s/%s has no data key %s', spec.namespace, spec.secret, key) end
  local ok, decoded = pcall(vim.base64.decode, b64)
  if not ok or type(decoded) ~= 'string' then return nil, 'base64 decode failed for ' .. key end
  return decoded:gsub('\n$', ''), nil
end

local function url_encode(value)
  return (value:gsub('[^%w%-_%.~]', function(char) return string.format('%%%02X', char:byte()) end))
end

local function publish()
  local list = {}
  for _, spec in ipairs(read_specs()) do
    local url = session_urls[spec.name]
    if url then list[#list + 1] = { name = spec.name, url = url } end
  end
  vim.g.dbs = list
  if vim.fn.exists '*db_ui#reset_state' == 1 then vim.fn['db_ui#reset_state']() end
end

local function open_drawer()
  pcall(vim.cmd.DBUIClose)
  vim.cmd.DBUI()
end

local function activate(spec)
  local password, err = secret_value(spec, spec.password_key)
  if not password or password == '' then
    vim.notify(err or 'empty password from secret', vim.log.levels.ERROR)
    return
  end
  local user = spec.user
  if spec.user_key ~= '' then
    local from_secret, user_err = secret_value(spec, spec.user_key)
    if not from_secret or from_secret == '' then
      vim.notify(user_err or 'empty username from secret', vim.log.levels.ERROR)
      return
    end
    user = from_secret
  end
  session_urls[spec.name] =
    string.format('postgresql://%s:%s@127.0.0.1:%d/%s?sslmode=disable', url_encode(user), url_encode(password), spec.port, url_encode(spec.database))
  publish()
  vim.notify(spec.name .. ': password from secret, this session only', vim.log.levels.INFO)
  if vim.fn.executable 'psql' ~= 1 then vim.notify('psql not on PATH — dadbod needs it for postgres', vim.log.levels.WARN) end
  open_drawer()
end

---Enter accepts default. Ctrl-C aborts. Empty + no default aborts when required.
---@return string|nil
local function prompt(label, default, required)
  local shown = label
  if default ~= '' then shown = shown .. ' [' .. default .. ']' end
  local ok, value = pcall(vim.fn.input, shown .. ': ')
  if not ok then return nil end
  value = vim.trim(value or '')
  if value == '' then
    if required and default == '' then
      vim.notify(label .. ' is required', vim.log.levels.WARN)
      return nil
    end
    return default
  end
  return value
end

local function new_spec()
  vim.cmd.redraw()
  local specs = read_specs()
  local previous = specs[#specs] or {}
  local context_default = current_context()
  if context_default == '' then context_default = previous.context or '' end
  local namespace_default = current_namespace(context_default)
  if namespace_default == '' then namespace_default = previous.namespace or '' end

  local name = prompt('Name', '', true)
  if not name then return end
  for _, spec in ipairs(specs) do
    if spec.name == name then
      vim.notify('connection ' .. name .. ' already exists', vim.log.levels.WARN)
      return
    end
  end
  local context = prompt('Context', context_default, true)
  if not context then return end
  local namespace = prompt('Namespace', namespace_default, true)
  if not namespace then return end
  local secret = prompt('Secret', '', true)
  if not secret then return end
  local password_key = prompt('Password key', previous.password_key or 'password', true)
  if not password_key then return end
  local user = prompt('Username', previous.user or 'postgres', true)
  if not user then return end
  local user_key = prompt('Username secret key (blank = username above)', '', false)
  if user_key == nil then return end
  local database = prompt('Database', previous.database or 'postgres', true)
  if not database then return end
  local port_text = prompt('Local port', tostring(previous.port or 5432), true)
  if not port_text then return end
  local port = tonumber(port_text)
  if not port or port < 1 or port > 65535 or port ~= math.floor(port) then
    vim.notify('port must be 1-65535', vim.log.levels.WARN)
    return
  end

  local spec = {
    name = name,
    context = context,
    namespace = namespace,
    secret = secret,
    password_key = password_key,
    user = user,
    user_key = user_key,
    database = database,
    port = port,
  }
  specs[#specs + 1] = spec
  if not write_specs(specs) then return end
  activate(spec)
end

local function delete_spec()
  local specs = read_specs()
  if #specs == 0 then
    vim.notify('no saved kubectl postgres connections', vim.log.levels.INFO)
    return
  end
  local labels = {}
  for _, spec in ipairs(specs) do
    labels[#labels + 1] = spec.name
  end
  vim.ui.select(labels, { prompt = 'Delete saved connection' }, function(_, idx)
    if not idx then return end
    vim.schedule(function()
      if vim.fn.confirm('Delete ' .. specs[idx].name .. '?', '&Yes\n&No', 2) ~= 1 then return end
      session_urls[specs[idx].name] = nil
      table.remove(specs, idx)
      if write_specs(specs) then publish() end
    end)
  end)
end

function M.connect()
  if vim.fn.executable 'kubectl' ~= 1 then
    vim.notify('kubectl not on PATH', vim.log.levels.ERROR)
    return
  end
  local specs = read_specs()
  if #specs == 0 then
    new_spec()
    return
  end
  local items = {}
  for _, spec in ipairs(specs) do
    items[#items + 1] = string.format('%s — %s/%s/%s @127.0.0.1:%d', spec.name, spec.context, spec.namespace, spec.secret, spec.port)
  end
  items[#items + 1] = 'New port-forward connection'
  items[#items + 1] = 'Delete saved connection'
  vim.ui.select(items, { prompt = 'Postgres (kubectl secret)' }, function(_, idx)
    if not idx then return end
    vim.schedule(function()
      if idx <= #specs then
        activate(specs[idx])
      elseif idx == #specs + 1 then
        new_spec()
      else
        delete_spec()
      end
    end)
  end)
end

return M
