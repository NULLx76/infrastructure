local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local obsidian_commands = require("obsidian.commands").commands
local results = {}
for key, _ in pairs(obsidian_commands) do
  table.insert(results, string.sub(key, 9))
end

Local = 100
local Local = 3
print(Local)

local obsidian_picker = function(opts)
  opts = opts or require("telescope.themes").get_dropdown{}
  pickers.new(opts, {
    prompt_title = "Obsidian",
    finder = finders.new_table {
      results = results,
      -- entry_maker = function(entry)
      --   return {
      --     value = entry,
      --     display = entry[1],
      --     ordinal = entry[1],
      --   }
      -- end
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.cmd(':Obsidian' .. selection[1])
      end)
      return true
    end,
  }):find()
end

-- obsidian_picker()

return {
  obsidian_picker = obsidian_picker
}

