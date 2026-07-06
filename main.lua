local EXTENSION_VERSION = "0.1.0"
local RELEASE_REPO = "rauldeavila/old-tv-preview"
local DEFAULT_PRESET_ID = "july_teste_01"
local DEFAULT_SCALE = 12
local DEFAULT_MARGIN = 14
local MIN_SCALE = 2
local MAX_SCALE = 32
local MAX_RENDER_PIXELS = 2300000
local COMPARISON_GAP = 18

local pluginRef = nil

local pc = app.pixelColor

local PRESETS = {
  {
    id = "july_teste_01",
    name = "July Test 01 (LIGHTWARD)",
    backgroundRed = 0.055,
    backgroundGreen = 0.062,
    backgroundBlue = 0.055,
    saturation = 1.52,
    lumaBandwidth = 0.55,
    iBlur = 3.35,
    qBlur = 5.65,
    chromaDelayX = 1.45,
    lumaIntoChroma = 0.55,
    chromaIntoLuma = 0.32,
    phaseError = 0.26,
    hue = 0.07,
    signalNoise = 0.006,
    chromaNoise = 0.010,
    ghostStrength1 = 0.075,
    ghostOffset1 = 0.34,
    ghostStrength2 = 0.030,
    ghostOffset2 = 0.92,
    cellApertureX = 0.96,
    cellApertureY = 0.84,
    cellRoundness = 1.65,
    cellMatrixDarkness = 0.12,
    subpixelApertureX = 0.86,
    subpixelApertureY = 0.94,
    activeThreshold = 0.028,
    neighborBleed = 0.20,
    matrixGlowResistance = 0.62,
    scanlineStrength = 0.40,
    scanlinePitch = 4.50,
    maskBrightness = 1.62,
    redOffsetX = -0.85,
    redOffsetY = -0.10,
    blueOffsetX = 0.92,
    blueOffsetY = 0.08,
    smallGlow = 0.42,
    largeGlow = 0.52,
    halationStrength = 0.26,
    bloomThreshold = 0.20,
    whiteBloom = 0.78,
    blueBloom = 0.92,
    greenBloom = 0.92,
    redBloom = 1.10,
    contrast = 1.16,
    gamma = 1.05,
    finalSaturation = 1.20,
    temperature = 0.12,
    blackFade = 0.18,
    blackWarmth = 0.72,
    backdropNoise = 0.18,
    backdropStrips = 0.34,
    stripScale = 1.00,
    vignette = 0.42,
    noise = 0.008
  },
  {
    id = "reference_match",
    name = "Reference Match",
    backgroundRed = 0.050,
    backgroundGreen = 0.058,
    backgroundBlue = 0.052,
    saturation = 1.25,
    lumaBandwidth = 0.75,
    iBlur = 2.0,
    qBlur = 3.5,
    chromaDelayX = 0.95,
    lumaIntoChroma = 0.16,
    chromaIntoLuma = 0.06,
    phaseError = 0.12,
    hue = -0.04,
    signalNoise = 0.004,
    chromaNoise = 0.006,
    ghostStrength1 = 0.045,
    ghostOffset1 = 0.26,
    ghostStrength2 = 0.018,
    ghostOffset2 = 0.72,
    cellApertureX = 0.94,
    cellApertureY = 0.82,
    cellRoundness = 2.10,
    cellMatrixDarkness = 0.18,
    subpixelApertureX = 0.78,
    subpixelApertureY = 0.90,
    activeThreshold = 0.026,
    neighborBleed = 0.16,
    matrixGlowResistance = 0.66,
    scanlineStrength = 0.40,
    scanlinePitch = 4.50,
    maskBrightness = 1.28,
    redOffsetX = -0.62,
    redOffsetY = -0.05,
    blueOffsetX = 0.76,
    blueOffsetY = 0.04,
    smallGlow = 0.22,
    largeGlow = 0.36,
    halationStrength = 0.16,
    bloomThreshold = 0.34,
    whiteBloom = 0.72,
    blueBloom = 1.24,
    greenBloom = 0.82,
    redBloom = 0.68,
    contrast = 1.10,
    gamma = 1.08,
    finalSaturation = 1.12,
    temperature = 0.02,
    blackFade = 0.16,
    blackWarmth = 0.60,
    backdropNoise = 0.14,
    backdropStrips = 0.26,
    stripScale = 1.00,
    vignette = 0.44,
    noise = 0.006
  },
  {
    id = "color_leak",
    name = "Color Leak",
    backgroundRed = 0.055,
    backgroundGreen = 0.062,
    backgroundBlue = 0.055,
    saturation = 1.86,
    lumaBandwidth = 0.55,
    iBlur = 3.35,
    qBlur = 5.65,
    chromaDelayX = 0.44,
    lumaIntoChroma = 0.76,
    chromaIntoLuma = 0.27,
    phaseError = -0.18,
    hue = 0.07,
    signalNoise = 0.006,
    chromaNoise = 0.021,
    ghostStrength1 = 0.075,
    ghostOffset1 = 0.34,
    ghostStrength2 = 0.030,
    ghostOffset2 = 0.92,
    cellApertureX = 0.97,
    cellApertureY = 0.89,
    cellRoundness = 1.65,
    cellMatrixDarkness = 0.38,
    subpixelApertureX = 0.42,
    subpixelApertureY = 0.94,
    activeThreshold = 0.028,
    neighborBleed = 0.54,
    matrixGlowResistance = 0.62,
    scanlineStrength = 0.50,
    scanlinePitch = 4.50,
    maskBrightness = 1.50,
    redOffsetX = -0.85,
    redOffsetY = -0.10,
    blueOffsetX = 0.92,
    blueOffsetY = 0.08,
    smallGlow = 0.58,
    largeGlow = 0.46,
    halationStrength = 0.26,
    bloomThreshold = 0.20,
    whiteBloom = 0.78,
    blueBloom = 1.12,
    greenBloom = 0.85,
    redBloom = 0.80,
    contrast = 1.16,
    gamma = 1.05,
    finalSaturation = 1.42,
    temperature = 0.12,
    blackFade = 0.18,
    blackWarmth = 0.72,
    backdropNoise = 0.18,
    backdropStrips = 0.34,
    stripScale = 1.00,
    vignette = 0.42,
    noise = 0.008
  }
}

