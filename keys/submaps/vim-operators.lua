-- keys/submaps/vim-operators.lua
-- DELETE, CHANGE, YANK operators with nested I/A/G sub-submaps

local Submap = require("lib.submap") ---@class HyprVimSubmap
local vim = require("vim") ---@class Vim
local motion = vim.motion
local count = vim.count
local reg = vim.registers
local Hypr = require("hypr") ---@class HyprVimHyprland
local common = require("keys.submaps.common")

local send = Hypr.send

local footer = common.footer()

-- Selection recipes live in vim/lib/motion/shortcuts.lua (SELECT table).
-- The AROUND submaps reuse the inner objects, so aw/ap currently behave like
-- iw/ip; true around-objects would need trailing-whitespace handling.
local SEL = motion.shortcuts.SELECT

--- Build and register the I/A/G sub-submaps for one operator.
--- @param op_name  string  parent submap name (e.g. "DELETE")
--- @param on_word  fun()   action for word text objects
--- @param on_para  fun()   action for paragraph text objects
--- @param on_first fun()   action for first-line goto
--- @param on_last  fun()   action for last-line goto
local function make_sub_submaps(op_name, on_word, on_para, on_first, on_last)
  local text_obj_rows = function()
    -- stylua: ignore start
    local rows = {
      { "w",         function() motion.send_sequence(SEL.inner_word) on_word() end, "Word" },
      { "SHIFT + w", function() motion.send_sequence(SEL.inner_word) on_word() end },
      { "p",         function() motion.send_sequence(SEL.inner_para) on_para() end, "Paragraph" },
      { "SHIFT + p", function() motion.send_sequence(SEL.inner_para) on_para() end },
    }
    -- stylua: ignore end
    for _, row in ipairs(footer) do
      table.insert(rows, row)
    end
    return rows
  end

  Submap.define({
    name = op_name .. "-INSIDE",
    operator = true,
    escape = "NORMAL",
    back = op_name,
    catchall = "stay",
    binds = text_obj_rows(),
  }).setup()

  Submap.define({
    name = op_name .. "-AROUND",
    operator = true,
    escape = "NORMAL",
    back = op_name,
    catchall = "stay",
    binds = text_obj_rows(),
  }).setup()

  Submap.define({
    name = op_name .. "-GOTO",
    operator = true,
    escape = "NORMAL",
    back = op_name,
    catchall = "stay",
    binds = function()
      local rows = {
        -- stylua: ignore start
        { "g",         function() motion.send_raw(SEL.first_line) on_first() end, "First line" },
        { "SHIFT + g", function() motion.send_raw(SEL.last_line) on_last()  end, "Last line"  },
        -- stylua: ignore end
      }
      for _, row in ipairs(footer) do
        table.insert(rows, row)
      end
      return rows
    end,
  }).setup()
end

-- ---------------------------------------------------------------------------
-- DELETE
-- ---------------------------------------------------------------------------

local function del(after)
  return function() reg.handle_delete(after) end
end

Submap.define({
  name = "DELETE",
  operator = true,
  escape = "NORMAL",
  back = "previous",
  catchall = "stay",
  binds = function()
    local rows = {
      -- stylua: ignore start
      { "w",         function() motion.send_raw(SEL.next_word, count.get()) del("NORMAL")() end, "Next word" },
      { "SHIFT + w", function() motion.send_raw(SEL.next_word, count.get()) del("NORMAL")() end },
      { "e",         function() motion.send_raw(SEL.next_word, count.get()) del("NORMAL")() end, "Next end of word" },
      { "SHIFT + e", function() motion.send_raw(SEL.next_word, count.get()) del("NORMAL")() end },
      { "b",         function() motion.send_raw(SEL.prev_word, count.get()) del("NORMAL")() end, "Prev word" },
      { "SHIFT + b", function() motion.send_raw(SEL.prev_word, count.get()) del("NORMAL")() end },
      { "d",         function() motion.send_sequence(SEL.line) del("NORMAL")() send("", "BackSpace") send("", "DOWN") end, "Delete line" },
      { "SHIFT + 4", function() count.clear() motion.send_raw(SEL.to_eol) del("NORMAL")() end, "End of line"   },
      { "SHIFT + 6", function() count.clear() motion.send_raw(SEL.to_bol) del("NORMAL")() end, "Start of line" },
      { "0",         function() count.clear() motion.send_raw(SEL.to_bol) del("NORMAL")() end, "Start of line" },
      { "m",         function() count.clear() vim.marks.enter_delete() end, "+Delete Mark" },
      { "i",         function() count.clear() Submap.enter("DELETE-INSIDE") end, "+Inner" },
      { "SHIFT + i", function() Submap.enter("DELETE-INSIDE") end },
      { "a",         function() count.clear() Submap.enter("DELETE-AROUND") end, "+Around" },
      { "SHIFT + a", function() Submap.enter("DELETE-AROUND") end },
      { "g",         function() count.clear() Submap.enter("DELETE-GOTO") end, "+Go" },
      -- stylua: ignore end
    }
    for _, row in ipairs(footer) do
      table.insert(rows, row)
    end
    return rows
  end,
}).setup()

