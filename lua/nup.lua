local M = {}
local MSG_PREFIX = "nup:: "

-- Default base URL, can be overridden in setup
M.BASE_URL = "https://basedbin.fly.dev"

-- Function to upload files from a list of paths
M.upload_files = function(file_paths)
  if #file_paths == 0 then
    print(MSG_PREFIX .. "No files to upload!")
    return
  end

  if not M.BASE_URL then
    print(MSG_PREFIX .. "Base URL is not set! Use setup() to configure it.")
    return
  end

  for _, file in ipairs(file_paths) do
    local filename = vim.fn.fnamemodify(file, ":t")
    local extension = filename:match("%.([^%.]+)$") or ""
    local cmd = "curl -fsSL --data-binary @" .. file .. " --url " .. M.BASE_URL

    print(MSG_PREFIX .. "Uploading to " .. M.BASE_URL)
    local response = vim.fn.system(cmd):gsub("\n", "")
    local paste_link = M.BASE_URL .. response

    if extension ~= "" then
      paste_link = paste_link .. "." .. extension
    end

    if paste_link then
      print(MSG_PREFIX .. "Uploaded to " .. paste_link)
      vim.fn.setreg("+", paste_link)
      print(MSG_PREFIX .. "URL copied to clipboard")
    else
      print(MSG_PREFIX .. "Failed to extract the URL from the response.")
    end
  end
end

-- Provide a function to change the base URL
M.set_base_url = function(url)
  M.BASE_URL = url
  print(MSG_PREFIX .. "Base URL set to: " .. M.BASE_URL)
end

-- Upload the current visual selection
M.upload_selection = function()
  vim.cmd('normal! gv"0y')

  local selection = vim.fn.getreg("0")

  if selection == "" then
    print(MSG_PREFIX .. "No selection to upload!")
    return
  end

  local temp_file = os.tmpname()
  local f, err = io.open(temp_file, "w")
  if not f then
    print(MSG_PREFIX .. "Failed to open temporary file: " .. err)
    return
  end

  local success, write_err = f:write(selection)
  if not success then
    print(MSG_PREFIX .. "Failed to write to file: " .. write_err)
    f:close()
    return
  end

  if not f:close() then
    print(MSG_PREFIX .. "Failed to close the file.")
    return
  end

  M.upload_files({ temp_file })

  os.remove(temp_file)
end

-- Upload the last yank or delete content
M.upload_yank = function()
  local temp_file = os.tmpname()
  local yank_content = vim.fn.getreg('"')

  if yank_content == "" then
    print(MSG_PREFIX .. "Nothing in yank register!")
    return
  end

  local f, err = io.open(temp_file, "w")
  if not f then
    print(MSG_PREFIX .. "Failed to open temporary file: " .. err)
    return
  end

  local success, write_err = f:write(yank_content)
  if not success then
    print(MSG_PREFIX .. "Failed to write to file: " .. write_err)
    f:close()
    return
  end

  if not f:close() then
    print(MSG_PREFIX .. "Failed to close the file.")
    return
  end

  M.upload_files({ temp_file })

  os.remove(temp_file)
end

-- Upload the current file in buffer
M.upload_current_file = function()
  local file = vim.fn.expand("%:p")

  if file == "" then
    local temp_file = os.tmpname()
    vim.cmd("write " .. temp_file)
    file = temp_file
    print(MSG_PREFIX .. "Buffer is unsaved. Uploaded temporary file: " .. temp_file)
  end

  if vim.fn.filereadable(file) == 1 then
    M.upload_files({ file })
  else
    print(MSG_PREFIX .. "No file to upload!")
  end
end

-- Upload the current file under cursor on Oil.nvim
M.upload_oil_file = function()
  if vim.bo.filetype ~= "oil" then
    print(MSG_PREFIX .. "Not in an oil.nvim window!")
    return
  end

  local oil = require("oil")

  local entry = oil.get_cursor_entry()

  if not entry then
    print(MSG_PREFIX .. "No file under cursor in oil.nvim!")
    return
  end

  local file_path = oil.get_current_dir() .. "/" .. entry.name

  M.upload_files({ file_path })
end

-- Provide a function to setup the plugin
M.setup = function(opts)
  opts = opts or {}

  if opts.base_url then
    M.set_base_url(opts.base_url)
  else
    print(MSG_PREFIX .. "Warning: No base URL provided in setup!")
  end

  local use_default_keymaps = opts.use_default_keymaps == nil or opts.use_default_keymaps

  if use_default_keymaps then
    vim.api.nvim_set_keymap(
      "n",
      "<leader>0f",
      ':lua require("nup").upload_current_file()<CR>',
      { noremap = true, silent = true, desc = "Upload the current file" }
    )
    vim.api.nvim_set_keymap(
      "v",
      "<leader>0s",
      ':lua require("nup").upload_selection()<CR>',
      { noremap = true, silent = true, desc = "Upload the visual selection" }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<leader>0y",
      ':lua require("nup").upload_yank()<CR>',
      { noremap = true, silent = true, desc = "Upload the last yank content" }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<leader>0o",
      ':lua require("nup").upload_oil_file()<CR>',
      { noremap = true, silent = true, desc = "Upload a file from oil.nvim" }
    )
  end
end

return M