local function clamp(value, minValue, maxValue)
  value = tonumber(value) or minValue
  if value < minValue then
    return minValue
  end
  if value > maxValue then
    return maxValue
  end
  return value
end

local function clampInt(value, fallback, minValue, maxValue)
  value = math.floor(tonumber(value) or fallback)
  return math.floor(clamp(value, minValue, maxValue))
end

local function saturate(value)
  return clamp(value, 0.0, 1.0)
end

local function lerp(a, b, t)
  return a + (b - a) * t
end

local function smoothstep(edge0, edge1, value)
  local t = saturate((value - edge0) / (edge1 - edge0))
  return t * t * (3.0 - 2.0 * t)
end

local function hash01(x, y, seed)
  local v = math.sin((x * 12.9898) + (y * 78.233) + (seed * 37.719)) * 43758.5453
  return v - math.floor(v)
end

local function shellQuote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function readCommand(command)
  local handle = io.popen(command)
  if not handle then
    return nil
  end

  local output = handle:read("*a")
  handle:close()
  return output
end

local function parseVersion(version)
  local major, minor, patch = tostring(version):match("v?(%d+)%.(%d+)%.(%d+)")
  return tonumber(major) or 0, tonumber(minor) or 0, tonumber(patch) or 0
end

local function isVersionNewer(remote, localVersion)
  local ra, rb, rc = parseVersion(remote)
  local la, lb, lc = parseVersion(localVersion)

  if ra ~= la then
    return ra > la
  elseif rb ~= lb then
    return rb > lb
  end

  return rc > lc
end

local function jsonStringField(text, field)
  local pattern = '"' .. field .. '"%s*:%s*"([^"]+)"'
  return text:match(pattern)
end

local function latestReleaseInfo(response)
  local tag = jsonStringField(response, "tag_name") or jsonStringField(response, "name")
  local downloadUrl = nil

  for block in response:gmatch("{.-}") do
    local name = jsonStringField(block, "name")
    local url = jsonStringField(block, "browser_download_url")

    if name and url and name:match("%.aseprite%-extension$") then
      downloadUrl = url:gsub("\\/", "/")
      break
    end
  end

  if not downloadUrl then
    downloadUrl = response:match('"browser_download_url"%s*:%s*"([^"]+%.aseprite%-extension)"')
    if downloadUrl then
      downloadUrl = downloadUrl:gsub("\\/", "/")
    end
  end

  return tag, downloadUrl
end

local function openFile(path)
  os.execute("open " .. shellQuote(path))
end

local function checkForUpdates()
  local apiUrl = "https://api.github.com/repos/" .. RELEASE_REPO .. "/releases/latest"
  local command = "curl -fsSL -H " ..
    shellQuote("Accept: application/vnd.github+json") .. " -H " ..
    shellQuote("User-Agent: old-tv-preview-aseprite") .. " " ..
    shellQuote(apiUrl)
  local response = readCommand(command)

  if not response or response == "" then
    app.alert {
      title = "Old TV Preview",
      text = "Could not check GitHub releases."
    }
    return
  end

  local tag, downloadUrl = latestReleaseInfo(response)
  if not tag or tag == "" then
    app.alert {
      title = "Old TV Preview",
      text = "Could not parse GitHub release data."
    }
    return
  end

  if not isVersionNewer(tag, EXTENSION_VERSION) then
    app.alert {
      title = "Old TV Preview",
      text = "Old TV Preview is up to date.\nInstalled: v" .. EXTENSION_VERSION
    }
    return
  end

  if not downloadUrl then
    app.alert {
      title = "Old TV Preview",
      text = "A newer release exists (" .. tag .. "), but no .aseprite-extension asset was found."
    }
    return
  end

  local target = app.fs.joinPath(app.fs.tempPath, "old-tv-preview-" .. tag .. ".aseprite-extension")
  local downloadCommand = "curl -fsSL -o " .. shellQuote(target) .. " " .. shellQuote(downloadUrl)
  local result = os.execute(downloadCommand)

  if result ~= true and result ~= 0 then
    app.alert {
      title = "Old TV Preview",
      text = "Could not download " .. tag .. "."
    }
    return
  end

  app.alert {
    title = "Old TV Preview",
    text = "Downloaded " .. tag .. ". Aseprite will open the installer now."
  }
  openFile(target)
