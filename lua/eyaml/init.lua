-- Load the module
require("eyaml")

-- Optional: Configure settings
vim.g.eyaml_encryption_method = "pkcs7" -- or 'gpg'
-- If using GPG, you might want to set:
-- vim.g.eyaml_gpg_recipients = 'your-recipient'
-- vim.g.eyaml_gpg_recipients_file = 'path/to/recipients'
-- vim.g.eyaml_gpg_always_trust = 1
