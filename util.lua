local util = {}

-- Return all tiles in the specified radius from position, sorted by closest first.
function util.get_tiles_near(position, radius)
  local area = {
    left_top = {position.x - radius, position.y - radius},
    right_bottom = {position.x + radius, position.y + radius}
  }

  local tiles = game.surfaces[1].find_tiles_filtered {area = area}

  table.sort(
    tiles,
    function(a, b)
      return util.sq_distance(a.position, position) < util.sq_distance(b.position, position)
    end
  )

  local result = {}

  local sq_radius = math.pow(radius, 2)

  for _, tile in pairs(tiles) do
    local distance = util.sq_distance(tile.position, position)
    if distance <= sq_radius then
      table.insert(result, tile)
    else
      break
    end
  end

  return result
end

-- Sqaured distance, fast, for distance comparisons.
function util.sq_distance(a, b)
  return math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2)
end

-- Distance between 2 positions.
function util.distance(a, b)
  return math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2))
end

-- Check for presence of a value `val` in table `tab`.
function util.has_value(tab, val)
  for index, value in ipairs(tab) do
    if value == val then
      return true
    end
  end

  return false
end

return util
