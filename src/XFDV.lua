require("graphics")
require("radio")
require("HUD")
require("jjjLib1")
local pluginName = "XFDV"

if jjjLib1.version == nil or jjjLib1.version() < 1.7 then
    do_every_draw('draw_string(20, SCREEN_HIGHT - 104, "Plugin ' .. pluginName .. ': Requires library \'3jLib1\' version 1.7 or higher! Please search for \'3jLib1\' on x-plane.org, download and install current version of library.")')
    return
end

local pluginId = jjjLib1.getPlId(pluginName)

if XPLANE_VERSION < 12000 then
    jjjLib1.warning(pluginId, pluginName .. ': This plugin is for X-Plane 12 only!')
    return
end

jjjLib1.addParam(pluginId, "liquidUnit", { ["save"] = "global", ["autosave"] = true, ["dflt"] = "G" }, "")
jjjLib1.addParam(pluginId, "weightUnit", { ["save"] = "global", ["autosave"] = true, ["dflt"] = "L" }, "")
jjjLib1.addParam(pluginId, "tempUnit", { ["save"] = "global", ["autosave"] = true, ["dflt"] = "F" }, "")
jjjLib1.addParam(pluginId, "showAircraft", { ["save"] = "global", ["autosave"] = true, ["dflt"] = true }, "")
jjjLib1.addParam(pluginId, "showWeather", { ["save"] = "global", ["autosave"] = true, ["dflt"] = true }, "")
jjjLib1.addParam(pluginId, "showSimulator", { ["save"] = "global", ["autosave"] = true, ["dflt"] = true }, "")
jjjLib1.addParam(pluginId, "showLocation", { ["save"] = "global", ["autosave"] = true, ["dflt"] = true }, "")
jjjLib1.addParam(pluginId, "showEngine", { ["save"] = "global", ["autosave"] = true, ["dflt"] = true }, "")
jjjLib1.addParam(pluginId, "showRadio", { ["save"] = "global", ["autosave"] = true, ["dflt"] = true }, "")
jjjLib1.addParam(pluginId, "showAutopilot", { ["save"] = "global", ["autosave"] = true, ["dflt"] = true }, "")

function XFDV_param(param)
    return jjjLib1.getParam(pluginId, param)
end
function XFDV_setParam(param, value)
    jjjLib1.setParam(pluginId, param, value)
end
function XFDV_loadParams()
    local ok = jjjLib1.loadParams(pluginId)
end
function XFDV_saveParams()
    jjjLib1.saveParams(pluginId)
end
function XFDV_setParamsDefault()
    jjjLib1.setParamsDefault(pluginId)
end

--local liquidUnit = XFDV_param("liquidUnit")
--local weightUnit = XFDV_param("weightUnit")
--local tempUnit = XFDV_param("tempUnit")
---- control visibility of informations
--local showAircraft = XFDV_param("showAircraft")
--local showWeather = XFDV_param("showWeather")
--local showSimulator = XFDV_param("showSimulator")
--local showLocation = XFDV_param("showLocation")
--local showEngine = XFDV_param("showEngine")
--local showRadio = XFDV_param("showRadio")
--local showAutopilot = XFDV_param("showAutopilot")

-- XFDV_saveParams()

function load_params()
    -- load XFDV settings
    jjjLib1.loadParams(pluginId, "global")

    -- units
    liquidUnit = XFDV_param("liquidUnit")
    weightUnit = XFDV_param("weightUnit")
    tempUnit = XFDV_param("tempUnit")
    -- control visibility of informations
    showAircraft = XFDV_param("showAircraft")
    showWeather = XFDV_param("showWeather")
    showSimulator = XFDV_param("showSimulator")
    showLocation = XFDV_param("showLocation")
    showEngine = XFDV_param("showEngine")
    showRadio = XFDV_param("showRadio")
    showAutopilot = XFDV_param("showAutopilot")
end