end

local function presetNames()
  local names = {}
  for i, preset in ipairs(PRESETS) do
    names[i] = preset.name
  end
  return names
end

local function presetById(id)
  for _, preset in ipairs(PRESETS) do
    if preset.id == id then
      return preset
    end
  end
  return PRESETS[1]
end

local function presetByName(name)
  for _, preset in ipairs(PRESETS) do
    if preset.name == name then
      return preset
    end
  end
  return PRESETS[1]
end

local function presetNameForId(id)
  return presetById(id).name
end

local function ensurePreferences()
  local prefs = pluginRef.preferences

  if type(prefs.presetId) ~= "string" then
    prefs.presetId = DEFAULT_PRESET_ID
  end

  if type(prefs.scale) ~= "number" then
    prefs.scale = DEFAULT_SCALE
  else
    prefs.scale = clampInt(prefs.scale, DEFAULT_SCALE, MIN_SCALE, MAX_SCALE)
  end

  if type(prefs.margin) ~= "number" then
    prefs.margin = DEFAULT_MARGIN
  else
    prefs.margin = clampInt(prefs.margin, DEFAULT_MARGIN, 0, 96)
  end

  if type(prefs.cropTransparentBounds) ~= "boolean" then
    prefs.cropTransparentBounds = true
  end

  if type(prefs.comparison) ~= "boolean" then
    prefs.comparison = false
  end
end

local function activeFrameNumber()
  if app.frame and app.frame.frameNumber then
    return app.frame.frameNumber
  end
  return 1
end

local function mergedCurrentFrame(sprite)
  local image = Image(sprite.width, sprite.height, ColorMode.RGB)
  image:clear(pc.rgba(0, 0, 0, 0))
  image:drawSprite(sprite, activeFrameNumber())
  return image
end

local function findOpaqueBounds(image)
  local minX = image.width
  local minY = image.height
  local maxX = -1
  local maxY = -1

  for y = 0, image.height - 1 do
    for x = 0, image.width - 1 do
      local pixel = image:getPixel(x, y)
      if pc.rgbaA(pixel) > 0 then
        if x < minX then minX = x end
        if y < minY then minY = y end
        if x > maxX then maxX = x end
        if y > maxY then maxY = y end
      end
    end
  end

  if maxX < minX or maxY < minY then
    return nil
  end

  return Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1)
end

local function captureSource(sprite, cropTransparentBounds)
  local merged = mergedCurrentFrame(sprite)

  if not cropTransparentBounds then
    return merged, Rectangle(0, 0, merged.width, merged.height)
  end

  local bounds = findOpaqueBounds(merged)
  if not bounds then
    return nil, nil, "The current frame has no visible pixels."
  end

  local cropped = Image(bounds.width, bounds.height, ColorMode.RGB)
  cropped:clear(pc.rgba(0, 0, 0, 0))
  cropped:drawImage(merged, Point(-bounds.x, -bounds.y))
  return cropped, bounds
end

local function luminance(r, g, b)
  return (r * 0.299) + (g * 0.587) + (b * 0.114)
end

local function rgbToYiq(r, g, b)
  return
    (0.299 * r) + (0.587 * g) + (0.114 * b),
    (0.596 * r) - (0.274 * g) - (0.322 * b),
    (0.211 * r) - (0.523 * g) + (0.312 * b)
end

local function yiqToRgb(y, i, q)
  return
    y + (0.956 * i) + (0.621 * q),
    y - (0.272 * i) - (0.647 * q),
    y - (1.106 * i) + (1.703 * q)
end

local function readSourceRows(image, preset)
  local rows = {}
  for y = 0, image.height - 1 do
    local row = {}
    for x = 0, image.width - 1 do
      local pixel = image:getPixel(x, y)
      local alpha = pc.rgbaA(pixel) / 255.0
      local r = ((pc.rgbaR(pixel) / 255.0) * alpha) + (preset.backgroundRed * (1.0 - alpha))
      local g = ((pc.rgbaG(pixel) / 255.0) * alpha) + (preset.backgroundGreen * (1.0 - alpha))
      local b = ((pc.rgbaB(pixel) / 255.0) * alpha) + (preset.backgroundBlue * (1.0 - alpha))
      row[x + 1] = { r = r, g = g, b = b, a = alpha, l = luminance(r, g, b) }
    end
    rows[y + 1] = row
  end
  return rows
