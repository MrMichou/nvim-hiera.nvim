-- In your init.lua or ~/.config/nvim/lua/eyaml.lua

local M = {}

local function eyaml(subcommand)
	-- Yank current or last selection to register x
	vim.cmd('normal! gv"xy')
	local reg_x = vim.fn.getreg("x")

	-- Build eyaml command
	local eyaml_cmd = "eyaml"
	local shellcmd = string.format("%s %s --stdin 2>/dev/null", eyaml_cmd, subcommand)

	-- Execute command
	local output = vim.fn.system(shellcmd, reg_x)

	if vim.v.shell_error == 0 then
		-- Strip newlines from output
		output = string.gsub(output, "[\r\n]*$", "")

		if string.match(subcommand, "^encrypt") then
			-- Only match ENC[.*] lines
			output = string.match(output, "ENC%[.*%]")
			if not string.match(output or "", "ENC%[.*%]") then
				vim.api.nvim_err_writeln("[eyaml] No encrypted lines returned")
				return
			end
		end

		-- Set register and paste
		vim.fn.setreg("x", output)
		vim.cmd('normal! gv"xp')
	else
		-- Error handling: run command again without stderr stripped
		shellcmd = string.format("%s %s --stdin", eyaml_cmd, subcommand)
		output = vim.fn.system(shellcmd, reg_x)
		vim.api.nvim_err_writeln("[eyaml] " .. output)
	end
end

function M.encrypt()
	-- Initialize variables
	local eyaml_args = ""

	-- Default to pkcs7 if not set
	vim.g.eyaml_encryption_method = vim.g.eyaml_encryption_method or "pkcs7"

	if vim.g.eyaml_encryption_method == "gpg" then
		if vim.g.eyaml_gpg_recipients then
			eyaml_args = " --gpg-recipients=" .. vim.g.eyaml_gpg_recipients
		else
			local recipients_file

			if vim.g.eyaml_gpg_recipients_file then
				recipients_file = vim.fn.findfile(vim.g.eyaml_gpg_recipients_file, "*;/")
			else
				recipients_file = vim.fn.findfile("hiera-eyaml-gpg.recipients", "*;/")
			end

			if recipients_file == "" then
				error(
					string.format(
						"[eyaml] Couldn't find recipient file %s",
						vim.g.eyaml_gpg_recipients_file or "hiera-eyaml-gpg.recipients"
					)
				)
			end

			eyaml_args = " --gpg-recipients-file=" .. recipients_file
		end

		if vim.g.eyaml_gpg_always_trust == 1 then
			eyaml_args = eyaml_args .. " --gpg-always-trust"
		end
	end

	eyaml_args = eyaml_args .. " -n " .. vim.g.eyaml_encryption_method
	eyaml("encrypt -o string " .. eyaml_args)
end

function M.decrypt()
	eyaml("decrypt")
end

-- Create commands
vim.api.nvim_create_user_command("EyamlEncrypt", M.encrypt, { range = true })
vim.api.nvim_create_user_command("EyamlDecrypt", M.decrypt, { range = true })

-- Optional: Add keymaps
vim.keymap.set("v", "<leader>ee", ":EyamlEncrypt<CR>", { silent = true, desc = "Eyaml encrypt" })
vim.keymap.set("v", "<leader>ed", ":EyamlDecrypt<CR>", { silent = true, desc = "Eyaml decrypt" })

return M
