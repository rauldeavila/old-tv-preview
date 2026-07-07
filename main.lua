local EXTENSION_VERSION = "0.2.1"
local RELEASE_REPO = "rauldeavila/old-tv-preview"
local OLD_TV_BRIDGE_DIR = (os.getenv("HOME") or "") .. "/Library/Application Support/OldTV/AsepriteBridge"
local OLD_TV_WS_URL = "ws://127.0.0.1:37171/aseprite"
local DEFAULT_PRESET_ID = "july_teste_01"
local DEFAULT_SCALE = 12
local DEFAULT_MARGIN = 14
local MIN_SCALE = 2
local MAX_SCALE = 32
local MAX_RENDER_PIXELS = 2300000
local COMPARISON_GAP = 18
local QUICK_PREVIEW_MAX_WIDTH = 720
local QUICK_PREVIEW_MAX_HEIGHT = 720
local QUICK_PREVIEW_MIN_WIDTH = 180
local QUICK_PREVIEW_MIN_HEIGHT = 140
local QUICK_PREVIEW_DEFAULT_ZOOM = 0.55
local QUICK_PREVIEW_MIN_ZOOM = 0.20
local QUICK_PREVIEW_MAX_ZOOM = 2.00
local QUICK_PREVIEW_ZOOM_STEP = 0.10
local QUICK_PREVIEW_TIMER_INTERVAL = 0.18
local QUICK_PREVIEW_LIVE_MAX_SCALE = 6
local QUICK_PREVIEW_LIVE_MAX_PIXELS = 260000
local METAL_LIVE_TIMER_INTERVAL = 0.08

local pluginRef = nil
local metalLiveEnabled = false
local metalLiveDirty = false
local metalLiveTimer = nil
local metalLiveSocket = nil
local metalLiveSocketConnected = false
local metalLiveSequence = 0
local metalLiveSprite = nil
local metalLiveSpriteChangeListener = nil
local quickPreviewDialog = nil
local quickPreviewImage = nil
local quickPreviewStatus = ""
local quickPreviewTimer = nil
local quickPreviewDirty = false
local quickPreviewRendering = false
local quickPreviewHighQuality = false
local quickPreviewSprite = nil
local quickPreviewSpriteChangeListener = nil
local listeners = {}

local pc = app.pixelColor