end

local function backgroundSample(preset)
  return {
    r = preset.backgroundRed,
    g = preset.backgroundGreen,
    b = preset.backgroundBlue,
    a = 0.0,
    l = luminance(preset.backgroundRed, preset.backgroundGreen, preset.backgroundBlue)
  }
end

local function sampleRows(rows, width, height, x, y, preset)
  if y < 0 or y > height - 1 or x < 0 or x > width - 1 then
    return backgroundSample(preset)
  end

  local x0 = math.floor(x)
  local x1 = math.min(width - 1, x0 + 1)
  local t = x - x0
  local row = rows[math.floor(y) + 1]
  local a = row[x0 + 1]
  local b = row[x1 + 1]

  return {
    r = lerp(a.r, b.r, t),
    g = lerp(a.g, b.g, t),
    b = lerp(a.b, b.b, t),
    a = lerp(a.a, b.a, t),
    l = lerp(a.l, b.l, t)
  }
end

local function buildSignalRows(rows, width, height, preset)
  local signal = {}
  local iRadius = math.max(1, math.min(6, math.ceil(preset.iBlur * 0.75)))
  local qRadius = math.max(1, math.min(8, math.ceil(preset.qBlur * 0.75)))
  local maxRadius = math.max(iRadius, qRadius)
  local sigmaI = math.max(0.35, preset.iBlur * 0.38)
  local sigmaQ = math.max(0.35, preset.qBlur * 0.38)
  local phase = preset.phaseError + preset.hue
  local cosPhase = math.cos(phase)
  local sinPhase = math.sin(phase)

  for y = 0, height - 1 do
    local outRow = {}
    for x = 0, width - 1 do
      local base = rows[y + 1][x + 1]
      local yBase, _, _ = rgbToYiq(base.r, base.g, base.b)

      local yBlur = 0.0
      local yWeight = 0.0
      local sigmaY = math.max(0.35, preset.lumaBandwidth)
      for tap = -1, 1 do
        local weight = math.exp(-(tap * tap) / (2.0 * sigmaY * sigmaY))
        local sample = sampleRows(rows, width, height, x + tap, y, preset)
        local sy, _, _ = rgbToYiq(sample.r, sample.g, sample.b)
        yBlur = yBlur + (sy * weight)
        yWeight = yWeight + weight
      end
      yBase = lerp(yBase, yBlur / yWeight, 0.32)

      local iSum = 0.0
      local iWeight = 0.0
      local qSum = 0.0
      local qWeight = 0.0

      for tap = -maxRadius, maxRadius do
        local delayedX = x + tap - preset.chromaDelayX
        local sample = sampleRows(rows, width, height, delayedX, y, preset)
        local sy, si, sq = rgbToYiq(sample.r, sample.g, sample.b)
        local wi = math.exp(-(tap * tap) / (2.0 * sigmaI * sigmaI))
        local wq = math.exp(-(tap * tap) / (2.0 * sigmaQ * sigmaQ))
        iSum = iSum + (si * wi)
        iWeight = iWeight + wi
        qSum = qSum + (sq * wq)
        qWeight = qWeight + wq
      end

      local iValue = iSum / iWeight
      local qValue = qSum / qWeight
      local rotatedI = (iValue * cosPhase) - (qValue * sinPhase)
      local rotatedQ = (iValue * sinPhase) + (qValue * cosPhase)

      iValue = (rotatedI * preset.saturation) + (yBase * preset.lumaIntoChroma * 0.08)
      qValue = (rotatedQ * preset.saturation) + (yBase * preset.lumaIntoChroma * 0.06)
      yBase = yBase + ((math.abs(iValue) + math.abs(qValue)) * preset.chromaIntoLuma * 0.12)

      local r, g, b = yiqToRgb(yBase, iValue, qValue)

      local left = sampleRows(rows, width, height, x - 1, y, preset)
      local right = sampleRows(rows, width, height, x + 1, y, preset)
      local bleed = preset.neighborBleed
      r = lerp(r, (left.r + right.r + base.r) / 3.0, bleed * 0.28)
      g = lerp(g, (left.g + right.g + base.g) / 3.0, bleed * 0.28)
      b = lerp(b, (left.b + right.b + base.b) / 3.0, bleed * 0.28)

      local ghost1 = sampleRows(rows, width, height, x - preset.ghostOffset1, y, preset)
      local ghost2 = sampleRows(rows, width, height, x - preset.ghostOffset2, y, preset)
      r = r + ghost1.r * preset.ghostStrength1 + ghost2.r * preset.ghostStrength2
      g = g + ghost1.g * preset.ghostStrength1 + ghost2.g * preset.ghostStrength2
      b = b + ghost1.b * preset.ghostStrength1 + ghost2.b * preset.ghostStrength2

      local noise = (hash01(x, y, 17.0) - 0.5) * preset.signalNoise
      local chromaNoise = (hash01(x, y, 43.0) - 0.5) * preset.chromaNoise
      r = r + noise + chromaNoise
      g = g + noise - chromaNoise * 0.25
      b = b + noise - chromaNoise

      r = saturate(r)
      g = saturate(g)
      b = saturate(b)
      outRow[x + 1] = { r = r, g = g, b = b, a = base.a, l = luminance(r, g, b) }
    end
    signal[y + 1] = outRow
  end

  return signal
