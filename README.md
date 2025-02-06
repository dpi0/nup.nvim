# nvim-0x0

A simple Neovim plugin to upload files, yanks, and selections to
[0x0.st](https://0x0.st).

## Obligatory Demos

- Uploading current opened file:
![demo-file](doc/demo_file.webm)

- Uploding visual selection:
![demo-file](doc/demo_visual_selection.webm)

- Uploading last yanked/deleted text:
![demo-file](doc/demo_yank.webm)

- Uploading a file selected in oil.nvim:
![demo-file](doc/demo_oil.webm)

## Installation

### Using lazy.nvim

Add the following to your `lazy.nvim` configuration:

```lua
require('lazy').setup({
  {
    "LionyxML/nvim-0x0",
    opts = {
      -- base_url = "https://<your-0x0-instance>,/", -- only needed if you host your own 0x0 instance
      use_default_keymaps = true,                    -- Set to false if you want to define your own keymaps
    }
  }
})
```

## Usage

By default, the following keymaps are available:

- `<leader>0f` - Upload the current file
- `<leader>0s` - Upload the current visual selection
- `<leader>0y` - Upload the last yank or delete content 
- `<leader>0o` - Upload a file selected in oil.nvim

If `use_default_keymaps = false`, you can define your own mappings, like:

```lua
vim.keymap.set('n', '<leader>uf', require("nvim-0x0").upload_current_file, { desc = "Upload current file" })
vim.keymap.set('v', '<leader>us', require("nvim-0x0").upload_selection, { desc = "Upload selection" })
vim.keymap.set('n', '<leader>uy', require("nvim-0x0").upload_yank, { desc = "Upload yank" })
vim.keymap.set('n', '<leader>uo', require("nvim-0x0").upload_oil_file, { desc = "Upload oil.nvim file" })
```

If you'd like to host your own instance of 0x0, set `base_url =
"https://0x0.st/"`.


## Contributing

Contributions are welcome! Please follow these steps:  

1. Fork the repository.  
2. Create a new branch for your changes.  
3. Make your modifications and ensure they follow the project's style.  
4. Submit a pull request with a clear description of your changes.  

## License

This project is licensed under the GPL-2.0. See the [LICENSE](LICENSE) file for
details.