make_sub_submaps("DELETE", del("NORMAL"), del("NORMAL"), del("NORMAL"), del("NORMAL"))

-- ---------------------------------------------------------------------------
-- CHANGE
-- ---------------------------------------------------------------------------

Submap.define({
  name = "CHANGE",
  operator = true,
  escape = "NORMAL",
  back = "previous",
  catchall = "stay",
  binds = function()
    local rows = {
      -- stylua: ignore start
      { "w",         function() motion.send_raw(SEL.next_word, count.get()) reg.handle_delete("INSERT") end, "Next word" },
      { "SHIFT + w", function() motion.send_sequence(SEL.word_end) reg.handle_delete("INSERT") end },
      { "e",         function() motion.send_sequence(SEL.word_end) reg.handle_delete("INSERT") end, "End of next word" },
      { "b",         function() motion.send_raw(SEL.prev_word, count.get()) reg.handle_delete("INSERT") end, "Prev word" },
      { "SHIFT + b", function() motion.send_raw(SEL.prev_word) reg.handle_delete("INSERT") end },
      { "c",         function() motion.send_sequence(SEL.line) reg.handle_delete("INSERT") end, "Change line" },
      { "SHIFT + 4", function() count.clear() motion.send_raw(SEL.to_eol) reg.handle_delete("INSERT") end, "End of line"   },
      { "SHIFT + 6", function() count.clear() motion.send_raw(SEL.to_bol) reg.handle_delete("INSERT") end, "Start of line" },
      { "0",         function() count.clear() motion.send_raw(SEL.to_bol) reg.handle_delete("INSERT") end, "Start of line" },
      { "SHIFT + g", function() count.clear() motion.send_raw(SEL.last_line) reg.handle_delete("INSERT") end, "Last line" },
      { "i",         function() count.clear() Submap.enter("CHANGE-INSIDE") end, "+Inner" },
      { "SHIFT + i", function() Submap.enter("CHANGE-INSIDE") end },
      { "a",         function() count.clear() Submap.enter("CHANGE-AROUND") end, "+Around" },
      { "SHIFT + a", function() Submap.enter("CHANGE-AROUND") end },
      { "g",         function() count.clear() Submap.enter("CHANGE-GOTO") end, "+Go" },
      -- stylua: ignore end
    }
    for _, row in ipairs(footer) do
      table.insert(rows, row)
    end
    return rows
  end,
}).setup()

make_sub_submaps("CHANGE", del("INSERT"), del("INSERT"), del("INSERT"), del("INSERT"))

-- ---------------------------------------------------------------------------
-- YANK
-- ---------------------------------------------------------------------------

-- collapse=false only for linewise yank, which positions the cursor itself.
local function yank(after, collapse)
  if collapse == nil then collapse = true end
  return function() reg.handle_yank("CTRL", "c", { return_mode = after, collapse = collapse }) end
end

Submap.define({
  name = "YANK",
  operator = true,
  escape = "NORMAL",
  back = "previous",
  catchall = "stay",
  binds = function()
    -- stylua: ignore start
    local rows = {
      { "w",         function() motion.send_raw(SEL.next_word, count.get()) yank("NORMAL")() end, "Next word" },
      { "e",         function() motion.send_raw(SEL.next_word, count.get()) yank("NORMAL")() end, "Next end of word" },
      { "b",         function() motion.send_raw(SEL.prev_word, count.get()) yank("NORMAL")() end, "Prev word" },
      { "SHIFT + w", function() motion.send_raw(SEL.next_word, count.get()) yank("NORMAL")() end },
      { "SHIFT + e", function() motion.send_raw(SEL.next_word, count.get()) yank("NORMAL")() end },
      { "SHIFT + b", function() motion.send_raw(SEL.prev_word, count.get()) yank("NORMAL")() end },
      { "y",         function() motion.send_sequence(SEL.line) yank("NORMAL", false)() send("", "DOWN") end, "Yank line" },
      { "SHIFT + 4", function() count.clear() motion.send_raw(SEL.to_eol) yank("NORMAL")() end, "End of line"   },
      { "0",         function() count.clear() motion.send_raw(SEL.to_bol) yank("NORMAL")() end, "Start of line" },
      { "SHIFT + 6", function() count.clear() motion.send_raw(SEL.to_bol) yank("NORMAL")() end, "Start of line" },
      { "SHIFT + g", function() motion.send_raw(SEL.last_line) yank("NORMAL")() end, "Last line" },
      { "i",         function() count.clear() Submap.enter("YANK-INSIDE") end, "+Inner" },
      { "SHIFT + i", function() Submap.enter("YANK-INSIDE") end },
      { "a",         function() count.clear() Submap.enter("YANK-AROUND") end, "+Around" },
      { "SHIFT + a", function() Submap.enter("YANK-AROUND") end },
      { "g",         function() count.clear() Submap.enter("YANK-GOTO") end, "+Go" },
      -- stylua: ignore end
    }
    for _, row in ipairs(footer) do
      table.insert(rows, row)
    end
    return rows
  end,
}).setup()

make_sub_submaps("YANK", yank("NORMAL"), yank("NORMAL"), yank("NORMAL"), yank("NORMAL"))
