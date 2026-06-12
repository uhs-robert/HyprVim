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

--- Build and register the I/A/G sub-submaps for one operator.
--- @param op_name  string  parent submap name (e.g. "DELETE")
--- @param on_word  fun()   action for word text objects
--- @param on_para  fun()   action for paragraph text objects
--- @param on_first fun()   action for first-line goto
--- @param on_last  fun()   action for last-line goto
local function make_sub_submaps(op_name, on_word, on_para, on_first, on_last)
  local text_obj_rows = function(word_seq, para_seq, word_action, para_action)
    -- stylua: ignore start
    local rows = {
      { "w",         function() motion.send_sequence(word_seq) word_action() end, "Word" },
      { "SHIFT + w", function() motion.send_sequence(word_seq) word_action() end },
      { "p",         function() motion.send_sequence(para_seq) para_action() end, "Paragraph" },
      { "SHIFT + p", function() motion.send_sequence(para_seq) para_action() end },
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
    binds = text_obj_rows(
      { { "CTRL", "LEFT" }, { "CTRL SHIFT", "RIGHT" } },
      { { "CTRL", "UP" }, { "CTRL SHIFT", "DOWN" } },
      on_word,
      on_para
    ),
  }).setup()

  Submap.define({
    name = op_name .. "-AROUND",
    operator = true,
    escape = "NORMAL",
    back = op_name,
    catchall = "stay",
    binds = text_obj_rows(
      { { "CTRL", "LEFT" }, { "CTRL SHIFT", "RIGHT" } },
      { { "CTRL", "UP" }, { "CTRL SHIFT", "DOWN" } },
      on_word,
      on_para
    ),
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
        { "g",         function() motion.send_raw({ "CTRL SHIFT", "HOME" }, 1) on_first() end, "First line" },
        { "SHIFT + g", function() motion.send_raw({ "CTRL SHIFT", "END" },  1) on_last()  end, "Last line"  },
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
      { "w",         function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) del("NORMAL")() end, "Next word" },
      { "SHIFT + w", function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) del("NORMAL")() end },
      { "e",         function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) del("NORMAL")() end, "Next end of word" },
      { "SHIFT + e", function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) del("NORMAL")() end },
      { "b",         function() motion.send_raw({ "CTRL SHIFT", "LEFT" },  count.get()) del("NORMAL")() end, "Prev word" },
      { "SHIFT + b", function() motion.send_raw({ "CTRL SHIFT", "LEFT" },  count.get()) del("NORMAL")() end },
      { "d",         function() motion.send_sequence({ { "", "HOME" }, { "SHIFT", "End" } }) del("NORMAL")() send("", "BackSpace") send("", "DOWN") end, "Delete line" },
      { "SHIFT + 4", function() count.clear() motion.send_raw({ "SHIFT", "End" },  1) del("NORMAL")() end, "End of line"   },
      { "SHIFT + 6", function() count.clear() motion.send_raw({ "SHIFT", "Home" }, 1) del("NORMAL")() end, "Start of line" },
      { "0",         function() count.clear() motion.send_raw({ "SHIFT", "Home" }, 1) del("NORMAL")() end, "Start of line" },
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

