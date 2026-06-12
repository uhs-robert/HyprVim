--- @class HyprVimUtils
local Utils = {}

--- Returns true if t is a sequence (array-like: all integer keys 1..n).
local function is_array(t)
  local n = 0
  for _ in pairs(t) do
    n = n + 1
  end
  return n == #t and n > 0
end

--- Deep-merge one or more source tables into target. Arrays are replaced, not merged.
--- @param target table
--- @param ... table
--- @return table
Utils.deep_extend = function(target, ...)
  for _, source in ipairs({ ... }) do
    for k, v in pairs(source) do
      if type(v) == "table" and type(target[k]) == "table" and not is_array(v) then
        Utils.deep_extend(target[k], v)
      else
        target[k] = v
      end
    end
  end
  return target
end

--- Writes content to a file, creating or overwriting it. Returns true on success.
--- @param path string
--- @param content string|number
--- @return boolean
Utils.write_file = function(path, content)
  local f = io.open(path, "w")
  if not f then return false end
  f:write(tostring(content) .. "\n")
  f:close()
  return true
end

--- Reads a file and returns its content with trailing whitespace stripped, or "" on failure.
--- @param path string
--- @return string
Utils.read_file = function(path)
  local f = io.open(path, "r")
  if not f then return "" end
  local s = f:read("*a"):gsub("%s+$", "")
  f:close()
  return s
end

--- Reads a file's raw content, or "" when unreadable. With limit, reads only the
--- first limit bytes and collapses whitespace runs to single spaces (one-line preview).
--- @param path string
--- @param limit? integer
--- @return string
Utils.read_head = function(path, limit)
  local f = io.open(path, "r")
  if not f then return "" end
  local s = f:read(limit or "*a") or ""
  f:close()
  if limit then s = s:gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "") end
  return s
end

--- Returns true if the file at path exists and is readable.
--- @param path string
--- @return boolean
Utils.file_exists = function(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

--- Runs cmd in a shell and returns stdout with trailing whitespace stripped.
--- @param cmd string
--- @return string
Utils.pread = function(cmd)
  local p = io.popen(cmd)
  if not p then return "" end
  local s = p:read("*a"):gsub("%s+$", "")
  p:close()
  return s
end

--- Single-quotes s for safe shell interpolation.
--- @param s string|number
--- @return string
Utils.sh_escape = function(s) return "'" .. tostring(s):gsub("'", "'\\''") .. "'" end

--- Escapes s for embedding in a JSON string literal. Quotes, backslashes, and braces
--- become \u00XX so pattern-based readers ('"[^"]*"', '%b{}') stay safe too.
--- @param s string
--- @return string
Utils.json_escape = function(s)
  return (s:gsub('[%c"\\{}]', function(c) return string.format("\\u%04x", c:byte()) end))
end

--- Decodes \uXXXX escapes (as emitted by json_escape) back to bytes.
--- @param s string
--- @return string
Utils.json_unescape = function(s)
  return (s:gsub("\\u(%x%x%x%x)", function(h)
    local n = tonumber(h, 16)
    return n < 256 and string.char(n) or nil
  end))
end

return Utils