function getDataRefs()

    --**GetDatarefValues**

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
    dataref("fuelFlow", "sim/cockpit2/engine/indicators/fuel_flow_kg_sec", 0, 0)

    -- GPS
    dataref("gpsNavID0", "sim/cockpit2/radios/indicators/gps_nav_id", 0, 0)

    --FlightModel
    dataref("parkBrake", "sim/flightmodel/controls/parkbrake")
    dataref("fuelKGS", "sim/flightmodel/engine/ENGN_FF_", 0, 0)
    dataref("egtC", "sim/flightmodel/engine/ENGN_EGT_c", 0, 0)
    dataref("batteryAmps", "sim/flightmodel/engine/ENGN_bat_amp", 0, 0)
    dataref("batteryVolts", "sim/flightmodel/engine/ENGN_bat_volt", 0, 0)
    dataref("flapsRatio", "sim/flightmodel2/wing/flap1_deg", 0, 0)
    dataref("magVar", "sim/flightmodel/position/magnetic_variation")
    dataref("fuelTnk1", "sim/flightmodel/weight/m_fuel1")
    dataref("fuelTnk2", "sim/flightmodel/weight/m_fuel2")

    --Weather
    dataref("pressureSPas", "sim/weather/region/sealevel_pressure_pas")
    dataref("windSP", "sim/weather/aircraft/wind_speed_kts", "readonly", 0)
    dataref("windDIR", "sim/weather/aircraft/wind_direction_degt", "readonly", 0)
    dataref("ambiTemp", "sim/weather/aircraft/temperature_ambient_deg_c")
    dataref("precip", "sim/weather/region/rain_percent")

    cloudTypes = dataref_table("sim/weather/aircraft/cloud_type")
    cloudAlts = dataref_table("sim/weather/aircraft/cloud_base_msl_m")
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


    --End of Datarefs
end

local function round(num)
    return num + (2 ^ 52 + 2 ^ 51) - (2 ^ 52 + 2 ^ 51)
end

function show_flight_data()
    if showAircraft or showEngine then
        calc_fuel_data()
    end
    if showAircraft or showWeather or showLocation then
        calc_weather_data()
    end
    if showAircraft then
        draw_aircraft()
    end
    if showWeather then
        draw_weather()
    end
    if showSimulator then
        draw_simulator()
    end
    if showLocation then
        draw_location()
    end
    if showEngine then
        draw_engine()
    end
    if showRadio then
        draw_radio()
    end
    if showAutopilot then
        draw_autopilot()
    end
end

function calc_fuel_data()
    --Calculate fuel data
    fuelAvail = fuelTnk1 + fuelTnk2
    fuelLBS = fuelAvail * 2.20462
    fuelGAL = fuelLBS / 6
    fuelAvailGal = (fuelAvail * 2.20462) / 6
    fuelFlowMin = fuelFlow * 60
    fuelFlowHour = fuelFlowMin * 60
    fuelFlowHourLBS = fuelFlowHour * 2.20462
    fuelFlowHourGal = fuelFlowHourLBS / 6
    fuelRemain = fuelAvailGal / fuelFlowHourGal
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