make_sub_submaps(
  "DELETE",
  function() del("NORMAL")() end,
  function() del("NORMAL")() end,
  function() del("NORMAL")() end,
  function() del("NORMAL")() end
)

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
      { "w",         function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) reg.handle_delete("INSERT") end, "Next word" },
      { "SHIFT + w", function() motion.send_sequence({ { "CTRL SHIFT", "RIGHT" }, { "SHIFT", "Left" } }) reg.handle_delete("INSERT") end },
      { "e",         function() motion.send_sequence({ { "CTRL SHIFT", "RIGHT" }, { "SHIFT", "Left" } }) reg.handle_delete("INSERT") end, "End of next word" },
      { "b",         function() motion.send_raw({ "CTRL SHIFT", "LEFT" }, count.get()) reg.handle_delete("INSERT") end, "Prev word" },
      { "SHIFT + b", function() motion.send_sequence({ { "CTRL SHIFT", "LEFT" } }) reg.handle_delete("INSERT") end },
      { "c",         function() motion.send_sequence({ { "", "HOME" }, { "SHIFT", "End" } }) reg.handle_delete("INSERT") end, "Change line" },
      { "SHIFT + 4", function() count.clear() motion.send_sequence({ { "SHIFT", "End" } })  reg.handle_delete("INSERT") end, "End of line"   },
      { "SHIFT + 6", function() count.clear() motion.send_sequence({ { "SHIFT", "Home" } }) reg.handle_delete("INSERT") end, "Start of line" },
      { "0",         function() count.clear() motion.send_sequence({ { "SHIFT", "Home" } }) reg.handle_delete("INSERT") end, "Start of line" },
      { "SHIFT + g", function() count.clear() motion.send_raw({ "CTRL SHIFT", "END" }, 1) reg.handle_delete("INSERT") end, "Last line" },
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

make_sub_submaps("CHANGE", function()
  motion.send_sequence({ { "CTRL", "LEFT" }, { "CTRL SHIFT", "RIGHT" } })
  reg.handle_delete("INSERT")
end, function()
  motion.send_sequence({ { "CTRL", "UP" }, { "CTRL SHIFT", "DOWN" } })
  reg.handle_delete("INSERT")
end, function()
  motion.send_raw({ "CTRL SHIFT", "HOME" }, 1)
  reg.handle_delete("INSERT")
end, function()
  motion.send_raw({ "CTRL SHIFT", "END" }, 1)
  reg.handle_delete("INSERT")
end)

-- ---------------------------------------------------------------------------
-- YANK
-- ---------------------------------------------------------------------------

local function yank(after)
  return function() reg.handle_yank("CTRL", "c", after) end
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
      { "w",         function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) yank("NORMAL")() end, "Next word" },
      { "e",         function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) yank("NORMAL")() end, "Next end of word" },
      { "b",         function() motion.send_raw({ "CTRL SHIFT", "LEFT" },  count.get()) yank("NORMAL")() end, "Prev word" },
      { "SHIFT + w", function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) yank("NORMAL")() end },
      { "SHIFT + e", function() motion.send_raw({ "CTRL SHIFT", "RIGHT" }, count.get()) yank("NORMAL")() end },
      { "SHIFT + b", function() motion.send_raw({ "CTRL SHIFT", "LEFT" },  count.get()) yank("NORMAL")() end },
      { "y",         function() motion.send_sequence({ { "", "HOME" }, { "SHIFT", "End" } }) yank("NORMAL")() send("", "DOWN") end, "Yank line" },
      { "SHIFT + 4", function() count.clear() motion.send_raw({ "SHIFT", "End" },  1) yank("NORMAL")() end, "End of line"   },
      { "0",         function() count.clear() motion.send_raw({ "SHIFT", "Home" }, 1) yank("NORMAL")() end, "Start of line" },
      { "SHIFT + 6", function() count.clear() motion.send_raw({ "SHIFT", "Home" }, 1) yank("NORMAL")() end, "Start of line" },
      { "SHIFT + g", function() motion.send_raw({ "CTRL SHIFT", "END" }, 1) yank("NORMAL")() end, "Last line" },
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

make_sub_submaps("YANK", function()
  motion.send_sequence({ { "CTRL", "LEFT" }, { "CTRL SHIFT", "RIGHT" } })
  yank("NORMAL")()
end, function()
  motion.send_sequence({ { "CTRL", "UP" }, { "CTRL SHIFT", "DOWN" } })
  yank("NORMAL")()
end, function()
  motion.send_raw({ "CTRL SHIFT", "HOME" }, 1)
  yank("NORMAL")()
end, function()
  motion.send_raw({ "CTRL SHIFT", "END" }, 1)
  yank("NORMAL")()
end)