end

local function sampleSignal(signalRows, width, height, x, y, preset)
  if y < 0 or y > height - 1 or x < 0 or x > width - 1 then
    return backgroundSample(preset)
  end

  local x0 = math.floor(x)
  local y0 = math.floor(y)
  local x1 = math.min(width - 1, x0 + 1)
  local y1 = math.min(height - 1, y0 + 1)
  local tx = x - x0
  local ty = y - y0
  local a = signalRows[y0 + 1][x0 + 1]
  local b = signalRows[y0 + 1][x1 + 1]
  local c = signalRows[y1 + 1][x0 + 1]
  local d = signalRows[y1 + 1][x1 + 1]

  local topR = lerp(a.r, b.r, tx)
  local topG = lerp(a.g, b.g, tx)
  local topB = lerp(a.b, b.b, tx)
  local botR = lerp(c.r, d.r, tx)
  local botG = lerp(c.g, d.g, tx)
  local botB = lerp(c.b, d.b, tx)

  return {
    r = lerp(topR, botR, ty),
    g = lerp(topG, botG, ty),
    b = lerp(topB, botB, ty),
    a = lerp(lerp(a.a, b.a, tx), lerp(c.a, d.a, tx), ty),
    l = lerp(lerp(a.l, b.l, tx), lerp(c.l, d.l, tx), ty)
  }
end

local function buildGlowRows(signalRows, width, height, preset, scale)
  local glow = {}
  local radius = math.max(1, math.min(5, math.ceil(16.0 / math.max(scale, 1))))
  local sigma = math.max(0.75, radius * 0.62)

  for y = 0, height - 1 do
    local row = {}
    for x = 0, width - 1 do
      local r = 0.0
      local g = 0.0
      local b = 0.0
      local weightSum = 0.0

      for yy = -radius, radius do
        for xx = -radius, radius do
          local sample = sampleSignal(signalRows, width, height, x + xx, y + yy, preset)
          local bright = math.max(0.0, sample.l - preset.bloomThreshold)
          if bright > 0.0 then
            local dist2 = (xx * xx) + (yy * yy)
            local weight = math.exp(-dist2 / (2.0 * sigma * sigma)) * bright
            r = r + sample.r * weight
            g = g + sample.g * weight
            b = b + sample.b * weight
            weightSum = weightSum + weight
          end
        end
      end

      if weightSum > 0.0 then
        r = r / weightSum
        g = g / weightSum
        b = b / weightSum
      end

      row[x + 1] = { r = r, g = g, b = b, l = luminance(r, g, b) }
    end
    glow[y + 1] = row
  end

  return glow
end

local function cellMask(localX, localY, preset)
  local ax = math.max(0.05, preset.cellApertureX)
  local ay = math.max(0.05, preset.cellApertureY)
  local roundness = math.max(0.2, preset.cellRoundness)
  local dx = math.abs(localX - 0.5) / (0.5 * ax)
  local dy = math.abs(localY - 0.5) / (0.5 * ay)
  local d = ((dx ^ roundness) + (dy ^ roundness)) ^ (1.0 / roundness)
  return 1.0 - smoothstep(0.82, 1.0, d)
end

local function subpixelMask(localX, localY, centerX, preset)
  local sigmaX = 0.038 + (0.110 * preset.subpixelApertureX)
  local sigmaY = 0.22 + (0.20 * preset.subpixelApertureY)
  local dx = (localX - centerX) / sigmaX
  local dy = (localY - 0.5) / sigmaY
  return math.exp(-0.5 * ((dx * dx) + (dy * dy)))
end

local function scanlineMultiplier(screenY, preset)
  local wave = (math.sin((screenY * 6.28318530718) / math.max(1.0, preset.scanlinePitch)) + 1.0) * 0.5
  local dip = (wave ^ 1.7) * preset.scanlineStrength * 0.68
  return clamp(1.0 - dip, 0.20, 1.25)
end