local PRESETS = {
  {
    id = "july_teste_01",
    name = "July Test 01 (LIGHTWARD)",
    backgroundRed = 0.055,
    backgroundGreen = 0.062,
    backgroundBlue = 0.055,
    saturation = 1.62,
    lumaBandwidth = 0.55,
    iBlur = 3.35,
    qBlur = 5.65,
    chromaDelayX = 1.45,
    lumaIntoChroma = 0.55,
    chromaIntoLuma = 0.32,
    phaseError = 0.26,
    hue = 0.07,
    signalNoise = 0.006,
    chromaNoise = 0.014,
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
    neighborBleed = 0.24,
    matrixGlowResistance = 0.62,
    scanlineStrength = 0.40,
    scanlinePitch = 4.50,
    maskBrightness = 1.62,
    redOffsetX = -1.35,
    redOffsetY = -0.16,
    blueOffsetX = 1.48,
    blueOffsetY = 0.14,
    rgbLeak = 0.92,
    rgbLeakRadius = 1.70,
    smallGlow = 0.62,
    largeGlow = 0.68,
    halationStrength = 0.30,
    bloomThreshold = 0.18,
    whiteBloom = 0.90,
    blueBloom = 1.24,
    greenBloom = 1.08,
    redBloom = 0.84,
    contrast = 1.16,
    gamma = 1.05,
    finalSaturation = 1.24,
    temperature = 0.06,
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
    rgbLeak = 0.28,
    rgbLeakRadius = 1.15,
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
    rgbLeak = 0.76,
    rgbLeakRadius = 1.80,
    smallGlow = 0.86,
    largeGlow = 0.64,
    halationStrength = 0.34,
    bloomThreshold = 0.16,
    whiteBloom = 0.88,
    blueBloom = 1.26,
    greenBloom = 0.96,
    redBloom = 0.92,
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

local function smoothReverse(edge0, edge1, value)
  local t = saturate((edge0 - value) / math.max(edge0 - edge1, 0.00001))
  return t * t * (3.0 - 2.0 * t)
end

local function fract(value)
  return value - math.floor(value)
end

local function hash01(x, y, seed)
  local v = math.sin((x * 12.9898) + (y * 78.233) + (seed * 37.719)) * 43758.5453
  return v - math.floor(v)
end

local function shellQuote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function jsonEscape(value)
  return tostring(value or "")
    :gsub("\\", "\\\\")
    :gsub('"', '\\"')
    :gsub("\n", "\\n")
    :gsub("\r", "\\r")
    :gsub("\t", "\\t")
end

local function writeTextFile(path, text)
  local handle = io.open(path, "wb")
  if not handle then
    return false
  end

  handle:write(text)
  handle:close()
  return true
end

local function ensureDirectory(path)
  os.execute("mkdir -p " .. shellQuote(path))
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

  if type(prefs.quickPreviewAutoRefresh) ~= "boolean" then
    prefs.quickPreviewAutoRefresh = true
  end

  if type(prefs.quickPreviewZoom) ~= "number" then
    prefs.quickPreviewZoom = QUICK_PREVIEW_DEFAULT_ZOOM
  else
    prefs.quickPreviewZoom = clamp(prefs.quickPreviewZoom, QUICK_PREVIEW_MIN_ZOOM, QUICK_PREVIEW_MAX_ZOOM)
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

local function metalLiveMetadataJson(image, sprite, sequence, pngPath)
  local spriteName = "Aseprite Sprite"
  if sprite then
    spriteName = sprite.filename or sprite.name or spriteName
    if spriteName == "" then
      spriteName = sprite.name or "Aseprite Sprite"
    end
  end

  local fields = {
    '"protocolName":"oldtv-aseprite-frame-v1"',
    '"sequence":' .. tostring(sequence),
    '"spriteName":"' .. jsonEscape(spriteName) .. '"',
    '"frameNumber":' .. tostring(activeFrameNumber()),
    '"width":' .. tostring(image.width),
    '"height":' .. tostring(image.height),
    '"bytesPerPixel":' .. tostring(image.bytesPerPixel or 4),
    '"rowStride":' .. tostring(image.rowStride or (image.width * 4)),
    '"format":"rgba8"'
  }

  if pngPath then
    fields[#fields + 1] = '"imagePath":"' .. jsonEscape(pngPath) .. '"'
  end

  return "{" .. table.concat(fields, ",") .. "}"
end

local function writeMetalLiveFallback(image, sprite, sequence)
  ensureDirectory(OLD_TV_BRIDGE_DIR)
  local pngPath = app.fs.joinPath(OLD_TV_BRIDGE_DIR, "frame.png")
  local tmpPngPath = app.fs.joinPath(OLD_TV_BRIDGE_DIR, "frame.tmp.png")
  local manifestPath = app.fs.joinPath(OLD_TV_BRIDGE_DIR, "manifest.json")
  local tmpManifestPath = app.fs.joinPath(OLD_TV_BRIDGE_DIR, "manifest.tmp.json")

  local ok, err = pcall(function()
    image:saveAs(tmpPngPath)
  end)
  if not ok then
    return false, tostring(err)
  end

  os.remove(pngPath)
  os.rename(tmpPngPath, pngPath)

  local manifest = metalLiveMetadataJson(image, sprite, sequence, pngPath)
  if not writeTextFile(tmpManifestPath, manifest) then
    return false, "Could not write Aseprite bridge manifest."
  end

  os.remove(manifestPath)
  os.rename(tmpManifestPath, manifestPath)
  return true, nil
end

local function ensureMetalLiveSocket()
  if metalLiveSocket or not WebSocket then
    return
  end

  local ok, socket = pcall(function()
    return WebSocket {
      url = OLD_TV_WS_URL,
      onopen = function(ws)
        metalLiveSocketConnected = true
        metalLiveDirty = true
      end,
      onclose = function(ws)
        metalLiveSocketConnected = false
        metalLiveSocket = nil
      end,
      onerror = function(ws, err)
        metalLiveSocketConnected = false
        metalLiveSocket = nil
      end
    }
  end)

  if ok and socket then
    metalLiveSocket = socket
    pcall(function()
      metalLiveSocket:connect()
    end)
  end
end

local function sendMetalLiveFrame()
  if not metalLiveEnabled or not app.sprite then
    return true
  end

  ensureMetalLiveSocket()
  if not metalLiveSocketConnected then
    return true
  end

  local sprite = app.sprite
  local image = mergedCurrentFrame(sprite)
  metalLiveSequence = metalLiveSequence + 1
  local metadata = metalLiveMetadataJson(image, sprite, metalLiveSequence, nil)
  local payload = metadata .. "\n" .. image.bytes
  local ok = pcall(function()
    metalLiveSocket:sendBinary(payload)
  end)
  if ok ~= true then
    metalLiveSocketConnected = false
    if metalLiveSocket then
      pcall(function()
        metalLiveSocket:close()
      end)
    end
    metalLiveSocket = nil
    return true
  end

  return true
end

local function stopMetalLiveTimer()
  if metalLiveTimer and metalLiveTimer.isRunning then
    metalLiveTimer:stop()
  end
end

local function startMetalLiveTimer()
  if metalLiveTimer and metalLiveTimer.isRunning then
    return
  end

  metalLiveTimer = Timer {
    interval = METAL_LIVE_TIMER_INTERVAL,
    ontick = function()
      if not metalLiveEnabled then
        stopMetalLiveTimer()
        return
      end

      if metalLiveDirty then
        metalLiveDirty = not sendMetalLiveFrame()
      end
    end
  }
  metalLiveTimer:start()
end

local function markMetalLiveDirty(reason)
  if not metalLiveEnabled then
    return
  end

  metalLiveDirty = true
  startMetalLiveTimer()
end

local function detachMetalLiveSpriteListener()
  if metalLiveSprite and metalLiveSpriteChangeListener and metalLiveSprite.events then
    pcall(function()
      metalLiveSprite.events:off(metalLiveSpriteChangeListener)
    end)
  end

  metalLiveSprite = nil
  metalLiveSpriteChangeListener = nil
end

local function attachMetalLiveSpriteListener(sprite)
  if metalLiveSprite == sprite and metalLiveSpriteChangeListener then
    return
  end

  detachMetalLiveSpriteListener()

  if not sprite or not sprite.events then
    return
  end

  metalLiveSprite = sprite
  metalLiveSpriteChangeListener = sprite.events:on("change", function(ev)
    markMetalLiveDirty("sprite change")
  end)
end

local function syncMetalLiveSpriteListener()
  if metalLiveEnabled and app.sprite then
    attachMetalLiveSpriteListener(app.sprite)
  else
    detachMetalLiveSpriteListener()
  end
end

local function stopMetalLivePreview()
  metalLiveEnabled = false
  metalLiveDirty = false
  stopMetalLiveTimer()
  detachMetalLiveSpriteListener()
  if metalLiveSocket then
    pcall(function()
      metalLiveSocket:close()
    end)
  end
  metalLiveSocket = nil
  metalLiveSocketConnected = false
end

local function startMetalLivePreview()
  if not app.sprite then
    app.alert {
      title = "Old TV Preview",
      text = "Open a sprite before starting the Old TV Metal live preview."
    }
    return
  end

  metalLiveEnabled = true
  ensureMetalLiveSocket()
  syncMetalLiveSpriteListener()
  markMetalLiveDirty("start")
end

local function toggleMetalLivePreview()
  if metalLiveEnabled then
    stopMetalLivePreview()
  else
    startMetalLivePreview()
  end
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

local function aboveBackground(sample, preset)
  local r = math.max(sample.r - preset.backgroundRed, 0.0)
  local g = math.max(sample.g - preset.backgroundGreen, 0.0)
  local b = math.max(sample.b - preset.backgroundBlue, 0.0)
  return {
    r = r,
    g = g,
    b = b,
    l = luminance(r, g, b),
    peak = math.max(r, math.max(g, b))
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

local function cellMask(localX, localY, preset)
  local distX = math.abs(localX - 0.5) * 2.0
  local distY = math.abs(localY - 0.5) * 2.0
  local normX = distX / math.max(preset.cellApertureX, 0.001)
  local normY = distY / math.max(preset.cellApertureY, 0.001)
  local power = math.max(preset.cellRoundness * 2.0, 0.35)
  local shape = (normX ^ power) + (normY ^ power)
  return smoothReverse(1.18, 0.72, shape)
end

local function subpixelStripMask(localX, localY, preset)
  local sub = localX * 3.0
  local channelIndex = math.floor(sub)
  local channelCenter = (channelIndex + 0.5) / 3.0
  local subDistance = math.abs(localX - channelCenter) * 3.0
  local apertureX = smoothstep(1.0, preset.subpixelApertureX, subDistance) ^ 1.10
  local apertureY = smoothstep(1.0, preset.subpixelApertureY, math.abs(localY - 0.5) * 2.0) ^ 1.15
  local aperture = apertureX * apertureY * preset.maskBrightness

  if channelIndex < 0.5 then
    return aperture, 0.0, 0.0
  elseif channelIndex < 1.5 then
    return 0.0, aperture, 0.0
  end

  return 0.0, 0.0, aperture
end

local function scanlineOpen(screenY, brightness, preset)
  local pitch = math.max(preset.scanlinePitch, 1.0)
  local scanLocal = math.abs(fract(screenY / pitch) - 0.5) * 2.0
  local thickness = lerp(0.64, 1.18, saturate(brightness))
  local open = smoothReverse(1.0, 0.0, scanLocal / math.max(thickness, 0.001))
  return lerp(1.0, open, saturate(preset.scanlineStrength))
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
  local uvX = (screenX + 0.5) / outWidth
  local uvY = (screenY + 0.5) / outHeight
  local centeredX = uvX * 2.0 - 1.0
  local centeredY = uvY * 2.0 - 1.0
  local vignette = 1.0 - preset.vignette * smoothstep(0.32, 1.22, (centeredX * centeredX) + (centeredY * centeredY))
  r = r * vignette
  g = g * vignette
  b = b * vignette

  r = r + 0.010
  g = g + 0.010
  b = b + 0.010

  r = r * (1.0 + preset.temperature)
  b = b * (1.0 - preset.temperature)

  r = ((r - 0.5) * preset.contrast) + 0.5
  g = ((g - 0.5) * preset.contrast) + 0.5
  b = ((b - 0.5) * preset.contrast) + 0.5

  local l = luminance(r, g, b)
  r = lerp(l, r, preset.finalSaturation)
  g = lerp(l, g, preset.finalSaturation)
  b = lerp(l, b, preset.finalSaturation)

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

local function matrixColor(preset)
  local amount = 1.0 - clamp(preset.cellMatrixDarkness, 0.0, 1.0)
  return preset.backgroundRed * amount, preset.backgroundGreen * amount, preset.backgroundBlue * amount
end

local function sourceOrBackgroundSignal(signalRows, width, height, sourceX, sourceY, preset)
  if sourceX < 0 or sourceY < 0 or sourceX >= width or sourceY >= height then
    return backgroundSample(preset)
  end

  return signalRows[sourceY + 1][sourceX + 1]
end

local function blendedSignalCell(signalRows, width, height, sourceX, sourceY, preset)
  local nearestX = math.floor(sourceX)
  local nearestY = math.floor(sourceY)
  local center = sourceOrBackgroundSignal(signalRows, width, height, nearestX, nearestY, preset)
  local bleed = clamp(preset.neighborBleed, 0.0, 1.0)
  if bleed <= 0.0001 then
    return center
  end

  local r = 0.0
  local g = 0.0
  local b = 0.0
  local weightSum = 0.0
  for yy = -1, 1 do
    for xx = -1, 1 do
      local sx = nearestX + xx
      local sy = nearestY + yy
      local sample = sourceOrBackgroundSignal(signalRows, width, height, sx, sy, preset)
      local dx = sourceX - (sx + 0.5)
      local dy = sourceY - (sy + 0.5)
      local weight = math.exp(-((dx * dx) + (dy * dy)) * 2.4)
      r = r + sample.r * weight
      g = g + sample.g * weight
      b = b + sample.b * weight
      weightSum = weightSum + weight
    end
  end

  weightSum = math.max(weightSum, 0.00001)
  r = lerp(center.r, r / weightSum, bleed)
  g = lerp(center.g, g / weightSum, bleed)
  b = lerp(center.b, b / weightSum, bleed)
  return { r = r, g = g, b = b, a = center.a, l = luminance(r, g, b) }
end

local function emitterBeamAt(signalRows, width, height, sourceX, sourceY, preset)
  local cellLocalX = fract(sourceX)
  local cellLocalY = fract(sourceY)
  local sourceColor = blendedSignalCell(signalRows, width, height, sourceX, sourceY, preset)
  local above = aboveBackground(sourceColor, preset)
  local sourceSignal = math.max(above.peak, above.l)
  local active = smoothstep(preset.activeThreshold, preset.activeThreshold + 0.16, sourceSignal)
  if active <= 0.0 then
    return { r = 0.0, g = 0.0, b = 0.0, l = 0.0 }
  end

  local aperture = cellMask(cellLocalX, cellLocalY, preset)
  local brightness = saturate(sourceColor.l * 1.22)
  local gain = 0.72 + brightness * 0.38
  local scale = active * aperture * gain
  local r = sourceColor.r * scale
  local g = sourceColor.g * scale
  local b = sourceColor.b * scale
  return { r = r, g = g, b = b, l = luminance(r, g, b) }
end

local function sampleColorRows(rows, width, height, x, y)
  local clampedX = clamp(x, 0.0, width - 1)
  local clampedY = clamp(y, 0.0, height - 1)
  local x0 = math.floor(clampedX)
  local y0 = math.floor(clampedY)
  local x1 = math.min(width - 1, x0 + 1)
  local y1 = math.min(height - 1, y0 + 1)
  local tx = clampedX - x0
  local ty = clampedY - y0
  local a = rows[y0 + 1][x0 + 1]
  local b = rows[y0 + 1][x1 + 1]
  local c = rows[y1 + 1][x0 + 1]
  local d = rows[y1 + 1][x1 + 1]

  local r = lerp(lerp(a.r, b.r, tx), lerp(c.r, d.r, tx), ty)
  local g = lerp(lerp(a.g, b.g, tx), lerp(c.g, d.g, tx), ty)
  local blue = lerp(lerp(a.b, b.b, tx), lerp(c.b, d.b, tx), ty)
  return { r = r, g = g, b = blue, l = luminance(r, g, blue) }
end

local function buildBloomExtractRows(rows, width, height, preset)
  local extractRows = {}
  for y = 0, height - 1 do
    local outRow = {}
    for x = 0, width - 1 do
      local color = rows[y + 1][x + 1]
      local brightness = color.l or luminance(color.r, color.g, color.b)
      local extract = smoothstep(preset.bloomThreshold, preset.bloomThreshold + 0.45, brightness)
      local minColor = math.min(color.r, math.min(color.g, color.b))
      local whiteBoost = preset.whiteBloom * smoothstep(0.55, 1.0, minColor)
      local r = color.r * extract * (preset.redBloom + whiteBoost)
      local g = color.g * extract * (preset.greenBloom + whiteBoost)
      local b = color.b * extract * (preset.blueBloom + whiteBoost)
      outRow[x + 1] = { r = r, g = g, b = b, l = luminance(r, g, b) }
    end
    extractRows[y + 1] = outRow
  end
  return extractRows
end

local function blurRows(rows, width, height, radius, horizontal)
  local outRows = {}
  local safeRadius = math.max(radius, 0.001)
  for y = 0, height - 1 do
    local outRow = {}
    for x = 0, width - 1 do
      local r = 0.0
      local g = 0.0
      local b = 0.0
      local weightSum = 0.0
      for tap = -7, 7 do
        local dist = tap
        local weight = math.exp(-(dist * dist) / 18.0)
        local offset = dist * safeRadius / 7.0
        local sample
        if horizontal then
          sample = sampleColorRows(rows, width, height, x + offset, y)
        else
          sample = sampleColorRows(rows, width, height, x, y + offset)
        end
        r = r + sample.r * weight
        g = g + sample.g * weight
        b = b + sample.b * weight
        weightSum = weightSum + weight
      end
      weightSum = math.max(weightSum, 0.00001)
      r = r / weightSum
      g = g / weightSum
      b = b / weightSum
      outRow[x + 1] = { r = r, g = g, b = b, l = luminance(r, g, b) }
    end
    outRows[y + 1] = outRow
  end
  return outRows
end

local function applyBlackFadePixel(r, g, b, preset)
  local amount = clamp(preset.blackFade, 0.0, 1.0)
  if amount <= 0.0001 then
    return r, g, b
  end

  local darkWeight = (1.0 - smoothstep(0.02, 0.48, luminance(r, g, b))) ^ 1.35
  local warm = clamp(preset.blackWarmth, 0.0, 1.0)
  local targetR = lerp(0.035, 0.105, warm)
  local targetG = lerp(0.038, 0.098, warm)
  local targetB = lerp(0.036, 0.058, warm)
  local mixAmount = amount * darkWeight
  return
    lerp(r, math.max(r, targetR), mixAmount),
    lerp(g, math.max(g, targetG), mixAmount),
    lerp(b, math.max(b, targetB), mixAmount)
end

local function applyBackdropArtifactsPixel(r, g, b, screenX, screenY, preset)
  local noiseAmount = clamp(preset.backdropNoise, 0.0, 1.0)
  local stripeAmount = clamp(preset.backdropStrips, 0.0, 1.0)
  if noiseAmount <= 0.0001 and stripeAmount <= 0.0001 then
    return r, g, b
  end

  local darkWeight = (1.0 - smoothstep(0.025, 0.44, luminance(r, g, b))) ^ 1.55
  if darkWeight <= 0.0001 then
    return r, g, b
  end

  local fine = hash01(math.floor(screenX), math.floor(screenY), 19.0) - 0.5
  local rowNoise = hash01(math.floor(screenY * 0.55), 41.0, 3.0) - 0.5
  local blotch = hash01(math.floor(screenX / 10.0), math.floor(screenY / 5.0), 3.0) - 0.5
  local noise = fine * 0.56 + rowNoise * 0.24 + blotch * 0.20
  r = r + noise * noiseAmount * darkWeight * 0.052
  g = g + noise * noiseAmount * darkWeight * 0.052
  b = b + noise * noiseAmount * darkWeight * 0.052

  local pitch = math.max(12.0 / math.max(preset.stripScale, 0.25), 1.0)
  local phase = fract((screenX + 0.4) / pitch)
  local red = smoothReverse(0.30, 0.0, math.abs(phase - 0.17))
  local green = smoothReverse(0.30, 0.0, math.abs(phase - 0.50))
  local blue = smoothReverse(0.30, 0.0, math.abs(phase - 0.83))
  local columnPeak = math.max(red, math.max(green, blue))
  red = lerp(columnPeak, red, 0.62)
  green = lerp(columnPeak, green, 0.62)
  blue = lerp(columnPeak, blue, 0.62)

  local scan = 0.42 + 0.58 * smoothReverse(1.0, 0.0, math.abs(fract(screenY / math.max(preset.scanlinePitch, 1.0)) - 0.5) * 2.0)
  local flutter = 0.58 + 0.42 * math.sin(screenX * 6.2831853 / pitch + math.sin(screenY * 0.027) * 0.75)
  local broadBand = hash01(math.floor(screenY / 18.0), 73.0, 0.7) - 0.5
  r = r + (red * scan * flutter * 0.032 + broadBand * 0.020) * stripeAmount * darkWeight
  g = g + (green * scan * flutter * 0.032 + broadBand * 0.020) * stripeAmount * darkWeight
  b = b + (blue * scan * flutter * 0.032 + broadBand * 0.020) * stripeAmount * darkWeight
  return r, g, b
end

local function applyRgbLeakPixel(r, g, b, beamRows, glowRows, width, height, x, y, preset)
  local amount = clamp(preset.rgbLeak, 0.0, 2.0)
  if amount <= 0.0001 then
    return r, g, b
  end

  local radius = math.max(0.15, tonumber(preset.rgbLeakRadius) or 1.25)
  local center = sampleColorRows(beamRows, width, height, x, y)
  local left = sampleColorRows(beamRows, width, height, x - radius, y - radius * 0.08)
  local right = sampleColorRows(beamRows, width, height, x + radius, y + radius * 0.08)
  local up = sampleColorRows(beamRows, width, height, x, y - radius)
  local down = sampleColorRows(beamRows, width, height, x, y + radius)
  local leftGlow = sampleColorRows(glowRows, width, height, x - radius * 1.45, y - radius * 0.14)
  local rightGlow = sampleColorRows(glowRows, width, height, x + radius * 1.45, y + radius * 0.14)
  local greenGlow = sampleColorRows(glowRows, width, height, x - radius * 0.18, y - radius * 0.55)

  local horizontalEdge = math.abs(left.l - right.l)
  local verticalEdge = math.abs(up.l - down.l)
  local edge = smoothstep(0.035, 0.36, (horizontalEdge * 1.9) + (verticalEdge * 0.85))
  local lit = smoothstep(0.08, 0.55, center.l + left.l + right.l)
  local fringe = amount * (edge * 0.92 + lit * 0.025)

  r = r + ((left.r * 0.18) + (leftGlow.r * 0.42)) * fringe
  g = g + ((greenGlow.g * 0.18) + (math.min(left.g, right.g) * 0.06)) * fringe
  b = b + ((right.b * 0.22) + (rightGlow.b * 0.50)) * fringe
  return r, g, b
end

local function renderCrtImage(signalRows, width, height, scale, margin, preset)
  local outWidth = (width * scale) + (margin * 2)
  local outHeight = (height * scale) + (margin * 2)
  local beamRows = {}
  local maskedRows = {}

  local matrixR, matrixG, matrixB = matrixColor(preset)
  for y = 0, outHeight - 1 do
    local beamRow = {}
    local maskedRow = {}
    for x = 0, outWidth - 1 do
      local sourceX = (x + 1.5 - margin) / scale
      local sourceY = (y + 1.5 - margin) / scale
      local redBeam = emitterBeamAt(signalRows, width, height, sourceX + preset.redOffsetX / scale, sourceY + preset.redOffsetY / scale, preset)
      local greenBeam = emitterBeamAt(signalRows, width, height, sourceX, sourceY, preset)
      local blueBeam = emitterBeamAt(signalRows, width, height, sourceX + preset.blueOffsetX / scale, sourceY + preset.blueOffsetY / scale, preset)
      local emissionR = redBeam.r
      local emissionG = greenBeam.g
      local emissionB = blueBeam.b
      local brightness = luminance(emissionR, emissionG, emissionB)
      local localX = fract(sourceX)
      local localY = fract(sourceY)
      local redMask, greenMask, blueMask = subpixelStripMask(localX, localY, preset)
      local scan = scanlineOpen(y, brightness, preset)
      local r = matrixR + emissionR * redMask * scan
      local g = matrixG + emissionG * greenMask * scan
      local b = matrixB + emissionB * blueMask * scan

      beamRow[x + 1] = { r = emissionR, g = emissionG, b = emissionB, l = brightness }
      maskedRow[x + 1] = { r = r, g = g, b = b, l = luminance(r, g, b) }
    end
    beamRows[y + 1] = beamRow
    maskedRows[y + 1] = maskedRow
  end

  local smallExtract = buildBloomExtractRows(maskedRows, outWidth, outHeight, preset)
  local largeExtract = buildBloomExtractRows(beamRows, outWidth, outHeight, preset)
  local smallBlur = blurRows(blurRows(smallExtract, outWidth, outHeight, preset.smallGlow * 5.5, true), outWidth, outHeight, preset.smallGlow * 5.5, false)
  local largeBlur = blurRows(blurRows(largeExtract, outWidth, outHeight, math.max(1.0, preset.largeGlow * 30.0), true), outWidth, outHeight, math.max(1.0, preset.largeGlow * 30.0), false)
  local image = Image(outWidth, outHeight, ColorMode.RGB)

  for y = 0, outHeight - 1 do
    for x = 0, outWidth - 1 do
      local masked = maskedRows[y + 1][x + 1]
      local small = smallBlur[y + 1][x + 1]
      local large = largeBlur[y + 1][x + 1]
      local r = masked.r
      local g = masked.g
      local b = masked.b
      local litR = math.max(r - matrixR, 0.0)
      local litG = math.max(g - matrixG, 0.0)
      local litB = math.max(b - matrixB, 0.0)
      local lit = smoothstep(0.02, 0.30, luminance(litR, litG, litB))
      local glowThroughMatrix = lerp(1.0 - clamp(preset.matrixGlowResistance, 0.0, 1.0), 1.0, lit)
      local largeMix = lerp(glowThroughMatrix, 1.0, 0.12)
      local halationMix = lerp(glowThroughMatrix, 1.0, 0.18)
      local smallStrength = preset.smallGlow * 1.18
      local largeStrength = preset.largeGlow * 1.14
      local halationStrength = preset.halationStrength * 1.12
      local redGlowScale = 0.94

      r = r + small.r * smallStrength * redGlowScale * glowThroughMatrix
      g = g + small.g * smallStrength * glowThroughMatrix
      b = b + small.b * smallStrength * glowThroughMatrix
      r = r + large.r * largeStrength * redGlowScale * largeMix
      g = g + large.g * largeStrength * largeMix
      b = b + large.b * largeStrength * largeMix
      r = r + large.r * halationStrength * redGlowScale * 0.90 * halationMix
      g = g + large.g * halationStrength * 0.96 * halationMix
      b = b + large.b * halationStrength * halationMix

      r, g, b = applyRgbLeakPixel(r, g, b, beamRows, largeBlur, outWidth, outHeight, x, y, preset)
      r, g, b = gradePixel(r, g, b, x, y, outWidth, outHeight, preset)
      r, g, b = applyBlackFadePixel(r, g, b, preset)
      r, g, b = applyBackdropArtifactsPixel(r, g, b, x, y, preset)
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

local function renderPreviewImageFromPreferences(comparisonOverride)
  ensurePreferences()

  local sprite = app.sprite
  if not sprite then
    return nil, "Open a sprite before rendering an Old TV preview."
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
    return nil, sourceError or "Could not capture the current frame."
  end

  local outWidth = (sourceImage.width * scale) + (margin * 2)
  local outHeight = (sourceImage.height * scale) + (margin * 2)
  local projectedPixels = outWidth * outHeight
  if comparison then
    projectedPixels = projectedPixels * 2.1
  end

  if projectedPixels > MAX_RENDER_PIXELS then
    return nil, "This preview would render about " ..
      tostring(math.floor(projectedPixels)) ..
      " pixels. Lower the scale or enable transparent-bounds crop."
  end

  local sourceRows = readSourceRows(sourceImage, preset)
  local signalRows = buildSignalRows(sourceRows, sourceImage.width, sourceImage.height, preset)
  local crtImage = renderCrtImage(signalRows, sourceImage.width, sourceImage.height, scale, margin, preset)

  if comparison then
    local rawImage = renderRawNearest(sourceRows, sourceImage.width, sourceImage.height, scale, margin, preset)
    crtImage = composeComparison(rawImage, crtImage, preset)
  end

  local status = preset.name .. " | " .. tostring(crtImage.width) .. "x" .. tostring(crtImage.height) .. " | scale " .. tostring(scale)
  return crtImage, nil, status
end

local function renderLivePreviewImageFromPreferences()
  ensurePreferences()

  local sprite = app.sprite
  if not sprite then
    return nil, "Open a sprite before rendering an Old TV preview."
  end

  local prefs = pluginRef.preferences
  local preset = presetById(prefs.presetId)
  local sourceImage, _, sourceError = captureSource(sprite, prefs.cropTransparentBounds == true)
  if not sourceImage then
    return nil, sourceError or "Could not capture the current frame."
  end

  local scale = clampInt(math.min(prefs.scale, QUICK_PREVIEW_LIVE_MAX_SCALE), DEFAULT_SCALE, MIN_SCALE, QUICK_PREVIEW_LIVE_MAX_SCALE)
  local margin = clampInt(math.min(prefs.margin, 6), DEFAULT_MARGIN, 0, 24)
  local outWidth = (sourceImage.width * scale) + (margin * 2)
  local outHeight = (sourceImage.height * scale) + (margin * 2)
  local projectedPixels = outWidth * outHeight

  if projectedPixels > QUICK_PREVIEW_LIVE_MAX_PIXELS then
    local fit = math.sqrt(QUICK_PREVIEW_LIVE_MAX_PIXELS / math.max(sourceImage.width * sourceImage.height, 1))
    scale = clampInt(math.floor(fit), scale, MIN_SCALE, QUICK_PREVIEW_LIVE_MAX_SCALE)
    outWidth = (sourceImage.width * scale) + (margin * 2)
    outHeight = (sourceImage.height * scale) + (margin * 2)
  end

  local sourceRows = readSourceRows(sourceImage, preset)
  local signalRows = buildSignalRows(sourceRows, sourceImage.width, sourceImage.height, preset)
  local crtImage = renderCrtImage(signalRows, sourceImage.width, sourceImage.height, scale, margin, preset)
  local status = "Live CRT | " .. preset.name .. " | " .. tostring(crtImage.width) .. "x" .. tostring(crtImage.height) .. " | scale " .. tostring(scale)
  return crtImage, nil, status
end

local function renderPreviewFromPreferences(comparisonOverride)
  ensurePreferences()

  local sourceSprite = app.sprite
  local comparison = comparisonOverride
  if comparison == nil then
    comparison = pluginRef.preferences.comparison == true
  end
  local preset = presetById(pluginRef.preferences.presetId)

  app.transaction("Render Old TV Preview", function()
    local crtImage, err = renderPreviewImageFromPreferences(comparisonOverride)
    if not crtImage then
      app.alert {
        title = "Old TV Preview",
        text = err or "Could not render the Old TV preview."
      }
      return
    end

    createSpriteFromImage(crtImage, previewName(sourceSprite, preset, comparison))
  end)
end

local showRenderDialog

local function quickPreviewZoom()
  ensurePreferences()
  return clamp(pluginRef.preferences.quickPreviewZoom, QUICK_PREVIEW_MIN_ZOOM, QUICK_PREVIEW_MAX_ZOOM)
end

local function quickPreviewZoomText()
  return tostring(math.floor(quickPreviewZoom() * 100.0 + 0.5)) .. "%"
end

local function quickPreviewCanvasSize(image)
  local zoom = quickPreviewZoom()
  if not image then
    return QUICK_PREVIEW_MIN_WIDTH, QUICK_PREVIEW_MIN_HEIGHT
  end

  return
    clampInt(math.floor(image.width * zoom + 0.5), QUICK_PREVIEW_MIN_WIDTH, QUICK_PREVIEW_MIN_WIDTH, QUICK_PREVIEW_MAX_WIDTH),
    clampInt(math.floor(image.height * zoom + 0.5), QUICK_PREVIEW_MIN_HEIGHT, QUICK_PREVIEW_MIN_HEIGHT, QUICK_PREVIEW_MAX_HEIGHT)
end

local function renderQuickPreviewImage(highQuality)
  quickPreviewRendering = true
  local startTime = os.clock()
  local image, err, status
  quickPreviewHighQuality = highQuality == true
  if quickPreviewHighQuality then
    image, err, status = renderPreviewImageFromPreferences(false)
  else
    image, err, status = renderLivePreviewImageFromPreferences()
  end
  local elapsed = os.clock() - startTime
  quickPreviewRendering = false

  if not image then
    quickPreviewImage = nil
    quickPreviewStatus = err or "Could not render the Old TV preview."
    return false, quickPreviewStatus
  end

  quickPreviewImage = image
  quickPreviewStatus = (status or "Old TV preview rendered.") ..
    " | zoom " .. quickPreviewZoomText() ..
    " | " .. string.format("%.2fs", elapsed)
  return true, nil
end

local function paintQuickPreviewCanvas(ev)
  local gc = ev.context
  gc.antialias = false
  gc.color = Color { r = 10, g = 11, b = 10, a = 255 }
  gc:fillRect(Rectangle(0, 0, gc.width, gc.height))

  if not quickPreviewImage then
    gc.color = Color { r = 220, g = 220, b = 220, a = 255 }
    gc:fillText(quickPreviewStatus ~= "" and quickPreviewStatus or "No CRT preview.", 12, 16)
    return
  end

  local zoom = quickPreviewZoom()
  local drawWidth = math.max(1, math.floor(quickPreviewImage.width * zoom + 0.5))
  local drawHeight = math.max(1, math.floor(quickPreviewImage.height * zoom + 0.5))
  local drawX = math.max(0, math.floor((gc.width - drawWidth) * 0.5))
  local drawY = math.max(0, math.floor((gc.height - drawHeight) * 0.5))

  gc:drawImage(
    quickPreviewImage,
    Rectangle(0, 0, quickPreviewImage.width, quickPreviewImage.height),
    Rectangle(drawX, drawY, drawWidth, drawHeight))
end

local function resizeQuickPreviewCanvas(dialog)
  if not dialog then
    return
  end

  local canvasWidth, canvasHeight = quickPreviewCanvasSize(quickPreviewImage)
  pcall(function()
    dialog:modify {
      id = "previewCanvas",
      width = canvasWidth,
      height = canvasHeight
    }
  end)
end

local function updateQuickPreviewDialogStatus(dialog)
  if not dialog then
    return
  end

  pcall(function()
    dialog:modify {
      id = "status",
      text = quickPreviewStatus
    }
  end)
  pcall(function()
    dialog:modify {
      id = "zoomLabel",
      text = quickPreviewZoomText()
    }
  end)
end

local function refreshQuickPreviewDialog(dialog, highQuality)
  local ok, err = renderQuickPreviewImage(highQuality)
  if not ok then
    app.alert {
      title = "Old TV CRT Preview",
      text = err or "Could not render the Old TV preview."
    }
  end

  if dialog then
    resizeQuickPreviewCanvas(dialog)
    updateQuickPreviewDialogStatus(dialog)
    dialog:repaint()
  end
end

local function stopQuickPreviewTimer()
  if quickPreviewTimer and quickPreviewTimer.isRunning then
    quickPreviewTimer:stop()
  end
end

local function startQuickPreviewTimer()
  if quickPreviewTimer and quickPreviewTimer.isRunning then
    return
  end

  quickPreviewTimer = Timer {
    interval = QUICK_PREVIEW_TIMER_INTERVAL,
    ontick = function()
      if not quickPreviewDialog then
        stopQuickPreviewTimer()
        return
      end

      if quickPreviewDirty and pluginRef.preferences.quickPreviewAutoRefresh == true and not quickPreviewRendering then
        quickPreviewDirty = false
        refreshQuickPreviewDialog(quickPreviewDialog, false)
      end
    end
  }
  quickPreviewTimer:start()
end

local function markQuickPreviewDirty(reason)
  if not quickPreviewDialog then
    return
  end

  ensurePreferences()
  if pluginRef.preferences.quickPreviewAutoRefresh ~= true then
    return
  end

  quickPreviewDirty = true
  if quickPreviewRendering then
    return
  end

  quickPreviewStatus = "Updating live CRT preview..."
  updateQuickPreviewDialogStatus(quickPreviewDialog)
  startQuickPreviewTimer()
end

local function detachQuickPreviewSpriteListener()
  if quickPreviewSprite and quickPreviewSpriteChangeListener and quickPreviewSprite.events then
    pcall(function()
      quickPreviewSprite.events:off(quickPreviewSpriteChangeListener)
    end)
  end

  quickPreviewSprite = nil
  quickPreviewSpriteChangeListener = nil
end

local function attachQuickPreviewSpriteListener(sprite)
  if quickPreviewSprite == sprite and quickPreviewSpriteChangeListener then
    return
  end

  detachQuickPreviewSpriteListener()

  if not sprite or not sprite.events then
    return
  end

  quickPreviewSprite = sprite
  quickPreviewSpriteChangeListener = sprite.events:on("change", function(ev)
    markQuickPreviewDirty("sprite change")
  end)
end

local function syncQuickPreviewSpriteListener()
  if quickPreviewDialog and app.sprite then
    attachQuickPreviewSpriteListener(app.sprite)
  else
    detachQuickPreviewSpriteListener()
  end
end

local function setQuickPreviewZoom(value)
  ensurePreferences()
  pluginRef.preferences.quickPreviewZoom = clamp(value, QUICK_PREVIEW_MIN_ZOOM, QUICK_PREVIEW_MAX_ZOOM)

  if quickPreviewImage then
    quickPreviewStatus = "CRT preview ready | zoom " .. quickPreviewZoomText()
  end

  resizeQuickPreviewCanvas(quickPreviewDialog)
  updateQuickPreviewDialogStatus(quickPreviewDialog)
  if quickPreviewDialog then
    quickPreviewDialog:repaint()
  end
end

local function toggleQuickPreviewWindow()
  if quickPreviewDialog then
    quickPreviewDialog:close()
    quickPreviewDialog = nil
    return
  end

  local ok, err = renderQuickPreviewImage(false)
  if not ok then
    app.alert {
      title = "Old TV CRT Preview",
      text = err or "Could not render the Old TV preview."
    }
    return
  end

  local canvasWidth, canvasHeight = quickPreviewCanvasSize(quickPreviewImage)
  local dlg = Dialog {
    title = "Old TV CRT Preview",
    resizeable = true,
    onclose = function()
      quickPreviewDialog = nil
      quickPreviewDirty = false
      detachQuickPreviewSpriteListener()
      stopQuickPreviewTimer()
    end
  }

  dlg:canvas {
    id = "previewCanvas",
    width = canvasWidth,
    height = canvasHeight,
    autoscaling = false,
    hexpand = true,
    vexpand = true,
    onpaint = paintQuickPreviewCanvas
  }

  dlg:label {
    id = "status",
    text = quickPreviewStatus
  }

  dlg:newrow()

  dlg:check {
    id = "autoRefresh",
    text = "Auto refresh",
    selected = pluginRef.preferences.quickPreviewAutoRefresh == true,
    onclick = function()
      pluginRef.preferences.quickPreviewAutoRefresh = dlg.data.autoRefresh == true
      if pluginRef.preferences.quickPreviewAutoRefresh == true then
        markQuickPreviewDirty("auto refresh enabled")
      end
    end
  }

  dlg:label {
    id = "zoomLabel",
    text = quickPreviewZoomText()
  }

  dlg:button {
    id = "zoomOut",
    text = "-",
    onclick = function()
      setQuickPreviewZoom(quickPreviewZoom() - QUICK_PREVIEW_ZOOM_STEP)
    end
  }

  dlg:button {
    id = "zoomIn",
    text = "+",
    onclick = function()
      setQuickPreviewZoom(quickPreviewZoom() + QUICK_PREVIEW_ZOOM_STEP)
    end
  }

  dlg:button {
    id = "zoomSmall",
    text = "Small",
    onclick = function()
      setQuickPreviewZoom(0.45)
    end
  }

  dlg:button {
    id = "zoom100",
    text = "100%",
    onclick = function()
      setQuickPreviewZoom(1.0)
    end
  }

  dlg:newrow()

  dlg:button {
    id = "refresh",
    text = "Live Refresh",
    onclick = function()
      refreshQuickPreviewDialog(dlg, false)
    end
  }

  dlg:button {
    id = "highQuality",
    text = "HQ Once",
    onclick = function()
      refreshQuickPreviewDialog(dlg, true)
    end
  }

  dlg:button {
    id = "renderSprite",
    text = "Render Sprite",
    onclick = function()
      local okRender, renderErr = pcall(function()
        renderPreviewFromPreferences(false)
      end)
      if not okRender then
        app.alert {
          title = "Old TV Preview",
          text = tostring(renderErr)
        }
      end
    end
  }

  dlg:button {
    id = "settings",
    text = "Settings",
    onclick = showRenderDialog
  }

  dlg:button {
    id = "close",
    text = "Close",
    onclick = function()
      dlg:close()
    end
  }

  quickPreviewDialog = dlg
  syncQuickPreviewSpriteListener()
  startQuickPreviewTimer()
  dlg:show {
    wait = false,
    autoscrollbars = true
  }
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

local function onQuickPreviewSiteChange()
  syncQuickPreviewSpriteListener()
  syncMetalLiveSpriteListener()
  markQuickPreviewDirty("sitechange")
  markMetalLiveDirty("sitechange")
end

local function onQuickPreviewAfterCommand(ev)
  syncQuickPreviewSpriteListener()
  syncMetalLiveSpriteListener()
  markQuickPreviewDirty("aftercommand")
  markMetalLiveDirty("aftercommand")
end

function showRenderDialog()
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
    id = "OldTvPreviewMetalLive",
    title = "Old TV Preview: Metal Live Preview",
    group = "view_controls",
    onclick = toggleMetalLivePreview,
    onenabled = function()
      return app.isUIAvailable and app.sprite ~= nil
    end,
    onchecked = function()
      return metalLiveEnabled
    end
  }

  plugin:newCommand {
    id = "OldTvPreviewQuickPreview",
    title = "Old TV Preview: Lua CRT Preview Window",
    group = "view_controls",
    onclick = toggleQuickPreviewWindow,
    onenabled = function()
      return app.isUIAvailable and app.sprite ~= nil
    end,
    onchecked = function()
      return quickPreviewDialog ~= nil
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

  listeners.sitechange = app.events:on("sitechange", onQuickPreviewSiteChange)
  listeners.aftercommand = app.events:on("aftercommand", onQuickPreviewAfterCommand)
end

function exit(plugin)
  if app and app.events then
    for _, listener in pairs(listeners) do
      pcall(function()
        app.events:off(listener)
      end)
    end
  end

  stopQuickPreviewTimer()
  stopMetalLivePreview()
  detachQuickPreviewSpriteListener()
  if quickPreviewDialog then
    pcall(function()
      quickPreviewDialog:close()
    end)
    quickPreviewDialog = nil
  end

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

  if app.params.live == "1" or app.params.live == "true" then
    local image, err = renderLivePreviewImageFromPreferences()
    if not image then
      error(err or "Could not render live preview smoke test.")
    end
    createSpriteFromImage(image, "old-tv-live-smoke")
  else
    renderPreviewFromPreferences(false)
  end

  local output = app.params["output"]
  if output and output ~= "" and app.sprite then
    app.sprite:saveCopyAs(output)
  end
end

local function runMetalBridgeSmokeTest()
  local input = app.params.input
  if input and input ~= "" then
    app.open(input)
  end

  if not app.sprite then
    local sprite = Sprite(4, 4, ColorMode.RGB)
    local image = Image(4, 4, ColorMode.RGB)
    image:clear(pc.rgba(0, 0, 0, 0))
    image:drawPixel(0, 0, pc.rgba(255, 0, 0, 255))
    image:drawPixel(1, 0, pc.rgba(0, 255, 0, 255))
    image:drawPixel(0, 1, pc.rgba(0, 0, 255, 255))
    image:drawPixel(1, 1, pc.rgba(255, 255, 255, 255))
    sprite.cels[1].image = image
    app.sprite = sprite
  end

  local image = mergedCurrentFrame(app.sprite)
  local sequence = tonumber(app.params.sequence) or 12001
  local ok, err = writeMetalLiveFallback(image, app.sprite, sequence)
  if not ok then
    error(err or "Could not write Old TV Metal bridge smoke frame.")
  end
end

if app.params and (app.params["old-tv-preview-smoke"] == "1" or app.params.old_tv_preview_smoke == "1") then
  runCliSmokeTest()
elseif app.params and (app.params["old-tv-preview-metal-smoke"] == "1" or app.params.old_tv_preview_metal_smoke == "1") then
  runMetalBridgeSmokeTest()
end
