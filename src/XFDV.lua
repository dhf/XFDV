require("graphics")
require("HUD")
require("jjjLib1")

local pluginName = "XFDV"
local boxWidth = 215
local boxHeight = 133
local borderWidth = 1
local showConfigPanel = false
local horizontalMargin = 5
local verticalMargin = 5
local menuBarHeight = 28
local rowCount = 1 -- for future use

if jjjLib1.version == nil or jjjLib1.version() < 1.7 then
    do_every_draw('draw_string(20, SCREEN_HIGHT - 104, "Plugin ' .. pluginName .. ': Requires library \'3jLib1\' version 1.7 or higher! Please search for \'3jLib1\' on x-plane.org, download and install current version of library.")')
    return
end

local pluginId = jjjLib1.getPlId(pluginName)
local panelId = jjjLib1.createPanel(pluginId, "", 320, 'draw_config_panel()', "grey")

if XPLANE_VERSION < 12000 then
    jjjLib1.warning(pluginId, pluginName .. ': This plugin is for X-Plane 12 only!')
    return
end

jjjLib1.addParam(pluginId, "horizontalAlignment", { ["save"] = "global", ["autosave"] = true, ["dflt"] = "R" }, "")
jjjLib1.addParam(pluginId, "verticalAlignment", { ["save"] = "global", ["autosave"] = true, ["dflt"] = "T" }, "")
jjjLib1.addParam(pluginId, "distribution", { ["save"] = "global", ["autosave"] = true, ["dflt"] = "V" }, "")
jjjLib1.addParam(pluginId, "liquidUnit", { ["save"] = "global", ["autosave"] = true, ["dflt"] = "L" }, "")
jjjLib1.addParam(pluginId, "tempUnit", { ["save"] = "global", ["autosave"] = true, ["dflt"] = "C" }, "")
jjjLib1.addParam(pluginId, "showAircraft", { ["save"] = "global", ["autosave"] = true, ["dflt"] = true }, "")
jjjLib1.addParam(pluginId, "showEngine", { ["save"] = "global", ["autosave"] = true, ["dflt"] = true }, "")
jjjLib1.addParam(pluginId, "showWeather", { ["save"] = "global", ["autosave"] = true, ["dflt"] = true }, "")
jjjLib1.addParam(pluginId, "showLocation", { ["save"] = "global", ["autosave"] = true, ["dflt"] = true }, "")
jjjLib1.addParam(pluginId, "showRadio", { ["save"] = "global", ["autosave"] = true, ["dflt"] = true }, "")
jjjLib1.addParam(pluginId, "showAutopilot", { ["save"] = "global", ["autosave"] = true, ["dflt"] = true }, "")

local function get_param(param)
    return jjjLib1.getParam(pluginId, param)
end

local function set_param(param, value)
    jjjLib1.setParam(pluginId, param, value)
end

function xfdv_save_params()
    jjjLib1.saveParams(pluginId)
end

function xfdv_set_params_default()
    jjjLib1.setParamsDefault(pluginId)
end

function xfdv_load_params()
    -- load XFDV settings
    jjjLib1.loadParams(pluginId, "global")

    -- Position
    horizontalAlignment = get_param("horizontalAlignment")
    verticalAlignment = get_param("verticalAlignment")
    distribution = get_param("distribution")
    -- units
    liquidUnit = get_param("liquidUnit")
    tempUnit = get_param("tempUnit")
    -- control visibility of informations
    showAircraft = get_param("showAircraft")
    showEngine = get_param("showEngine")
    showWeather = get_param("showWeather")
    showLocation = get_param("showLocation")
    showRadio = get_param("showRadio")
    showAutopilot = get_param("showAutopilot")
end