local function backdropColor(screenX, screenY, outWidth, outHeight, preset)
  local fade = preset.blackFade
  local warmth = preset.blackWarmth
  local r = preset.backgroundRed + fade * (0.040 + 0.070 * warmth)
  local g = preset.backgroundGreen + fade * (0.035 + 0.045 * warmth)
  local b = preset.backgroundBlue + fade * 0.024

  local stripeScale = math.max(0.25, preset.stripScale)
  local verticalStripe = math.sin((screenX / (8.0 * stripeScale)) + (screenY * 0.045))
  local horizontalStripe = math.sin(screenY / (3.5 * stripeScale))
  local strip = ((verticalStripe * 0.70) + (horizontalStripe * 0.30)) * preset.backdropStrips * 0.018
  local noise = (hash01(screenX, screenY, 5.0) - 0.5) * preset.backdropNoise * 0.045

  r = r + strip + noise
  g = g + strip * 1.12 + noise
  b = b + strip * 0.82 + noise * 0.75

  local nx = ((screenX + 0.5) / outWidth) * 2.0 - 1.0
  local ny = ((screenY + 0.5) / outHeight) * 2.0 - 1.0
  local vignette = clamp((nx * nx + ny * ny) * preset.vignette * 0.38, 0.0, 0.55)

  return r * (1.0 - vignette), g * (1.0 - vignette), b * (1.0 - vignette)
end

local function gradePixel(r, g, b, screenX, screenY, outWidth, outHeight, preset)
  local l = luminance(r, g, b)
  r = lerp(l, r, preset.finalSaturation)
  g = lerp(l, g, preset.finalSaturation)
  b = lerp(l, b, preset.finalSaturation)

  r = r + preset.temperature * 0.055
  b = b - preset.temperature * 0.045

  r = ((r - 0.5) * preset.contrast) + 0.5
  g = ((g - 0.5) * preset.contrast) + 0.5
  b = ((b - 0.5) * preset.contrast) + 0.5

  local invGamma = 1.0 / math.max(0.2, preset.gamma)
  r = saturate(r) ^ invGamma
  g = saturate(g) ^ invGamma
  b = saturate(b) ^ invGamma

  local noise = (hash01(screenX, screenY, 113.0) - 0.5) * preset.noise
  return saturate(r + noise), saturate(g + noise), saturate(b + noise)
end

local function writeRgb(image, x, y, r, g, b)
  image:drawPixel(
    x,
    y,
    pc.rgba(
      math.floor(saturate(r) * 255.0 + 0.5),
      math.floor(saturate(g) * 255.0 + 0.5),
      math.floor(saturate(b) * 255.0 + 0.5),
      255))
end

local function renderRawNearest(sourceRows, width, height, scale, margin, preset)
  local outWidth = (width * scale) + (margin * 2)
  local outHeight = (height * scale) + (margin * 2)
  local image = Image(outWidth, outHeight, ColorMode.RGB)

  for y = 0, outHeight - 1 do
    for x = 0, outWidth - 1 do
      local r, g, b = backdropColor(x, y, outWidth, outHeight, preset)
      local sx = math.floor((x - margin) / scale)
      local sy = math.floor((y - margin) / scale)
      if sx >= 0 and sx < width and sy >= 0 and sy < height then
        local sample = sourceRows[sy + 1][sx + 1]
        r = sample.r
        g = sample.g
        b = sample.b
      end
      writeRgb(image, x, y, r, g, b)
    end
  end

  return image
end