function draw_location()
    local function double_box(y, height)
        graphics.set_color(.6, .6, .6, .5)
        graphics.draw_rectangle(col2Start + 66, y, col2Start + 66 + 136, y + height)
        graphics.set_color(0, 0, 0, .425)
        graphics.draw_rectangle(col2Start + 67, y + border, col2Start + 67 + 70, y + height - (2 * border))
        graphics.draw_rectangle(col2Start + 138, y + border, col2Start + 138 + 63, y + height - (2 * border))
    end

    local function single_box(y, height)
        graphics.set_color(.6, .6, .6, .5)
        graphics.draw_rectangle(col2Start + 66, y, col2Start + 66 + 136, y + height)
        graphics.set_color(0, 0, 0, .425)
        graphics.draw_rectangle(col2Start + 67, y + border, col2Start + 67 + 134, y + height - (2 * border))
    end

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

    if airSpeed <= 0 then
        airSpeed = 0
    end

    --Time and Location
    draw_string(col2Start + 10, 247, "Location Information", .9, .9, .2)

    draw_string(col2Start + 16, 234, "Time", .9, .9, .9)
    double_box(230, 14)

    if batteryOn then
        --display data only if the battery is on
        draw_string(col2Start + 71, 234, zuluHours .. ":" .. zuluMinutes .. " GMT", 0, 1, 0, .8)
        draw_string(col2Start + 142, 234, localHours .. ":" .. localMinutes .. " LCL", 0, 1, 0, .8)
    end

    draw_string(col2Start + 16, 219, "Location", .9, .9, .9)
    single_box(215, 14)

    if batteryOn then
        --display data only if the battery is on
        draw_string(col2Start + 74, 219, string.format('%.3f', acftLat) .. nsLat .. " , " .. string.format('%.3f', acftLong) .. ewLong, 0, 1, 0, .8)
    end

    draw_string(col2Start + 16, 204, "Atm.Pr.", .9, .9, .9)
    double_box(200, 14)

    if batteryOn then
        --display data only if the battery is on
        draw_string(col2Start + 73, 204, string.format('%.2f', pressureP) .. " Set", 0, 1, 0, .8)
        draw_string(col2Start + 144, 204, string.format('%.2f', pressureS) .. " SL", 0, 1, 0, .8)
    end

    draw_string(col2Start + 16, 188, "OAT", .9, .9, .9)
    double_box(185, 14)

    if batteryOn then
        --display data only if the battery is on
        draw_string(col2Start + 81, 189, string.format('%04.1f°C', ambiTemp), 0, 1, 0, .8)
        draw_string(col2Start + 152, 189, string.format('%04.1f°F', ambiTempF), 0, 1, 0, .8)
    end

    --Special data area
    graphics.set_color(.9, .9, .9, .2)
    graphics.draw_rectangle(col2Start + 7, 127, col2Start + 7 + 199, 180)
    graphics.set_color(.0, .2, .5, .1)
    graphics.draw_rectangle(col2Start + 9, 129, col2Start + 9 + 195, 178)

    --Display istrument info
    draw_string(col2Start + 14, 169, "Airspeed", .9, .9, .9)
    draw_string(col2Start + 79, 169, "Bearing", .9, .9, .9)
    draw_string(col2Start + 147, 169, "Altitude", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(col2Start + 10, 150, col2Start + 10 + 192, 164)

    ---Airspeed
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(col2Start + 11, 151, col2Start + 11 + 56, 163)

    if batteryOn then
        --display data only if the battery is on
        if airSpeed >= 119.5 then
            graphics.set_color(1, 0, 0, .45)
            graphics.draw_rectangle(col2Start + 11, 151, col2Start + 11 + 56, 163)
            draw_string(col2Start + 20, 154, string.format('%.0fKts', airSpeed), 1, 1, 0, 1)
        elseif airSpeed >= 69.5 and airSpeed < 119.5 then
            graphics.set_color(0, 0, 0, .175)
            graphics.draw_rectangle(col2Start + 11, 151, col2Start + 11 + 56, 163)
            draw_string(col2Start + 20, 154, string.format('%.0fKts', airSpeed), 0, 1, 0, 1)
        elseif airSpeed >= 49.5 and airSpeed < 69.5 then
            graphics.set_color(1, 1, 0, .6)
            graphics.draw_rectangle(col2Start + 11, 151, col2Start + 11 + 56, 163)
            draw_string(col2Start + 24, 154, string.format('%.0fKts', airSpeed), 0, 0, 0, 1)
        elseif airSpeed >= 0 and airSpeed < 49.5 then
            graphics.set_color(1, 0, 0, .45)
            graphics.draw_rectangle(col2Start + 11, 151, col2Start + 11 + 56, 163)
            draw_string(col2Start + 17, 154, "OnGrnd", 1, 1, 0, 1)
        else
            airSpeed = 0
            graphics.set_color(0, 0, 0, .125)
            graphics.draw_rectangle(col2Start + 11, 151, col2Start + 11 + 56, 163)
            draw_string(col2Start + 26, 154, string.format('%.0fKts', airSpeed), 0, 1, 0, 1)
        end
    end

    --Bearing
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(col2Start + 68, 151, col2Start + 68 + 66, 163)

    if batteryOn then
        --display data only if the battery is on
        draw_string(col2Start + 74, 154, string.format('%05.1fDeg', magBearing), 0, .9, 0, 1)
    end

    ---Altitude AGL
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(col2Start + 135, 151, col2Start + 135 + 66, 163)

    if batteryOn then
        --display data only if the battery is on
        if altFtAGL > 999.5 and altFtAGL <= 1500 then
            --adjust display based on current AGL altitude
            graphics.set_color(0, 1, 0, .6)
            graphics.draw_rectangle(col2Start + 135, 151, col2Start + 135 + 66, 163)
            draw_string(col2Start + 148, 154, string.format('%.0fFt', altFtAGL), 0, 0, 0, 1)
        elseif altFtAGL > 499.5 and altFtAGL <= 999.5 then
            graphics.set_color(1, 1, 0, .625)
            graphics.draw_rectangle(col2Start + 135, 151, col2Start + 135 + 66, 163)
            draw_string(col2Start + 148, 154, string.format('%.0fFt', altFtAGL), 0, 0, 0, 1)
        elseif altFtAGL > 99.5 and altFtAGL <= 499.5 then
            graphics.set_color(1, 1, 0, .625)
            graphics.draw_rectangle(col2Start + 135, 151, col2Start + 135 + 66, 163)
            draw_string(col2Start + 148, 154, string.format('%.0fFt', altFtAGL), 1, 0, 0, 1)
        elseif altFtAGL <= 99.5 then
            graphics.set_color(1, 0, 0, .6)
            graphics.draw_rectangle(col2Start + 135, 151, col2Start + 135 + 66, 163)
            draw_string(col2Start + 148, 154, string.format('%.0fFt', altFtAGL), 1, 1, 0, 1)
        else
            graphics.set_color(0, 0, 0, .125)
            graphics.draw_rectangle(col2Start + 135, 151, col2Start + 135 + 66, 163)
            draw_string(col2Start + 148, 154, string.format('%.0fFt', altFtAGL), 0, 1, 0, 1)
        end
    end

    ---Flaps
    draw_string(col2Start + 18, 136, "Flaps", 1, .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(col2Start + 51, 146, col2Start + 51 + 35, 132)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(col2Start + 52, 145, col2Start + 52 + 33, 133)

    if batteryOn then
        --display data only if the battery is on
        if flapsRatio == 0 then
            draw_string(col2Start + 56, 136, string.format('%02.0f', flapsRatio) .. "%", 0, 1, 0, 1)
        else
            graphics.set_color(0, 0, .725, .5)
            graphics.draw_rectangle(col2Start + 52, 145, col2Start + 52 + 33, 133)
            draw_string(col2Start + 56, 136, string.format('%02.0f', flapsRatio) .. "%", 1, 1, 0, 1)
        end
    end

    --Parking brake info
    draw_string(col2Start + 92, 136, "Parking Brake", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(col2Start + 175, 146, col2Start + 175 + 27, 132)

    if parkBrake == 1 then
        graphics.set_color(1, 0, 0, .75)
        graphics.draw_rectangle(col2Start + 175, 145, col2Start + 175 + 25, 133)
        draw_string(col2Start + 179, 136, "ON", 1, 1, 0)
    else
        graphics.set_color(0, .8, 0, .75)
        graphics.draw_rectangle(col2Start + 175, 145, col2Start + 175 + 25, 133)
        draw_string(col2Start + 177, 136, "OFF", 0, 0, 0)
    end
end

function draw_aircraft()
    --Aircraft information
    draw_string(53, 247, "AIRCRAFT", .9, .9, .2)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(112, 243, 228, 257)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(113, 244, 166, 256)
    graphics.draw_rectangle(167, 244, 227, 256)

    draw_string(115, 247, acftName, 1, 1, 0, .8)
    draw_string(169, 247, tailNum, 1, 1, 0, .8)

    --Annunciators
    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(52, 200, 228, 242)
    graphics.set_color(0, 0, 0, .425)

    --row 1
    graphics.draw_rectangle(53, 229, 112, 241)

    if batteryOn then
        --display data only if the battery is on
        if ckPressure == 0 then
            draw_string(57, 232, "CK BARO", .3, .3, .3)
        else
            draw_string(57, 232, "CK BARO", .8, .8, .2)
        end
    end

    graphics.draw_rectangle(113, 229, 166, 241)

    if batteryOn then
        --display data only if the battery is on
        if fuelRemain <= 2.5 then
            draw_string(117, 232, "CK FUEL", .8, .8, .2)
        else
            draw_string(117, 232, "CK FUEL", .3, .3, .3)
        end
    end

    graphics.draw_rectangle(167, 229, 227, 241)

    if batteryOn then
        --display data only if the battery is on
        if fuelPump == 0 then
            draw_string(172, 232, "Fuel Pmp", .3, .3, .3)
        else
            draw_string(172, 232, "Fuel Pmp", .2, .8, .2)
        end
    end

    --row 2
    graphics.draw_rectangle(53, 215, 112, 228)

    if batteryOn then
        --display data only if the battery is on
        if landingLight == 0 then
            draw_string(61, 218, "Land LT", .3, .3, .3)
        else
            draw_string(61, 218, "Land Lt", .2, .8, .2)
        end
    end

    graphics.draw_rectangle(113, 215, 166, 228)

    if batteryOn then
        --display data only if the battery is on
        if taxiLight == 0 then
            draw_string(120, 218, "Taxi LT", .3, .3, .3)
        else
            draw_string(120, 218, "Taxi Lt", .2, .8, .2)
        end
    end

    graphics.draw_rectangle(167, 215, 227, 228)

    if batteryOn then
        --display data only if the battery is on
        if pitoHeat == 0 then
            draw_string(175, 218, "PITO Ht", .3, .3, .3)
        else
            draw_string(175, 218, "PITO Ht", .2, .8, .2)
        end
    end

    --row 3
    graphics.draw_rectangle(53, 201, 112, 214)

    if batteryOn then
        --display data only if the battery is on
        if beaconLight == 0 then
            draw_string(61, 204, "Beacon", .3, .3, .3)
        else
            draw_string(61, 204, "Beacon", .2, .8, .2)
        end
    end

    graphics.draw_rectangle(113, 201, 166, 214)

    if batteryOn then
        --display data only if the battery is on
        if strobeLight == 0 then
            draw_string(121, 204, "Strobe", .3, .3, .3)
        else
            draw_string(121, 204, "Strobe", .2, .8, .2)
        end
    end

    graphics.draw_rectangle(167, 201, 227, 214)

    if batteryOn then
        --display data only if the battery is on
        if navLight == 0 then
            draw_string(185, 204, "Nav", .3, .3, .3)
        else
            draw_string(185, 204, "Nav", .2, .8, .2)
        end
    end

    --Display electrical info
    draw_string(64, 187, "Main Battery", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(139, 182, 228, 196)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(140, 183, 185, 195)

    if batteryOn then
        --display data only if the battery is on
        if batteryAmps <= -0.0 then
            graphics.set_color(1, 0, 0, .5)
            graphics.draw_rectangle(140, 183, 185, 195)
            draw_string(144, 186, string.format('%.1fA', batteryAmps), 1, 1, 0)
        else
            draw_string(143, 186, string.format('%.1fA', batteryAmps), 0, 1, 0)
        end
    end

    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(186, 183, 227, 195)

    if batteryOn then
        --display data only if the battery is on
        draw_string(190, 186, string.format('%.1fV', batteryVolts), 0, 1, 0)
    end

    --Oil pressure
    draw_string(67, 170, "Oil Pressure", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(139, 166, 185, 180)
    graphics.set_color(.0, .0, .0, .425)
    graphics.draw_rectangle(140, 167, 184, 179)

    if batteryOn then
        --display data only if the battery is on
        draw_string(144, 170, string.format('%.2f', oilPressure), 0, 1, 0)
    end

    --Vacuum pressure
    draw_string(55, 154, "Vacuum Press", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(139, 150, 185, 164)
    graphics.set_color(.0, .0, .0, .425)
    graphics.draw_rectangle(140, 151, 184, 163)

    if batteryOn then
        --display data only if the battery is on
        draw_string(144, 154, string.format('%02.2f', vacuumRatio), 0, 1, 0)
    end
end

function draw_weather()
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
    local clType0 = cloudType_tbl[round(cloudTypes[0])]
    local clType1 = cloudType_tbl[round(cloudTypes[1])]
    local clType2 = cloudType_tbl[round(cloudTypes[2])]

    --Miscellaneous Calculations
    --weather
    windMPH = 1.15 * math.ceil(windSP)
    --visibility
    visMiles = visibility * 0.000621371

    --Display weather data
    draw_string(52, 137, "Weather Data", .9, .9, .2)

    --wind dir box
    draw_string(55, 124, "Wind", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(85, 120, 116, 134)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(86, 133, 115, 121)

    if batteryOn then
        draw_string(89, 124, string.format('%03.0f', math.ceil(windDIR)), 0, 1, 0)
    end

    draw_string(121, 124, "at", .9, .9, .9)

    --wind speed box
    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(138, 134, 228, 120)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(139, 133, 181, 121)
    graphics.draw_rectangle(182, 133, 227, 121)

    if batteryOn then
        --display data only if the battery is on
        draw_string(143, 124, string.format('%02.0f', math.ceil(windSP)) .. " Kts", 0, 1, 0)
        draw_string(184, 124, string.format('%02.0f', math.ceil(windMPH)) .. " Mph", 0, 1, 0)
    end

    --Turbulence/Precip/Visibility
    draw_string(54, 108, "Turb.", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(85, 104, 110, 118)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(86, 105, 109, 117)

    if batteryOn then
        --display data only if the battery is on
        draw_string(88, 108, string.format('%.1f', turbulence), 0, 1, 0, .8)
    end

    draw_string(115, 108, "Precip.", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(156, 104, 172, 118)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(157, 105, 171, 117)

    if batteryOn then
        --display data only if the battery is on
        draw_string(160, 108, string.format('%.0f', precip), 0, 1, 0, .8)
    end

    draw_string(176, 108, "Vis.", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(198, 104, 228, 118)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(199, 105, 227, 117)

    if batteryOn then
        --display data only if the battery is on
        draw_string(206, 108, string.format('%.0f', visMiles), 0, 1, 0, .8)
    end

    draw_string(57, 94, "Clouds at Alt.", .9, .9, .9)
    draw_string(168, 94, "Type", .9, .9, .9)

    --create clouds data boxes
    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(52, 52, 228, 90)
    --left column
    graphics.set_color(0, 0, 0, .425)
    graphics.set_color(.1, .1, .3, .45)
    graphics.draw_rectangle(53, 77, 138, 89)
    graphics.set_color(.1, .1, .6, .35)
    graphics.draw_rectangle(53, 65, 138, 77)
    graphics.set_color(.1, .1, .9, .25)
    graphics.draw_rectangle(53, 53, 138, 65)
    --right column
    graphics.set_color(.0, .0, .0, .45)
    graphics.draw_rectangle(139, 77, 227, 89)
    graphics.set_color(.1, .1, .1, .35)
    graphics.draw_rectangle(139, 65, 227, 77)
    graphics.set_color(.2, .2, .2, .25)
    graphics.draw_rectangle(139, 53, 227, 65)

    if batteryOn then
        --display data only if the battery is on
        draw_string(78, 80, string.format('%05.0f', cloudAlts[2] * 3.28), .9, .9, .9)
        draw_string(143, 80, clType2, 0, 1, 0, .8)

        draw_string(78, 68, string.format('%05.0f', cloudAlts[1] * 3.28), .9, .9, .9)
        draw_string(143, 68, clType1, 0, 1, 0, .8)

        draw_string(78, 56, string.format('%05.0f', cloudAlts[0] * 3.28), .9, .9, .9)
        draw_string(143, 56, clType0, 0, 1, 0, .9)
    end
end

function draw_simulator()
    fps = 1 / fpsRate
    draw_string(52, 36, "Simulator Data", .9, .9, .2)

    draw_string(87, 23, "FPS", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(110, 19, 139, 33)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(111, 20, 138, 32)

    draw_string(114, 23, string.format('%03.0f', fps), 0, 1, 0, .8)

    draw_string(158, 23, "GPU", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(185, 19, 228, 33)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(186, 20, 227, 32)

    draw_string(191, 23, string.format('%.3f', gpuTime), 0, 1, 0, .8)
end

function draw_engine()
    -- egt Temperature
    egtF = (egtC * 9 / 5) + 32

    if engRPMS < 1 then
        engRPMS = 0
    end

    --Display engine data
    draw_string(250, 115, "Engine Performance", .9, .9, .2)
    draw_string(254, 103, "Mixture", .9, .9, .9)
    draw_string(307, 103, "RPM", .9, .9, .9)
    draw_string(373, 103, "EGT", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(250, 84, 442, 98)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(251, 85, 299, 97)
    graphics.draw_rectangle(300, 85, 337, 97)
    graphics.draw_rectangle(338, 85, 441, 97)

    if batteryOn then
        --display data only if the battery is on
        draw_string(265, 88, string.format('%02.0f', (mixture * 100)) .. "%", 0, 1, 0)
        draw_string(305, 88, string.format('%04.0f', engRPMS), 0, 1, 0)
        draw_string(344, 88, string.format('%.0f°C', egtC) .. " (" .. string.format('%.0f°F', egtF) .. ")", 0, 1, 0)
    end

    ---Fuel
    draw_string(271, 68, "Fuel Status", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(337, 64, 442, 79)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(338, 65, 441, 78)

    if batteryOn then
        --display data only if the battery is on
        if fuelRemain <= 3.0 then
            graphics.set_color(1, 1, 0, .6)
            graphics.draw_rectangle(338, 65, 441, 78)
            draw_string(355, 68, "CHECK FUEL", 0, 0, 0, 1)
        elseif fuelRemain <= 2.5 then
            graphics.set_color(1, 0, 0, .6)
            graphics.draw_rectangle(338, 65, 441, 78)
            draw_string(365, 68, "FUEL!!", 1, 1, 0, 1)
        else
            draw_string(365, 68, "FUEL OK", 0, 1, 0, 1)
        end
    end

    draw_string(253, 52, "Fuel On Board", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(337, 48, 442, 62)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(338, 49, 386, 61)
    graphics.draw_rectangle(387, 49, 441, 61)

    if batteryOn then
        --display data only if the battery is on
        draw_string(340, 52, string.format('%.0f Lbs', fuelLBS), 0, 1, 0, .8)
        draw_string(389, 52, string.format('%.1f %s', fuelAvailGal, liquidUnit), 0, 1, 0, .8)
    end

    draw_string(263, 36, "Flow Rate", .9, .9, .9)
    draw_string(370, 36, "Time", .9, .9, .9)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(250, 19, 442, 33)
    graphics.set_color(0, 0, 0, .5)
    graphics.draw_rectangle(251, 20, 337, 32)
    graphics.draw_rectangle(338, 20, 441, 32)

    if batteryOn then
        --display data only if the battery is on
        draw_string(263, 23, string.format('%.1f %s/Hr', fuelFlowHourGal, liquidUnit), 0, 1, 0, .8)
        draw_string(360, 23, string.format('%.2f Hrs', fuelRemain), 0, 1, 0, .8)
    end
end

function draw_radio()
    --Radios (data provided by require "radio" module)
    com1 = COM1 / 100
    com2 = COM2 / 100
    nav1 = NAV1 / 100
    nav2 = NAV2 / 100
    com1S = COM1_STDBY / 100
    com2S = COM2_STDBY / 100
    nav1S = NAV1_STDBY / 100
    nav2S = NAV2_STDBY / 100
    adf1 = ADF1
    adf1S = ADF1_STDBY
    xpdr = SQUAWK
    xpdrMode = TRANSPONDER_MODE

    local xpdrMode_tbl = {
        [0] = "OFF",
        [1] = "STDBY",
        [2] = "ON",
        [3] = "ALT",
        [4] = "TEST",
    }
    xpMode = xpdrMode_tbl[xpdrMode]
    --Radios
    graphics.set_color(.6, .6, .6, .5)
    --com1/com2
    graphics.draw_rectangle(504, 202, 599, 230)
    --nav1/nav2
    graphics.draw_rectangle(504, 172, 599, 200)
    --ADF
    graphics.draw_rectangle(504, 156, 599, 170)
    --Xpdr
    graphics.draw_rectangle(504, 138, 599, 153)

    graphics.set_color(0, 0, 0, .425)
    --com1
    graphics.draw_rectangle(505, 216, 552, 229)
    graphics.draw_rectangle(553, 216, 598, 229)
    --com2
    graphics.draw_rectangle(505, 203, 552, 215)
    graphics.draw_rectangle(553, 203, 598, 215)
    --nav1
    graphics.draw_rectangle(505, 186, 552, 199)
    graphics.draw_rectangle(553, 186, 598, 199)
    --nav2
    graphics.draw_rectangle(505, 173, 552, 185)
    graphics.draw_rectangle(553, 173, 598, 185)
    --ADF
    graphics.draw_rectangle(505, 157, 552, 169)
    graphics.draw_rectangle(553, 157, 598, 169)
    --Xpdr
    graphics.draw_rectangle(505, 139, 552, 152)
    graphics.draw_rectangle(553, 139, 598, 152)

    --radio stack labels
    draw_string(467, 247, "Radios", .9, .9, .1)
    draw_string(507, 234, "Active", .9, .9, .9)
    draw_string(557, 234, "Stdby", .7, .7, .7)
    draw_string(467, 220, "COM1", .9, .9, .9)
    draw_string(467, 206, "COM2", .9, .9, .9)
    draw_string(467, 190, "NAV1", .9, .9, .9)
    draw_string(467, 176, "NAV2", .9, .9, .9)
    draw_string(467, 160, "ADF1", .9, .9, .9)
    draw_string(467, 143, "XPDR", .9, .9, .9)

    --display radio data only if the battery is on
    if batteryOn then
        if avBusOn == 1 then
            --display data only if the avionics bus is on
            draw_string(507, 220, string.format('%.2f', com1), .1, 1, .1)
            draw_string(557, 220, string.format('%.2f', com1S), 0, .7, 0)
            draw_string(507, 190, string.format('%.2f', nav1), .1, 1, .1)
            draw_string(557, 190, string.format('%.2f', nav1S), 0, .7, 0)
            if xpMode ~= "OFF" then
                draw_string(507, 142, xpdr, .1, 1, .1)
            end
            draw_string(557, 142, xpMode, .1, 7, .1)
            if crossTie == 1 then
                --display data only if the cross tie to bus 2 is on
                draw_string(507, 206, string.format('%.2f', com2), .1, 1, .1)
                draw_string(557, 206, string.format('%.2f', com2S), 0, .7, 0)
                draw_string(507, 176, string.format('%.2f', nav2), .1, 1, .1)
                draw_string(557, 176, string.format('%.2f', nav2S), 0, .7, 0)
                draw_string(507, 160, adf1, .1, 1, .1)
                draw_string(557, 160, adf1S, 0, .7, 0)
            end
        end
    end

    --GPS
    draw_string(467, 121, "Nxt GPS Wpt", 1, 1, 1)

    graphics.set_color(.6, .6, .6, .5)
    graphics.draw_rectangle(542, 116, 599, 130)
    graphics.set_color(0, 0, 0, .425)
    graphics.draw_rectangle(543, 117, 598, 129)

    if batteryOn and avBusOn == 1 then
        draw_string(545, 120, gpsNavID0, 0, 1, 0)
    end
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

function draw_data_box()
    leftMargin = 40
    local col1 = 198
    local col2 = 213
    local col3 = 157
    border = 1

    local showCol1 = showAircraft or showWeather or showSimulator
    local showCol2 = showLocation or showEngine
    local showCol3 = showRadio or showAutopilot

    outerWidth = leftMargin
    if showCol1 then
        outerWidth = outerWidth + col1 + border
    end
    if showCol2 then
        outerWidth = outerWidth + col2 + border
    end
    if showCol3 then
        outerWidth = outerWidth + col3 + border
    end

    --Draw outer box
    if outerWidth > leftMargin then
        graphics.set_color(.9, .9, .9, .325)
        graphics.draw_rectangle(leftMargin, 11, outerWidth + border, 265)
    end

    --Backgrounds
    graphics.set_color(.1, .1, .1, .425)
    colBegin = leftMargin + border
    if showCol1 then
        graphics.draw_rectangle(colBegin, 12, colBegin + col1, 264)
        colBegin = colBegin + col1 + border
    end
    if showCol2 then
        graphics.draw_rectangle(colBegin, 12, colBegin + col2, 264)
        col2Start = colBegin
        colBegin = colBegin + col2 + border
    end
    if showCol3 then
        graphics.draw_rectangle(colBegin, 12, colBegin + col3, 264)
        col3Start = colBegin
    end

end

function power_warn_box()
    local left = leftMargin + ((outerWidth - leftMargin) / 2) - 100
    local right = leftMargin + ((outerWidth - leftMargin) / 2) + 100
    local bottom = 100
    local top = 175
    --optional function to let the pilot know the battery is not on
    graphics.set_color(.2, .2, .2, .6)
    graphics.draw_rectangle(left, bottom, right, top)
    graphics.set_color(.8, .8, .2, .6)
    graphics.draw_rectangle(left + 3, bottom + 3, right - 3, top - 3)
    draw_string(left + 38, top - 20, "-= Flight Data Viewer =-", 1, 0, 0)
    draw_string(left + 70, top - 45, "NO POWER!", 1, 0, 0)
    draw_string(left + 59, top - 59, "Turn Battery On", 1, 0, 0)
end

function mainProg()
    if isActive then
        batteryOn = mainBatteryOn ~= 0

        if batteryOn and reloadParams then
            load_params()
            reloadParams = false
        end
        draw_data_box()
        show_flight_data()

        if not batteryOn then
            power_warn_box()
            reloadParams = true
        end
    end
end

reloadParams = false

--Main Program
load_params()
getDataRefs()
do_every_draw("mainProg()")

add_macro("Show Flight Data Window", "isActive = true", "isActive = false", "activate")