function getDataRefs()

    --**GetDatarefValues**
    dataref("paused", "sim/time/paused")
    --Cockpit
    dataref("mainBatteryOn", "sim/cockpit/electrical/battery_on")
    dataref("taxiLight", "sim/cockpit/electrical/taxi_light_on")
    dataref("landingLight", "sim/cockpit/electrical/landing_lights_on")
    dataref("strobeLight", "sim/cockpit/electrical/strobe_lights_on")
    dataref("beaconLight", "sim/cockpit/electrical/beacon_lights_on")
    dataref("navLight", "sim/cockpit/electrical/nav_lights_on")
    dataref("fuelPump", "sim/cockpit/engine/fuel_pump_on", 0, 0)
    dataref("magBearing", "sim/cockpit/misc/compass_indicated")
    dataref("cabinAlt", "sim/cockpit/pressure/cabin_altitude_actual_m_msl")
    dataref("pressureP", "sim/cockpit/misc/barometer_setting")
    dataref("vacuumRatio", "sim/cockpit/misc/vacuum")
    dataref("pitoHeat", "sim/cockpit/switches/pitot_heat_on")

    --Cockpit2
    dataref("avBusOn", "sim/cockpit/electrical/avionics_on")
    dataref("crossTie", "sim/cockpit2/electrical/cross_tie")
    dataref("oilPressure", "sim/cockpit2/engine/indicators/oil_pressure_psi", 0, 0)
    dataref("currentAlt", "sim/cockpit2/gauges/indicators/altitude_ft_pilot")
    dataref("altFtAGL", "sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
    dataref("zuluHours", "sim/cockpit2/clock_timer/zulu_time_hours")
    dataref("zuluMinutes", "sim/cockpit2/clock_timer/zulu_time_minutes")
    dataref("localHours", "sim/cockpit2/clock_timer/local_time_hours")
    dataref("localMinutes", "sim/cockpit2/clock_timer/local_time_minutes")
    dataref("mixture", "sim/cockpit2/engine/actuators/mixture_ratio", 0, 0)
    dataref("engRPMS", "sim/cockpit2/engine/indicators/engine_speed_rpm", 0, 0)
    dataref("fuelAvail", "sim/cockpit2/fuel/fuel_quantity", 0, 0)
    dataref("airSpeed", "sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
    dataref("gndSpeed", "sim/cockpit2/gauges/indicators/ground_speed_kt")
    dataref("fuelFlow", "sim/cockpit2/engine/indicators/fuel_flow_kg_sec", 0, 0)

    --FlightModel
    dataref("parkBrake", "sim/flightmodel/controls/parkbrake")
    dataref("egtC", "sim/flightmodel/engine/ENGN_EGT_c", 0, 0)
    dataref("batteryAmps", "sim/flightmodel/engine/ENGN_bat_amp", 0, 0)
    dataref("batteryVolts", "sim/flightmodel/engine/ENGN_bat_volt", 0, 0)
    dataref("flapsRatio", "sim/flightmodel2/wing/flap1_deg", 0, 0)
    dataref("magVar", "sim/flightmodel/position/magnetic_variation")
    dataref("fuelAvailKgSum", "sim/flightmodel/weight/m_fuel_total")

    --Weather
    dataref("pressureSPas", "sim/weather/region/sealevel_pressure_pas")
    dataref("windSP", "sim/weather/aircraft/wind_speed_kts", "readonly", 0)
    dataref("windDIR", "sim/weather/aircraft/wind_direction_degt", "readonly", 0)
    dataref("ambiTemp", "sim/weather/aircraft/temperature_ambient_deg_c")
    dataref("isaTemp", "sim/weather/region/sealevel_temperature_c")
    dataref("precip", "sim/weather/region/rain_percent")

    dataref("cloudType0", "sim/weather/aircraft/cloud_type", "readonly", 0)
    dataref("cloudType1", "sim/weather/aircraft/cloud_type", "readonly", 1)
    dataref("cloudType2", "sim/weather/aircraft/cloud_type", "readonly", 2)
    dataref("cloudAlt0", "sim/weather/aircraft/cloud_base_msl_m", "readonly", 0)
    dataref("cloudAlt1", "sim/weather/aircraft/cloud_base_msl_m", "readonly", 1)
    dataref("cloudAlt2", "sim/weather/aircraft/cloud_base_msl_m", "readonly", 2)
    dataref("turbulence", "sim/weather/region/turbulence", "readonly", 0)
    --***comment out next three lines to allow real time weather to control turbulence level
    if turbulence >= 0.25 then
        set_array("sim/weather/region/turbulence", 0, 0.13)
    end
    dataref("visibility", "sim/weather/region/visibility_reported_sm")


    --Time
    dataref("simSpeedActual", "sim/time/sim_speed_actual")
    dataref("gpuTime", "sim/time/gpu_time_per_frame_sec_approx")
    dataref("fpsRate", "sim/time/framerate_period")

    --Aircraft
    tailNum = get("sim/aircraft/view/acf_tailnum", 0, 0)
    acftName = get("sim/aircraft/view/acf_ICAO", 0, 0)

    --Autopilot
    dataref("apState", "sim/cockpit/autopilot/autopilot_state")
    dataref("apAnnunciator", "sim/cockpit/warnings/annunciators/autopilot")
    dataref("apVNAVPitch", "sim/cockpit2/autopilot/flight_director_pitch_deg")

    dataref("overVne", "sim/aircraft/view/acf_Vne")
    dataref("overVno", "sim/aircraft/view/acf_Vno")

    -- Radio
    dataref("com1_freq_hz", "sim/cockpit2/radios/actuators/com1_frequency_hz_833")
    dataref("com1_stby_freq_hz", "sim/cockpit2/radios/actuators/com1_standby_frequency_hz_833")
    dataref("com2_freq_hz", "sim/cockpit2/radios/actuators/com2_frequency_hz_833")
    dataref("com2_stby_freq_hz", "sim/cockpit2/radios/actuators/com2_standby_frequency_hz_833")
    dataref("nav1_freq_hz", "sim/cockpit2/radios/actuators/nav1_frequency_hz")
    dataref("nav1_stby_freq_hz", "sim/cockpit2/radios/actuators/nav1_standby_frequency_hz")
    dataref("nav2_freq_hz", "sim/cockpit2/radios/actuators/nav2_frequency_hz")
    dataref("nav2_stby_freq_hz", "sim/cockpit2/radios/actuators/nav2_standby_frequency_hz")
    dataref("adf1_freq_hz", "sim/cockpit2/radios/actuators/adf1_frequency_hz")
    dataref("adf1_stby_freq_hz", "sim/cockpit2/radios/actuators/adf1_standby_frequency_hz")

    -- Transponder
    dataref("xpdr", "sim/cockpit/radios/transponder_code")
    dataref("xpdrMode", "sim/cockpit/radios/transponder_mode")

    -- GPS
    dataref("gpsNavID0", "sim/cockpit2/radios/indicators/gps_nav_id", 0, 0)

    --End of Datarefs
end

local function round(num)
    return num + (2 ^ 52 + 2 ^ 51) - (2 ^ 52 + 2 ^ 51)
end

local function draw_switch(isOn, label, x, y)
    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_circle(x + 3, y + 3, 4)
    if isOn then
        graphics.set_color(0, 1, 0, .5)
    else
        graphics.set_color(0, 0, 0, .425)
    end
    graphics.draw_filled_circle(x + 3, y + 3, 3)
    draw_string(x + 9, y, label, 1, 1, 1)
end

local function draw_fill_rect(left, top, length, height, rBorder, gBorder, bBorder, alphaBorder, lineWidth, rFill, gFill, bFill, alphaFill)
    graphics.set_color(rBorder, gBorder, bBorder, alphaBorder)
    graphics.draw_rectangle(left, top, left + length, top - height)
    graphics.set_color(rFill, gFill, bFill, alphaFill)
    graphics.draw_rectangle(left + lineWidth, top - lineWidth, left + length - lineWidth, top - height + lineWidth)
end

local function draw_fill_rect_text_center(left, top, length, height, rBorder, gBorder, bBorder, alphaBorder,
                                          lineWidth, rFill, gFill, bFill, alphaFill,
                                          text, rText, gText, bText, showText)
    draw_fill_rect(left, top, length, height, rBorder, gBorder, bBorder, alphaBorder, lineWidth, rFill, gFill, bFill, alphaFill)
    local strLen = measure_string(text)
    if showText then
        draw_string(left + ((length - strLen) / 2), top - (height / 2 + 3), text, rText, gText, bText)
    end
end

local function draw_fill_rect_text_left(left, top, length, height, rBorder, gBorder, bBorder, alphaBorder,
                                        lineWidth, rFill, gFill, bFill, alphaFill,
                                        text, rText, gText, bText, showText)
    draw_fill_rect(left, top, length, height, rBorder, gBorder, bBorder, alphaBorder, lineWidth, rFill, gFill, bFill, alphaFill)
    if showText then
        draw_string(left + 4, top - 10, text, rText, gText, bText)
    end
end

local function draw_fill_rect_text_right(left, top, length, height, rBorder, gBorder, bBorder, alphaBorder,
                                         lineWidth, rFill, gFill, bFill, alphaFill,
                                         text, rText, gText, bText, showText)
    draw_fill_rect(left, top, length, height, rBorder, gBorder, bBorder, alphaBorder, lineWidth, rFill, gFill, bFill, alphaFill)
    if showText then
        local strLen = measure_string(text)
        draw_string(left + (length - strLen - 4), top - 10, text, rText, gText, bText)
    end
end

local function condIf ( cond , T , F )
    if cond then return T else return F end
end

local function active_box_count()
    local boxCount = 0
    boxCount =  boxCount + condIf(showAircraft, 1, 0)
    boxCount =  boxCount + condIf(showEngine, 1, 0)
    boxCount =  boxCount + condIf(showWeather, 1, 0)
    boxCount =  boxCount + condIf(showLocation, 1, 0)
    boxCount =  boxCount + condIf(showRadio, 1, 0)
    boxCount =  boxCount + condIf(showAutopilot, 1, 0)
    return boxCount
end

local function calc_positions()
    local boxPositions = {}
    local boxCount = active_box_count()
    if rowCount == 1 then
        if distribution == "H" then
            for i = 0, (boxCount - 1) do
                if horizontalAlignment == "L" then
                    lx = horizontalMargin + (i * (boxWidth - borderWidth))
                else
                    lx = SCREEN_WIDTH - horizontalMargin - ((i + 1) * (boxWidth - borderWidth))
                end

                if verticalAlignment == "T" then
                    ly = SCREEN_HEIGHT - menuBarHeight - verticalMargin
                else
                    ly = verticalMargin + boxHeight
                end
                table.insert(boxPositions, {lx, ly})
            end
        else
            for i = 0, (boxCount - 1) do
                if horizontalAlignment == "L" then
                    lx = horizontalMargin
                else
                    lx = SCREEN_WIDTH - horizontalMargin - boxWidth
                end

                if verticalAlignment == "T" then
                    ly = SCREEN_HEIGHT - menuBarHeight - verticalMargin - (i * (boxHeight - borderWidth))
                else
                    ly = verticalMargin + ((boxCount - (i + 1)) * (boxHeight - borderWidth))
                end
                table.insert(boxPositions, {lx, ly})
            end
        end
    else
        -- for future use...
    end
    return boxPositions
end

function show_flight_data()
    local boxCount = 1
    local curPos = { }
    local positions = calc_positions()

    if showAircraft or showEngine then
        calc_fuel_data()
    end
    if showAircraft or showWeather or showLocation then
        calc_weather_data()
    end

    if showAircraft then
        curPos = positions[boxCount]
        draw_aircraft(curPos[1], curPos[2])
        boxCount = boxCount + 1
    end
    if showEngine then
        curPos = positions[boxCount]
        draw_engine(curPos[1], curPos[2])
        boxCount = boxCount + 1
    end
    if showWeather then
        curPos = positions[boxCount]
        draw_weather(curPos[1], curPos[2])
        boxCount = boxCount + 1
    end
    if showLocation then
        curPos = positions[boxCount]
        draw_location(curPos[1], curPos[2])
        boxCount = boxCount + 1
    end
    if showRadio then
        curPos = positions[boxCount]
        draw_radio(curPos[1], curPos[2])
        boxCount = boxCount + 1
    end
    if showAutopilot then
        -- draw_autopilot()
    end

    local yPosCloseButton = positions[1][2]
    if horizontalAlignment == "L" then
        draw_close_button(horizontalMargin, yPosCloseButton)
    else
        draw_close_button(SCREEN_WIDTH - horizontalMargin - 10, yPosCloseButton)
    end
end

function calc_fuel_data()
    --Calculate fuel data
    local fuelAvailLiter = fuelAvailKgSum * 1.34603
    local fuelAvailGal = fuelAvailKgSum * 0.35558
    local fuelFlowHourKg = fuelFlow * 60 * 60
    local fuelFlowHourLiter = fuelFlowHourKg * 1.34603
    local fuelFlowHourGal = fuelFlowHourKg * 0.35558

    if liquidUnit == "G" then
        fuelAvail = fuelAvailGal
        fuelFlowHour = fuelFlowHourGal
        fuelRemain = fuelAvailGal / fuelFlowHourGal
        fuelUnit = "Gal"
    else
        fuelAvail = fuelAvailLiter
        fuelFlowHour = fuelFlowHourLiter
        fuelRemain = fuelAvailLiter / fuelFlowHourLiter
        fuelUnit = "Ltr"
    end
    -- Limit fuel hours remaining if engine is not running (for display purproses only)
    if fuelRemain >= 20 then
        fuelRemain = 20
    end
end

function calc_weather_data()
    --atm pressure
    ckPressure = 0
    pressureS = pressureSPas / 3386.3886666667
    pressureCk = pressureS - pressureP

    if pressureCk < 0 then
        pressureCk = pressureCk * -1
    end
    if pressureCk > .009 then
        ckPressure = 1
    end
end

function draw_close_button(left, top)
    draw_fill_rect_text_center(left, top, 10, 10, .6, .6, .6, .5,
            1, 1, 0, 0, .5,
            "x", 1, 1, 0, true)
end

function draw_location(boxLeft, boxTop)
    draw_fill_rect(boxLeft, boxTop, boxWidth, boxHeight, .9, .9, .9, .325,
            1, .1, .1, .1, .425)

    left = boxLeft + 10
    top = boxTop - 5

    acftLat = LATITUDE
    acftLong = LONGITUDE
    --time
    zuluHours = string.format("%02d", zuluHours)
    zuluMinutes = string.format("%02d", zuluMinutes)
    localHours = string.format("%02d", localHours)
    localMinutes = string.format("%02d", localMinutes)
    --
    ambiTempF = (ambiTemp * 9 / 5) + 32

    --Conditionals
    if acftLat > 0 then
        nsLat = "N"
    else
        nsLat = "S"
    end

    if acftLong < 0 then
        ewLong = "W"
    else
        ewLong = "E"
    end

    if airSpeed <= 0 or round(gndSpeed) == 0 then
        airSpeed = 0
        altFtAGL = 0
    end

    --Time and Location
    draw_string(left, top - 10, "Location Information", .9, .9, .2)
    draw_string(left, top - 23, "Time", .9, .9, .9)
    draw_string(left, top - 38, "Location", .9, .9, .9)
    draw_string(left, top - 53, "Atm.Pr.", .9, .9, .9)
    draw_string(left, top - 68, "OAT/ISA", .9, .9, .9)

    draw_fill_rect_text_center(left + 49, top - 13, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            zuluHours .. ":" .. zuluMinutes .. " GMT", 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 120, top - 13, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            localHours .. ":" .. localMinutes .. " LCL", 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 49, top - 28, 143, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.3f', acftLat) .. nsLat .. " , " .. string.format('%.3f', acftLong) .. ewLong, 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 49, top - 43, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.2f', pressureP) .. " Set", 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 120, top - 43, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.2f', pressureS) .. " SL", 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 49, top - 58, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%04.1f°C', ambiTemp), 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 120, top - 58, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%04.1f°C', isaTemp), 0, 1, 0, batteryOn)

    -- inline draw simulator info
    draw_simulator_inline(left, top - 75)
end

function draw_av_measurements_inline(left, top)
    draw_string(left, top - 10, "Aviation Measurements", .9, .9, .2)
    draw_string(left, top - 23, "AirSp.", .9, .9, .9)
    draw_string(left, top - 38, "GndSp.", .9, .9, .9)
    draw_string(left + 103, top - 23, "Bear.", .9, .9, .9)
    draw_string(left + 103, top - 38, "Alt.", .9, .9, .9)

    --Airspeed
    if airSpeed >= overVne then
        draw_fill_rect_text_center(left + 49, top - 13, 47, 14, .6, .6, .6, .5,
                1, 1, 0, 0, .45,
                string.format('%.0fKts', airSpeed), 1, 1, 0, batteryOn)
    elseif airSpeed >= overVno then
        draw_fill_rect_text_center(left + 49, top - 13, 47, 14, .6, .6, .6, .5,
                1, 1, 1, 0, .625,
                string.format('%.0fKts', airSpeed), 1, 0, 0, batteryOn)
    elseif airSpeed >= 69.5 and airSpeed < overVno then
        draw_fill_rect_text_center(left + 49, top - 13, 47, 14, .6, .6, .6, .5,
                1, 0, 0, 0, .425,
                string.format('%.0fKts', airSpeed), 0, 1, 0, batteryOn)
    elseif airSpeed >= 49.5 and airSpeed < 69.5 then
        draw_fill_rect_text_center(left + 49, top - 13, 47, 14, .6, .6, .6, .5,
                1, 1, 1, 0, .6,
                string.format('%.0fKts', airSpeed), 0, 0, 0, batteryOn)
    elseif airSpeed > 0 and airSpeed < 49.5 then
        draw_fill_rect_text_center(left + 49, top - 13, 47, 14, .6, .6, .6, .5,
                1, 1, 0, 0, .45,
                string.format('%.0fKts', airSpeed), 1, 1, 0, batteryOn)
    elseif airSpeed == 0 then
        draw_fill_rect_text_center(left + 49, top - 13, 47, 14, .6, .6, .6, .5,
                1, 0, 0, 0, .425,
                "OnGrnd", 1, 1, 0, batteryOn)
    end

    --Ground speed
    if round(gndSpeed) > 0 then
        draw_fill_rect_text_center(left + 49, top - 28, 47, 14, .6, .6, .6, .5,
                1, 0, 0, 0, .425,
                string.format('%.0fKts', gndSpeed), 0, 1, 0, batteryOn)
    else
        draw_fill_rect_text_center(left + 49, top - 28, 47, 14, .6, .6, .6, .5,
                1, 0, 0, 0, .425,
                "OnGrnd", 1, 1, 0, batteryOn)
    end

    --Bearing
    draw_fill_rect_text_center(left + 134, top - 13, 58, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%05.1fDeg', magBearing), 0, 1, 0, batteryOn)

    -- display Altitude AGL based on current value
    if altFtAGL > 1500 then
        draw_fill_rect_text_center(left + 134, top - 28, 58, 14, .6, .6, .6, .5,
                1, 0, 0, 0, .425,
                string.format('%.0fFt', altFtAGL), 0, 1, 0, batteryOn)
    elseif altFtAGL > 999.5 and altFtAGL <= 1500 then
        draw_fill_rect_text_center(left + 134, top - 28, 58, 14, .6, .6, .6, .5,
                1, 0, 1, 0, .6,
                string.format('%.0fFt', altFtAGL), 0, 0, 0, batteryOn)
    elseif altFtAGL > 499.5 and altFtAGL <= 999.5 then
        draw_fill_rect_text_center(left + 134, top - 28, 58, 14, .6, .6, .6, .5,
                1, 1, 1, 0, .625,
                string.format('%.0fFt', altFtAGL), 0, 0, 0, batteryOn)
    elseif altFtAGL > 99.5 and altFtAGL <= 499.5 then
        draw_fill_rect_text_center(left + 134, top - 28, 58, 14, .6, .6, .6, .5,
                1, 1, 1, 0, .625,
                string.format('%.0fFt', altFtAGL), 1, 0, 0, batteryOn)
    elseif altFtAGL <= 99.5 and altFtAGL ~= 0 then
        draw_fill_rect_text_center(left + 134, top - 28, 58, 14, .6, .6, .6, .5,
                1, 1, 0, 0, .6,
                string.format('%.0fFt', altFtAGL), 1, 1, 0, batteryOn)
    else
        draw_fill_rect_text_center(left + 134, top - 28, 58, 14, .6, .6, .6, .5,
                1, 0, 0, 0, .425,
                "OnGrnd", 1, 1, 0, batteryOn)
    end
end

function draw_aircraft(boxLeft, boxTop)
    draw_fill_rect(boxLeft, boxTop, boxWidth, boxHeight, .9, .9, .9, .325,
            1, .1, .1, .1, .425)

    left = boxLeft + 10
    top = boxTop - 5
    --Aircraft information
    draw_string(left, top - 10, "AIRCRAFT", .9, .9, .2)
    draw_fill_rect_text_center(left + 59, top, 67, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            acftName, 1, 1, 0, true)
    draw_fill_rect_text_center(left + 59 + 66, top, 67, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            tailNum, 1, 1, 0, true)

    --Switches
    draw_fill_rect(left, top - 16, 192, 43, .6, .6, .6, .5, 1, 0, 0, 0, .425)
    draw_switch(batteryOn and taxiLight ~= 0, "Taxi LT", left + 3, top - 26)
    draw_switch(batteryOn and landingLight ~= 0, "Land LT", left + 72, top - 26)
    draw_switch(batteryOn and navLight ~= 0, "Nav LT", left + 138, top - 26)
    draw_switch(batteryOn and strobeLight ~= 0, "Strobe", left + 3, top - 40)
    draw_switch(batteryOn and beaconLight ~= 0, "Beacon", left + 72, top - 40)
    draw_switch(batteryOn and fuelPump ~= 0, "Fuel P.", left + 3, top - 54)
    draw_switch(batteryOn and pitoHeat ~= 0, "Pitot Ht", left + 72, top - 54)

    --Display electrical and engine info
    draw_string(left, top - 70, "Main Battery", .9, .9, .9)
    draw_string(left, top - 87, "Oil Pressure", .9, .9, .9)
    draw_string(left, top - 103, "Vacuum Press", .9, .9, .9)
    if batteryOn and batteryAmps <= -0.0 then
        draw_fill_rect_text_center(left + 77, top - 61, 58, 14, .6, .6, .6, .5,
                1, 1, 0, 0, .8,
                string.format('%.1fA', batteryAmps), 1, 1, 0, batteryOn)
    else
        draw_fill_rect_text_center(left + 77, top - 61, 58, 14, .6, .6, .6, .5,
                1, 0, 0, 0, .425,
                string.format('%.1fA', batteryAmps), 0, 1, 0, batteryOn)
    end
    draw_fill_rect_text_center(left + 134, top - 61, 58, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.1fV', batteryVolts), 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 77, top - 77, 58, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.2f', oilPressure), 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 77, top - 93, 58, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%02.2f', vacuumRatio), 0, 1, 0, batteryOn)

    --Parking brake info
    draw_string(left, top - 119, "Parking Brake", .9, .9, .9)

    if parkBrake == 1 then
        draw_fill_rect_text_center(left + 77, top - 109, 35, 14, .6, .6, .6, .5,
                1, 1, 0, 0, .6,
                "ON", 1, 1, 0, true)
    elseif parkBrake == 0 then
        draw_fill_rect_text_center(left + 77, top - 109, 35, 14, .6, .6, .6, .5,
                1, 0, .8, 0, .75,
                "OFF", 0, 0, 0, true)
    else
        draw_fill_rect_text_center(left + 77, top - 109, 35, 14, .6, .6, .6, .5,
                1, 0, 0, .725, .5,
                string.format('%02.0f%%', parkBrake * 100), 1, 1, 0, true)
    end

    --Flaps
    draw_string(left + 122, top - 119, "Flaps", .9, .9, .9)

    --display data only if the battery is on
    if flapsRatio == 0 then
        draw_fill_rect_text_center(left + 157, top - 109, 35, 14, .6, .6, .6, .5,
                1, 0, 0, 0, .425,
                string.format('%02.0f%%', flapsRatio), 0, 1, 0, batteryOn)
    else
        draw_fill_rect_text_center(left + 157, top - 109, 35, 14, .6, .6, .6, .5,
                1, 0, 0, .725, .5,
                string.format('%02.0f%%', flapsRatio), 1, 1, 0, batteryOn)
    end
end

function draw_weather(boxLeft, boxTop)
    draw_fill_rect(boxLeft, boxTop, boxWidth, boxHeight, .9, .9, .9, .325,
            1, .1, .1, .1, .425)

    left = boxLeft + 10
    top = boxTop - 5
    --Set cloud types for display
    --Cloud Types: Clear = 0, High Cirrus = 1, Scattered = 2, Broken = 3, Overcast = 4, Stratus = 5
    local cloudType_tbl = {
        [0] = "Clear",
        [1] = "High Cirrus",
        [2] = "Scattered",
        [3] = "Broken",
        [4] = "Overcast",
        [5] = "Stratus",
    }
    local clType0 = cloudType_tbl[round(cloudType0)]
    local clType1 = cloudType_tbl[round(cloudType1)]
    local clType2 = cloudType_tbl[round(cloudType2)]

    --Miscellaneous Calculations
    --weather
    windMPH = 1.15 * math.ceil(windSP)
    --visibility
    visMiles = visibility * 0.000621371

    --Display weather data
    draw_string(left, top - 10, "Weather Data", .9, .9, .2)

    --wind dir box
    draw_string(left, top - 23, "Wind", .9, .9, .9)
    draw_string(left + 69, top - 23, "at", .9, .9, .9)
    draw_fill_rect_text_center(left + 32, top - 13, 31, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%03.0f', math.ceil(windDIR)), 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 83, top - 13, 46, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%02.0f', math.ceil(windSP)) .. " Kts", 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 128, top - 13, 46, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%02.0f', math.ceil(windMPH)) .. " Mph", 0, 1, 0, batteryOn)

    --Turbulence/Precip/Visibility
    draw_string(left, top - 39, "Turb.", .9, .9, .9)
    draw_string(left + 63, top - 39, "Precip.", .9, .9, .9)
    draw_string(left + 124, top - 39, "Vis.", .9, .9, .9)

    draw_fill_rect_text_center(left + 32, top - 29, 25, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.1f', turbulence), 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 101, top - 29, 17, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.0f', precip), 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 145, top - 29, 29, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.0f', visMiles), 0, 1, 0, batteryOn)

    draw_string(left, top - 53, "Clouds at Alt.", .9, .9, .9)
    draw_string(left + 90, top - 53, "Type", .9, .9, .9)
    draw_fill_rect_text_center(left, top - 57, 87, 14, .6, .6, .6, .5,
            1, .1, .1, .3, .45,
            string.format('%05.0f', cloudAlt2 * 3.28), .9, .9, .9, batteryOn)
    draw_fill_rect_text_center(left, top - 70, 87, 14, .6, .6, .6, .5,
            1, .1, .1, .6, .35,
            string.format('%05.0f', cloudAlt1 * 3.28), .9, .9, .9, batteryOn)
    draw_fill_rect_text_center(left, top - 83, 87, 14, .6, .6, .6, .5,
            1, .1, .1, .9, .25,
            string.format('%05.0f', cloudAlt0 * 3.28), .9, .9, .9, batteryOn)
    draw_fill_rect_text_left(left + 86, top - 57, 88, 14, .6, .6, .6, .5,
            1, .0, .0, .0, .45,
            clType2, 0, 1, 0, batteryOn)
    draw_fill_rect_text_left(left + 86, top - 70, 88, 14, .6, .6, .6, .5,
            1, .1, .1, .1, .35,
            clType1, 0, 1, 0, batteryOn)
    draw_fill_rect_text_left(left + 86, top - 83, 88, 14, .6, .6, .6, .5,
            1, .2, .2, .2, .25,
            clType0, 0, 1, 0, batteryOn)
end

function draw_simulator_inline(left, top)
    fps = 1 / fpsRate
    draw_string(left, top - 10, "Simulator Data", .9, .9, .2)
    draw_string(left, top - 23, "FPS/GPU", .9, .9, .9)
    -- draw_string(left + 95, top - 23, "GPU", .9, .9, .9)

    if fps <= 18 then
        draw_fill_rect_text_center(left + 49, top - 13, 72, 14, .6, .6, .6, .5,
                1, 1, 0, 0, .5,
                string.format('%3.0f', fps), 1, 1, 0, true)
    else
        draw_fill_rect_text_center(left + 49, top - 13, 72, 14, .6, .6, .6, .5,
                1, 0, 0, 0, .425,
                string.format('%3.0f', fps), 0, 1, 0, true)
    end
    draw_fill_rect_text_center(left + 120, top - 13, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.3f', gpuTime), 0, 1, 0, true)
end

function draw_engine(boxLeft, boxTop)
    draw_fill_rect(boxLeft, boxTop, boxWidth, boxHeight, .9, .9, .9, .325,
            1, .1, .1, .1, .425)

    left = boxLeft + 10
    top = boxTop - 5
    -- egt Temperature
    if tempUnit == "F" then
        egtValue = (egtC * 9 / 5) + 32
    else
        egtValue = egtC
    end

    if engRPMS < 1 then
        engRPMS = 0
    end

    --Display engine data
    draw_string(left, top - 10, "Engine Performance", .9, .9, .2)
    draw_string(left, top - 23, "Mixture", .9, .9, .9)
    draw_string(left + 49, top - 23, "RPM", .9, .9, .9)
    draw_string(left + 85, top - 23, "EGT", .9, .9, .9)
    draw_string(left + 134, top - 23, "Fuel Status", .9, .9, .9)

    draw_fill_rect_text_center(left, top - 28, 46, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%02.0f%%', (mixture * 100)), 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 45, top - 28, 39, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%04.0f', engRPMS), 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 82, top - 28, 52, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.0f°%s', egtValue, tempUnit), 0, 1, 0, batteryOn)

    if fuelRemain <= 0.5 then
        draw_fill_rect_text_center(left + 132, top - 28, 60, 14, .6, .6, .6, .5,
                1, 1, 1, 0, .6,
                "FUEL!!", 1, 0, 1, batteryOn)
    elseif fuelRemain <= 1.0 then
        draw_fill_rect_text_center(left + 132, top - 28, 60, 14, .6, .6, .6, .5,
                1, 1, 1, 0, .6,
                "CHECK", 0, 0, 0, batteryOn)
    else
        draw_fill_rect_text_center(left + 132, top - 28, 60, 14, .6, .6, .6, .5,
                1, 0, 0, 0, .425,
                "OK", 0, 1, 0, batteryOn)
    end

    draw_string(left, top - 53, "Flow Rate", .9, .9, .9)
    draw_string(left + 69, top - 53, "Time", .9, .9, .9)
    draw_string(left + 119, top - 53, "Fuel On Board", .9, .9, .9)
    draw_fill_rect_text_center(left, top - 58, 68, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.1f %s/h', fuelFlowHour, fuelUnit), 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 67, top - 58, 52, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.1f hrs', fuelRemain), 0, 1, 0, batteryOn)
    draw_fill_rect_text_center(left + 118, top - 58, 74, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.1f %s', fuelAvail, fuelUnit), 0, 1, 0, batteryOn)

    -- inline draw av measurements
    draw_av_measurements_inline(left, top - 75)
end

function draw_radio(boxLeft, boxTop)
    draw_fill_rect(boxLeft, boxTop, boxWidth, boxHeight, .9, .9, .9, .325,
            1, .1, .1, .1, .425)

    left = boxLeft + 10
    top = boxTop - 5
    --Radios (data provided by require "radio" module)
    com1 = com1_freq_hz / 1000
    com2 = com2_freq_hz / 1000
    nav1 = nav1_freq_hz / 100
    nav2 = nav2_freq_hz / 100
    com1S = com1_stby_freq_hz / 1000
    com2S = com2_stby_freq_hz / 1000
    nav1S = nav1_stby_freq_hz / 100
    nav2S = nav2_stby_freq_hz / 100
    adf1 = adf1_freq_hz
    adf1S = adf1_stby_freq_hz

    local xpdrMode_tbl = {
        [0] = "OFF",
        [1] = "STDBY",
        [2] = "ON",
        [3] = "ALT",
        [4] = "TEST",
        [5] = "GND",
        [6] = "ta_only",
        [7] = "ta/ra",
    }
    xpMode = xpdrMode_tbl[xpdrMode]

    --radio stack labels
    draw_string(left + 70, top - 11, "Active", .9, .9, .9)
    draw_string(left + 141, top - 11, "Stdby", .8, .8, .8)

    --Radios
    draw_string(left, top - 10, "Radios", .9, .9, .2)
    draw_string(left, top - 23, "COM1", .9, .9, .9)
    draw_string(left, top - 38, "COM2", .9, .9, .9)
    draw_string(left, top - 55, "NAV1", .9, .9, .9)
    draw_string(left, top - 70, "NAV2", .9, .9, .9)
    draw_string(left, top - 87, "ADF1", .9, .9, .9)
    draw_string(left, top - 102, "XPDR", .9, .9, .9)
    draw_string(left, top - 119, "Nxt GPS Wpt", .9, .9, .9)

    draw_fill_rect_text_center(left + 49, top - 13, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.3f', com1), 0, 1, 0, batteryOn and avBusOn == 1)
    draw_fill_rect_text_center(left + 120, top - 13, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.3f', com1S), 0, .7, 0, batteryOn and avBusOn == 1)
    draw_fill_rect_text_center(left + 49, top - 28, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.3f', com2), 0, 1, 0, batteryOn and avBusOn == 1)
    draw_fill_rect_text_center(left + 120, top - 28, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.3f', com2S), 0, .7, 0, batteryOn and avBusOn == 1)
    draw_fill_rect_text_center(left + 49, top - 45, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.2f', nav1), 0, 1, 0, batteryOn and avBusOn == 1)
    draw_fill_rect_text_center(left + 120, top - 45, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.2f', nav1S), 0, .7, 0, batteryOn and avBusOn == 1)
    draw_fill_rect_text_center(left + 49, top - 60, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.2f', nav2), 0, 1, 0, batteryOn and avBusOn == 1)
    draw_fill_rect_text_center(left + 120, top - 60, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            string.format('%.2f', nav2S), 0, .7, 0, batteryOn and avBusOn == 1)
    draw_fill_rect_text_center(left + 49, top - 77, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            adf1, 0, 1, 0, batteryOn and avBusOn == 1)
    draw_fill_rect_text_center(left + 120, top - 77, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            adf1S, 0, .7, 0, batteryOn and avBusOn == 1)
    draw_fill_rect_text_center(left + 49, top - 92, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            xpdr, 0, 1, 0, batteryOn and avBusOn == 1 and xpMode ~= "OFF")
    draw_fill_rect_text_center(left + 120, top - 92, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            xpMode, 0, 1, 0, batteryOn and avBusOn == 1)
    draw_fill_rect_text_center(left + 120, top - 109, 72, 14, .6, .6, .6, .5,
            1, 0, 0, 0, .425,
            gpsNavID0, 0, 1, 0, batteryOn and avBusOn == 1)
end

function draw_autopilot()
    --Autopilot
    draw_string(467, 96, "Autopilot", 1, 1, 0)

    --power indicator
    draw_string(467, 81, "Pwr", 1, 1, 1)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(490, 78, 502, 91)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(491, 79, 501, 90)

    --standby indicator
    draw_string(505, 81, "Stdby", 1, 1, 1)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(539, 78, 551, 91)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(540, 79, 550, 90)

    if apAnnunciator == 0 and apState ~= 132 then
        -- show ap in standby mode
        graphics.set_color(.1, 1, .1, .825)
        graphics.draw_rectangle(540, 79, 550, 90)
    end

    --engaged indicator
    draw_string(554, 81, "Engd", 1, 1, 1)
    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(586, 78, 599, 91)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(587, 79, 598, 90)

    if apAnnunciator == 1 then
        -- show ap engaged
        graphics.set_color(.1, 1, .1, .825)
        graphics.draw_rectangle(587, 79, 598, 90)
    end

    --mode panel
    draw_string(467, 68, "Mode", 1, 1, 1)
    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(465, 50, 601, 64)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(466, 51, 600, 63)

    if avBusOn == 1 then
        --display data only if the avionics bus is on
        draw_string(467, 54, "HDG", .3, .3, .3)
        draw_string(493, 54, "NAV", .3, .3, .3)
        draw_string(518, 54, "APR", .3, .3, .3)
        draw_string(543, 54, "ALT", .3, .3, .3)
        draw_string(566, 54, "GS", .3, .3, .3)
        draw_string(584, 54, "VS", .3, .3, .3)

        graphics.set_color(.1, 1, .1, .825)
        graphics.draw_rectangle(491, 79, 502, 90)

        --determine autopilot state and adjust display accordingly
        if apState == 18 then
            draw_string(467, 54, "HDG", .1, 1, .1)
            draw_string(584, 54, "VS", .1, 1, .1)
        elseif apState == 20 then
            draw_string(584, 54, "VS", .1, 1, .1)
        elseif apState == 130 or apState == 276 or apState == 386 or apState == 388 then
            draw_string(467, 54, "HDG", .1, 1, .1)
        elseif apState == 528 then
            draw_string(493, 54, "NAV", .1, 1, .1)
            draw_string(584, 54, "VS", .1, 1, .1)
        elseif apState == 640 then
            draw_string(493, 54, "NAV", .1, 1, .1)
        elseif apState == 1044 then
            draw_string(566, 54, "GS", .1, 1, .1)
            draw_string(584, 54, "VS", .1, 1, .1)
        elseif apState == 1042 then
            draw_string(467, 54, "HDG", .1, 1, .1)
            draw_string(566, 54, "GS", .1, 1, .1)
            draw_string(584, 54, "VS", .1, 1, .1)
        elseif apState == 1154 then
            draw_string(467, 54, "HDG", .1, 1, .1)
            draw_string(566, 54, "GS", .1, 1, .1)
        elseif apState == 1156 then
            draw_string(566, 54, "GS", .1, 1, .1)
        elseif apState == 1410 then
            draw_string(467, 54, "HDG", .1, 1, .1)
            draw_string(493, 54, "NAV", .1, 1, .1)
            draw_string(518, 54, "APR", .1, 1, .1)
            draw_string(566, 54, "GS", .1, 1, .1)
        elseif apState == 1412 or apState == 1664 then
            draw_string(493, 54, "NAV", .1, 1, .1)
            draw_string(518, 54, "APR", .1, 1, .1)
            draw_string(566, 54, "GS", .1, 1, .1)
        elseif apState == 16386 then
            draw_string(467, 54, "HDG", .1, 1, .1)
            draw_string(543, 54, "ALT", .1, 1, .1)
        elseif apState == 17410 then
            draw_string(467, 54, "HDG", .1, 1, .1)
            draw_string(543, 54, "ALT", .1, 1, .1)
            draw_string(566, 54, "GS", .1, 1, .1)
        elseif apState == 16388 or apState == 16644 then
            draw_string(543, 54, "ALT", .1, 1, .1)
        elseif apState == 16896 then
            draw_string(493, 54, "NAV", .1, 1, .1)
            draw_string(543, 54, "ALT", .1, 1, .1)
        elseif apState == 17412 then
            draw_string(539, 54, "ALT", .1, 1, .1)
            draw_string(566, 54, "GS", .1, 1, .1)
        elseif apState == 17920 or apState == 17668 then
            draw_string(493, 54, "NAV", .1, 1, .1)
            draw_string(518, 54, "APR", .1, 1, .1)
            draw_string(543, 54, "ALT", .1, 1, .1)
            draw_string(566, 54, "GS", .1, 1, .1)
        end
    end
end

local function draw_warning_msg(value, showConfigButton)
    local x = (SCREEN_WIDTH / 2) - 100
    local xConf = (SCREEN_WIDTH / 2) - 50
    local y = verticalMargin + 16
    local yConf = verticalMargin + 16 + 16
    if verticalAlignment == "T" then
        y = SCREEN_HEIGHT - menuBarHeight - verticalMargin
        yConf = SCREEN_HEIGHT - menuBarHeight - verticalMargin - 16
    end
    if showConfigButton then
        draw_fill_rect_text_center(xConf, yConf, 100, 16, .6, .6, .6, .5,
                1, 1, 0, 0, .5,
                "Configure XFDV", 1, 1, 0, true)
    end

    draw_fill_rect_text_center(x, y, 200, 16, .6, .6, .6, .5,
            1, .7, .7, .1, .6,
            "XFDV: " .. value, 1, 0, 0, true)
end

local function draw_pause_msg()
    draw_warning_msg("** SIMULATOR PAUSED **", true)
end

local function draw_battery_msg()
    draw_warning_msg("NO POWER! - Turn Battery On", false)
end

function xfdv_set_horizontal_alignment(value)
    horizontalAlignment = value
    set_param("horizontalAlignment", value)
end

function xfdv_set_vertical_alignment(value)
    verticalAlignment = value
    set_param("verticalAlignment", value)
end

function xfdv_set_distribution(value)
    distribution = value
    set_param("distribution", value)
end

function xfdv_set_aircraft_visibility(value)
    showAircraft = value
    set_param("showAircraft", value)
end

function xfdv_set_engine_visibility(value)
    showEngine = value
    set_param("showEngine", value)
end

function xfdv_set_weather_visibility(value)
    showWeather = value
    set_param("showWeather", value)
end

function xfdv_set_location_visibility(value)
    showLocation = value
    set_param("showLocation", value)
end

function xfdv_set_radio_visibility(value)
    showRadio = value
    set_param("showRadio", value)
end

function xfdv_set_temp_unit(value)
    tempUnit = value
    set_param("tempUnit", value)
end

function xfdv_set_liquid_unit(value)
    liquidUnit = value
    set_param("liquidUnit", value)
end

function draw_config_panel()
    jjjLib1.clearPanel(pluginId, panelId)
    jjjLib1.setPanelPos(pluginId, panelId, SCREEN_WIDTH / 2 - 160)
    jjjLib1.setPanelName(pluginId, panelId, "CONFIGURATION")
    jjjLib1.addPanelTextLine(pluginId, panelId, "Panel position:")
    jjjLib1.addPanelBR(pluginId, panelId, 0.5)
    jjjLib1.addPanelLabel(pluginId, panelId, "Horizontal alignment")
    jjjLib1.addPanelButton(pluginId, panelId, "", "s", false, false, "")
    jjjLib1.addPanelButton(pluginId, panelId, "LEFT", "s", horizontalAlignment == "L", true, 'xfdv_set_horizontal_alignment("L")')
    jjjLib1.addPanelButton(pluginId, panelId, "RIGHT", "s", horizontalAlignment == "R", true, 'xfdv_set_horizontal_alignment("R")')
    jjjLib1.addPanelBR(pluginId, panelId, 2.0)
    jjjLib1.addPanelLabel(pluginId, panelId, "Vertical alignment")
    jjjLib1.addPanelButton(pluginId, panelId, "", "s", false, false, "")
    jjjLib1.addPanelButton(pluginId, panelId, "TOP", "s", verticalAlignment == "T", true, 'xfdv_set_vertical_alignment("T")')
    jjjLib1.addPanelButton(pluginId, panelId, "BOTTOM", "s", verticalAlignment == "B", true, 'xfdv_set_vertical_alignment("B")')

    jjjLib1.addPanelBR(pluginId, panelId, 2)
    jjjLib1.addPanelHR(pluginId, panelId)

    jjjLib1.addPanelTextLine(pluginId, panelId, "Panel distribution:")
    jjjLib1.addPanelBR(pluginId, panelId, 0.5)
    jjjLib1.addPanelLabel(pluginId, panelId, "Distribution")
    jjjLib1.addPanelButton(pluginId, panelId, "", "s", false, false, "")
    jjjLib1.addPanelButton(pluginId, panelId, "HORIZONTAL", "s", distribution == "H", true, 'xfdv_set_distribution("H")')
    jjjLib1.addPanelButton(pluginId, panelId, "VERTICAL", "s", distribution == "V", true, 'xfdv_set_distribution("V")')

    jjjLib1.addPanelBR(pluginId, panelId, 2)
    jjjLib1.addPanelHR(pluginId, panelId)

    jjjLib1.addPanelTextLine(pluginId, panelId, "Temp/Liquid unit:")
    jjjLib1.addPanelBR(pluginId, panelId, 0.5)
    jjjLib1.addPanelLabel(pluginId, panelId, "Temperature unit")
    jjjLib1.addPanelButton(pluginId, panelId, "", "s", false, false, "")
    jjjLib1.addPanelButton(pluginId, panelId, "CELSIUS", "s", tempUnit == "C", true, 'xfdv_set_temp_unit("C")')
    jjjLib1.addPanelButton(pluginId, panelId, "FAHRENH.", "s", tempUnit == "F", true, 'xfdv_set_temp_unit("F")')
    jjjLib1.addPanelBR(pluginId, panelId, 2.0)
    jjjLib1.addPanelLabel(pluginId, panelId, "Liquid unit")
    jjjLib1.addPanelButton(pluginId, panelId, "", "s", false, false, "")
    jjjLib1.addPanelButton(pluginId, panelId, "LITER", "s", liquidUnit == "L", true, 'xfdv_set_liquid_unit("L")')
    jjjLib1.addPanelButton(pluginId, panelId, "GALLON", "s", liquidUnit == "G", true, 'xfdv_set_liquid_unit("G")')

    jjjLib1.addPanelBR(pluginId, panelId, 2)
    jjjLib1.addPanelHR(pluginId, panelId)

    jjjLib1.addPanelTextLine(pluginId, panelId, "Switch visibility of elements:")
    jjjLib1.addPanelBR(pluginId, panelId, 1)
    jjjLib1.addPanelLabel(pluginId, panelId, "Aircraft")
    jjjLib1.addPanelButton(pluginId, panelId, "", "s", false, false, "")
    jjjLib1.addPanelButton(pluginId, panelId, "SHOW", "s", showAircraft == true, true, 'xfdv_set_aircraft_visibility(true)')
    jjjLib1.addPanelButton(pluginId, panelId, "HIDE", "s", showAircraft == false, true, 'xfdv_set_aircraft_visibility(false)')
    jjjLib1.addPanelBR(pluginId, panelId, 2)
    jjjLib1.addPanelLabel(pluginId, panelId, "Engine")
    jjjLib1.addPanelButton(pluginId, panelId, "", "s", false, false, "")
    jjjLib1.addPanelButton(pluginId, panelId, "SHOW", "s", showEngine == true, true, 'xfdv_set_engine_visibility(true)')
    jjjLib1.addPanelButton(pluginId, panelId, "HIDE", "s", showEngine == false, true, 'xfdv_set_engine_visibility(false)')
    jjjLib1.addPanelBR(pluginId, panelId, 2)
    jjjLib1.addPanelLabel(pluginId, panelId, "Weather")
    jjjLib1.addPanelButton(pluginId, panelId, "", "s", false, false, "")
    jjjLib1.addPanelButton(pluginId, panelId, "SHOW", "s", showWeather == true, true, 'xfdv_set_weather_visibility(true)')
    jjjLib1.addPanelButton(pluginId, panelId, "HIDE", "s", showWeather == false, true, 'xfdv_set_weather_visibility(false)')
    jjjLib1.addPanelBR(pluginId, panelId, 2)
    jjjLib1.addPanelLabel(pluginId, panelId, "Location")
    jjjLib1.addPanelButton(pluginId, panelId, "", "s", false, false, "")
    jjjLib1.addPanelButton(pluginId, panelId, "SHOW", "s", showLocation == true, true, 'xfdv_set_location_visibility(true)')
    jjjLib1.addPanelButton(pluginId, panelId, "HIDE", "s", showLocation == false, true, 'xfdv_set_location_visibility(false)')
    jjjLib1.addPanelBR(pluginId, panelId, 2)
    jjjLib1.addPanelLabel(pluginId, panelId, "Radio")
    jjjLib1.addPanelButton(pluginId, panelId, "", "s", false, false, "")
    jjjLib1.addPanelButton(pluginId, panelId, "SHOW", "s", showRadio == true, true, 'xfdv_set_radio_visibility(true)')
    jjjLib1.addPanelButton(pluginId, panelId, "HIDE", "s", showRadio == false, true, 'xfdv_set_radio_visibility(false)')

    jjjLib1.addPanelBR(pluginId, panelId, 2)
    jjjLib1.addPanelHR(pluginId, panelId)

    jjjLib1.addPanelButton(pluginId, panelId, "SAVE", "m", false, jjjLib1.isAnyParamUnsaved(pluginId), 'xfdv_save_params(); xfdv_toggle_config_panel()', "green")
    if jjjLib1.isAnyParamUnsaved(pluginId) then
        jjjLib1.addPanelButton(pluginId, panelId, "CANCEL", "m", false, true, 'xfdv_load_params(); xfdv_toggle_config_panel()', "grey")
    else
        jjjLib1.addPanelButton(pluginId, panelId, "BACK", "m", false, true, 'xfdv_toggle_config_panel()', "grey")
    end
    jjjLib1.addPanelButton(pluginId, panelId, "DEFAULT", "m", false, jjjLib1.isAnyParamNotDefault(pluginId), 'xfdv_set_params_default()', "grey")
end

function xfdv_toggle_config_panel()
    showConfigPanel = not showConfigPanel
    if showConfigPanel == false then
        jjjLib1.closePanel(pluginId, panelId)
    else
        jjjLib1.openPanel(pluginId, panelId)
    end
end

function mainProg()
    if XFDVisActive then
        batteryOn = mainBatteryOn ~= 0

        if batteryOn and reloadParams then
            xfdv_load_params()
            reloadParams = false
        end
        show_flight_data()

        -- simulator and battery power status hint
        if paused ~= 0 then
            draw_pause_msg()
        elseif (not batteryOn) then
            draw_battery_msg()
            reloadParams = true
        end
    end
end

function mouse_click()
    -- close button clicked
    xClick = MOUSE_X
    yClick = MOUSE_Y
    xMinConf = (SCREEN_WIDTH / 2) - 48
    xMaxConf = (SCREEN_WIDTH / 2) + 48
    if horizontalAlignment == "L" then
        xMinClose = horizontalMargin
        xMaxClose = horizontalMargin + 10
    else
        xMinClose = SCREEN_WIDTH - horizontalMargin - 10
        xMaxClose = SCREEN_WIDTH - horizontalMargin
    end
    if verticalAlignment == "T" then
        yMinClose = SCREEN_HEIGHT - menuBarHeight - verticalMargin - 10
        yMaxClose = SCREEN_HEIGHT - menuBarHeight - verticalMargin

        yMinConf = SCREEN_HEIGHT - menuBarHeight - verticalMargin - 16 - 16
        yMaxConf = SCREEN_HEIGHT - menuBarHeight - verticalMargin - 16
    else
        yMinClose = verticalMargin + boxHeight - 10
        yMaxClose = verticalMargin + boxHeight
        yMinConf = verticalMargin + 16
        yMaxConf = verticalMargin + 16 + 16
    end

    if (xClick >= xMinClose and xClick <= xMaxClose) and (yClick >= yMinClose and yClick <= yMaxClose) then
        XFDVisActive = false
    end
    if XFDVisActive and paused ~= 0 and showConfigPanel == false and (xClick >= xMinConf and xClick <= xMaxConf) and (yClick >= yMinConf and yClick <= yMaxConf) then
        xfdv_toggle_config_panel()
    end
end

XFDVisActive = true
reloadParams = false

--Main Program
xfdv_load_params()
getDataRefs()

draw_config_panel()

do_every_draw("mainProg()")
do_on_mouse_click("mouse_click()")

add_macro("Show XFDV Window", "XFDVisActive = true")