local function renderCrtImage(signalRows, glowRows, width, height, scale, margin, preset)
  local outWidth = (width * scale) + (margin * 2)
  local outHeight = (height * scale) + (margin * 2)
  local image = Image(outWidth, outHeight, ColorMode.RGB)

  for y = 0, outHeight - 1 do
    for x = 0, outWidth - 1 do
      local r, g, b = backdropColor(x, y, outWidth, outHeight, preset)
      local sourceX = (x - margin) / scale
      local sourceY = (y - margin) / scale

      if sourceX >= 0 and sourceX < width and sourceY >= 0 and sourceY < height then
        local cellX = math.floor(sourceX)
        local cellY = math.floor(sourceY)
        local localX = sourceX - cellX
        local localY = sourceY - cellY

        local redSample = sampleSignal(signalRows, width, height, sourceX - preset.redOffsetX / scale, sourceY - preset.redOffsetY / scale, preset)
        local greenSample = sampleSignal(signalRows, width, height, sourceX, sourceY, preset)
        local blueSample = sampleSignal(signalRows, width, height, sourceX - preset.blueOffsetX / scale, sourceY - preset.blueOffsetY / scale, preset)
        local sourceLum = luminance(redSample.r, greenSample.g, blueSample.b)

        local aperture = cellMask(localX, localY, preset)
        local active = smoothstep(preset.activeThreshold, preset.activeThreshold + 0.08, sourceLum) * aperture
        local scan = scanlineMultiplier(y, preset)
        local matrixResistance = 1.0 - preset.matrixGlowResistance * (1.0 - aperture)

        if active > 0.0 then
          local redMask = subpixelMask(localX, localY, 0.22, preset) * active
          local greenMask = subpixelMask(localX, localY, 0.50, preset) * active
          local blueMask = subpixelMask(localX, localY, 0.78, preset) * active
          local maskScale = scan * preset.maskBrightness * 0.72
          local beamMask = active * aperture * scan * (0.34 + sourceLum * 0.30)

          local emitR = redSample.r * redMask * maskScale
          local emitG = greenSample.g * greenMask * maskScale
          local emitB = blueSample.b * blueMask * maskScale

          local whiteBoost = math.max(0.0, sourceLum - preset.bloomThreshold) * preset.whiteBloom
          r = r + redSample.r * beamMask + emitR + (redSample.r * whiteBoost * aperture * preset.smallGlow * 0.34)
          g = g + greenSample.g * beamMask + emitG + (greenSample.g * whiteBoost * aperture * preset.smallGlow * 0.34)
          b = b + blueSample.b * beamMask + emitB + (blueSample.b * whiteBoost * aperture * preset.smallGlow * 0.34)
        end

        local glowCell = glowRows[cellY + 1][cellX + 1]
        local glowAmount = preset.largeGlow * 0.24 * matrixResistance
        r = r + glowCell.r * glowAmount * preset.redBloom
        g = g + glowCell.g * glowAmount * preset.greenBloom
        b = b + glowCell.b * glowAmount * preset.blueBloom

        local halation = math.max(0.0, glowCell.l - preset.bloomThreshold) * preset.halationStrength * 0.18
        r = r + halation * preset.redBloom
        g = g + halation * preset.greenBloom
        b = b + halation * preset.blueBloom
      end

      r, g, b = gradePixel(r, g, b, x, y, outWidth, outHeight, preset)
      writeRgb(image, x, y, r, g, b)
    end
  end

  return image
end

local function composeComparison(rawImage, crtImage, preset)
  local width = rawImage.width + COMPARISON_GAP + crtImage.width
  local height = math.max(rawImage.height, crtImage.height)
  local image = Image(width, height, ColorMode.RGB)

  for y = 0, height - 1 do
    for x = 0, width - 1 do
      local r, g, b = backdropColor(x, y, width, height, preset)
      writeRgb(image, x, y, r, g, b)
    end
  end

  image:drawImage(rawImage, Point(0, math.floor((height - rawImage.height) / 2)))
  image:drawImage(crtImage, Point(rawImage.width + COMPARISON_GAP, math.floor((height - crtImage.height) / 2)))
  return image
end

local function previewName(sprite, preset, comparison)
  local base = sprite.filename
  if not base or base == "" then
    base = sprite.name or "sprite"
  end

  base = app.fs.fileTitle(base)
  local suffix = comparison and "-old-tv-comparison" or "-old-tv-preview"
  return base .. suffix .. "-" .. preset.id
end

local function createSpriteFromImage(image, name)
  local sprite = Sprite(image.width, image.height, ColorMode.RGB)
  sprite.layers[1].name = "Old TV Preview"
  sprite.cels[1].image = image
  sprite.filename = name .. ".png"
  app.sprite = sprite
  app.refresh()
end

local function renderPreviewFromPreferences(comparisonOverride)
  ensurePreferences()

  local sprite = app.sprite
  if not sprite then
    app.alert {
      title = "Old TV Preview",
      text = "Open a sprite before rendering an Old TV preview."
    }
    return
  end

  local prefs = pluginRef.preferences
  local preset = presetById(prefs.presetId)
  local scale = clampInt(prefs.scale, DEFAULT_SCALE, MIN_SCALE, MAX_SCALE)
  local margin = clampInt(prefs.margin, DEFAULT_MARGIN, 0, 96)
  local comparison = comparisonOverride
  if comparison == nil then
    comparison = prefs.comparison == true
  end

  local sourceImage, _, sourceError = captureSource(sprite, prefs.cropTransparentBounds == true)
  if not sourceImage then
    app.alert {
      title = "Old TV Preview",
      text = sourceError or "Could not capture the current frame."
    }
    return
  end

  local outWidth = (sourceImage.width * scale) + (margin * 2)
  local outHeight = (sourceImage.height * scale) + (margin * 2)
  local projectedPixels = outWidth * outHeight
  if comparison then
    projectedPixels = projectedPixels * 2.1
  end

  if projectedPixels > MAX_RENDER_PIXELS then
    app.alert {
      title = "Old TV Preview",
      text = "This preview would render about " ..
        tostring(math.floor(projectedPixels)) ..
        " pixels. Lower the scale or enable transparent-bounds crop."
    }
    return
  end

  app.transaction("Render Old TV Preview", function()
    local sourceRows = readSourceRows(sourceImage, preset)
    local signalRows = buildSignalRows(sourceRows, sourceImage.width, sourceImage.height, preset)
    local glowRows = buildGlowRows(signalRows, sourceImage.width, sourceImage.height, preset, scale)
    local crtImage = renderCrtImage(signalRows, glowRows, sourceImage.width, sourceImage.height, scale, margin, preset)

    if comparison then
      local rawImage = renderRawNearest(sourceRows, sourceImage.width, sourceImage.height, scale, margin, preset)
      crtImage = composeComparison(rawImage, crtImage, preset)
    end

    createSpriteFromImage(crtImage, previewName(sprite, preset, comparison))
  end)
