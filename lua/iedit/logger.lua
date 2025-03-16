local M = {}

local logger

function M.debug(msg)
  if not logger then
    pcall(function()
      logger = require('logger').derive('iedit')
      logger.debug(msg)
    end)
  else
    logger.debug(msg)
  end
end

return M
