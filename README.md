# Eyaml.nvim

A Neovim plugin for encrypting and decrypting values using [hiera-eyaml](https://github.com/voxpupuli/hiera-eyaml). This plugin allows you to easily encrypt/decrypt values directly from your editor, which is particularly useful when working with Puppet YAML files.

## Prerequisites

- Neovim >= 0.5.0
- [hiera-eyaml](https://github.com/voxpupuli/hiera-eyaml) installed and configured
- PKCS7 keys or GPG setup (depending on your encryption method)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "your-username/eyaml.nvim",
    event = { "BufReadPre *.yaml", "BufReadPre *.yml" },
    config = function()
        require("eyaml")
    end
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
    "your-username/eyaml.nvim",
    config = function()
        require("eyaml")
    end
}
```

## Configuration

Add to your `init.lua`:

```lua
-- Basic setup with default settings
require('eyaml')

-- Or with custom configuration
vim.g.eyaml_encryption_method = 'pkcs7'  -- Default: 'pkcs7', Alternative: 'gpg'

-- GPG specific settings (optional)
vim.g.eyaml_gpg_recipients = 'user@example.com'  -- GPG recipient
-- OR
vim.g.eyaml_gpg_recipients_file = 'path/to/recipients'  -- Path to recipients file
vim.g.eyaml_gpg_always_trust = 1  -- Trust GPG keys without verification
```

## Usage

### Commands

- Visual select text and use:
  - `:EyamlEncrypt` - Encrypt selected text
  - `:EyamlDecrypt` - Decrypt selected text

### Default Keymaps

The plugin comes with default keymaps (in visual mode):

- `<leader>ee` - Encrypt selection
- `<leader>ed` - Decrypt selection

### Custom Keymaps

To set your own keymaps:

```lua
vim.keymap.set('v', '<your-key>', ':EyamlEncrypt<CR>', { silent = true })
vim.keymap.set('v', '<your-key>', ':EyamlDecrypt<CR>', { silent = true })
```

## Examples

```yaml
# Example YAML file
---
mysql::root_password: unencrypted_password

# 1. Visual select 'unencrypted_password'
# 2. Press <leader>ee or type :EyamlEncrypt
# Result:
mysql::root_password: ENC[PKCS7,MIIBiQYJKoZIhvcNAQcDoIIBejCCAXYCAQAxggEh...]

# To decrypt:
# 1. Visual select the entire ENC[...] string
# 2. Press <leader>ed or type :EyamlDecrypt
```

## Key Setup

### PKCS7 Keys

Make sure your PKCS7 keys are in one of these locations:

```
/etc/puppetlabs/code/keys/private_key.pkcs7.pem
/etc/puppetlabs/code/keys/public_key.pkcs7.pem
```

or

```
~/.eyaml/private_key.pkcs7.pem
~/.eyaml/public_key.pkcs7.pem
```

### GPG Setup

If using GPG encryption:

1. Ensure you have GPG keys generated
2. Configure recipients in one of two ways:
   - Set `vim.g.eyaml_gpg_recipients`
   - Create a recipients file and set `vim.g.eyaml_gpg_recipients_file`

## Troubleshooting

### Common Issues

1. "No encrypted lines returned"

   - Check if eyaml is properly installed
   - Verify key permissions and locations

2. "Couldn't find recipient file"

   - Check if your GPG recipients file exists
   - Verify the path in `eyaml_gpg_recipients_file`

3. Encryption/Decryption fails
   - Ensure eyaml is in your PATH
   - Check key permissions
   - Verify key locations
   - Run `eyaml encrypt --test` to verify setup

### Debug Commands

Test your eyaml setup:

```bash
# Test encryption
echo "test" | eyaml encrypt --stdin

# Test decryption
echo "ENC[PKCS7,...]" | eyaml decrypt --stdin
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details.