end

local function quickRender()
  local ok, err = pcall(function()
    renderPreviewFromPreferences(nil)
  end)

  if not ok then
    app.alert {
      title = "Old TV Preview",
      text = tostring(err)
    }
  end
end

local function showRenderDialog()
  ensurePreferences()

  local prefs = pluginRef.preferences
  local dlg = Dialog {
    title = "Old TV Preview"
  }

  dlg:combobox {
    id = "preset",
    label = "Preset",
    option = presetNameForId(prefs.presetId),
    options = presetNames()
  }

  dlg:number {
    id = "scale",
    label = "Scale",
    text = tostring(prefs.scale),
    decimals = 0
  }

  dlg:number {
    id = "margin",
    label = "Margin",
    text = tostring(prefs.margin),
    decimals = 0
  }

  dlg:check {
    id = "crop",
    text = "Crop transparent bounds",
    selected = prefs.cropTransparentBounds == true
  }

  dlg:check {
    id = "comparison",
    text = "Create side-by-side comparison",
    selected = prefs.comparison == true
  }

  dlg:separator {
    text = "Output"
  }

  dlg:label {
    text = "Creates a new RGB sprite. The source art is not modified."
  }

  dlg:button {
    id = "render",
    text = "Render",
    onclick = function()
      local data = dlg.data
      local preset = presetByName(data.preset)
      prefs.presetId = preset.id
      prefs.scale = clampInt(data.scale, DEFAULT_SCALE, MIN_SCALE, MAX_SCALE)
      prefs.margin = clampInt(data.margin, DEFAULT_MARGIN, 0, 96)
      prefs.cropTransparentBounds = data.crop == true
      prefs.comparison = data.comparison == true
      dlg:close()

      local ok, err = pcall(function()
        renderPreviewFromPreferences(prefs.comparison)
      end)

      if not ok then
        app.alert {
          title = "Old TV Preview",
          text = tostring(err)
        }
      end
    end
  }

  dlg:button {
    id = "cancel",
    text = "Cancel",
    onclick = function()
      dlg:close()
    end
  }

  dlg:show()
end

function init(plugin)
  pluginRef = plugin
  ensurePreferences()

  plugin:newCommand {
    id = "OldTvPreviewRender",
    title = "Old TV Preview: Render...",
    group = "view_controls",
    onclick = showRenderDialog,
    onenabled = function()
      return app.isUIAvailable and app.sprite ~= nil
    end
  }

  plugin:newCommand {
    id = "OldTvPreviewQuickRender",
    title = "Old TV Preview: Quick Render",
    group = "view_controls",
    onclick = quickRender,
    onenabled = function()
      return app.isUIAvailable and app.sprite ~= nil
    end
  }

  plugin:newCommand {
    id = "OldTvPreviewCheckUpdates",
    title = "Old TV Preview: Check for Updates...",
    group = "view_controls",
    onclick = checkForUpdates,
    onenabled = function()
      return app.isUIAvailable
    end
  }
end

function exit(plugin)
  pluginRef = nil
end

local function runCliSmokeTest()
  local input = app.params.input
  if input and input ~= "" then
    app.open(input)
  end

  if not app.sprite then
    local sprite = Sprite(5, 5, ColorMode.RGB)
    local image = Image(5, 5, ColorMode.RGB)
    image:clear(pc.rgba(0, 0, 0, 0))
    image:drawPixel(1, 1, pc.rgba(255, 255, 255, 255))
    image:drawPixel(2, 1, pc.rgba(255, 255, 255, 255))
    image:drawPixel(1, 2, pc.rgba(255, 0, 128, 255))
    image:drawPixel(2, 2, pc.rgba(80, 100, 255, 255))
    image:drawPixel(3, 3, pc.rgba(0, 0, 0, 255))
    sprite.cels[1].image = image
    app.sprite = sprite
  end

  pluginRef = {
    preferences = {
      presetId = DEFAULT_PRESET_ID,
      scale = clampInt(app.params.scale, input and DEFAULT_SCALE or 5, MIN_SCALE, MAX_SCALE),
      margin = 3,
      cropTransparentBounds = true,
      comparison = false
    }
  }

  renderPreviewFromPreferences(false)

  local output = app.params["output"]
  if output and output ~= "" and app.sprite then
    app.sprite:saveCopyAs(output)
  end
end

if app.params and (app.params["old-tv-preview-smoke"] == "1" or app.params.old_tv_preview_smoke == "1") then
  runCliSmokeTest()
end
