ConfigSubmixes = {
    micro = {
        filters = {
            freq_low    = 50.0,
            freq_hi     = 10000.0,
            rm_mod_freq = 300.0,
            rm_mix      = 0.05,
            fudge       = 1.0,
            o_freq_lo   = 50.0,
            o_freq_hi   = 6000.0,
        }
    },
    megaphone = {
        filters = {
            freq_low    = 10.0,
            freq_hi     = 10000.0,
            rm_mod_freq = 300.0,
            rm_mix      = 0.2,
            fudge       = 0.0,
            o_freq_lo   = 200.0,
            o_freq_hi   = 5000.0,
        }
    },
    muffled = {
        filters = {
            freq_low  = 0.0,
            freq_hi   = 850.0,
            rm_mix    = 0.00,
            o_freq_lo = 0.0,
            o_freq_hi = 850.0,
        }
    },
    radio_default = {
        filters = {
            freq_low    = 100.0,
            freq_hi     = 5000.0,
            rm_mod_freq = 300.0,
            rm_mix      = 0.1,
            fudge       = 4.0,
            o_freq_lo   = 300.0,
            o_freq_hi   = 5000.0,
        }
    },
    radio_medium_distance = {
        filters = {
            freq_low    = 100.0,
            freq_hi     = 5000.0,
            rm_mod_freq = 300.0,
            rm_mix      = 0.5,
            fudge       = 10.0,
            o_freq_lo   = 300.0,
            o_freq_hi   = 5000.0,
        }
    },
    radio_far_distance = {
        filters = {
            freq_low    = 100.0,
            freq_hi     = 5000.0,
            rm_mod_freq = 300.0,
            rm_mix      = 0.8,
            fudge       = 16.0,
            o_freq_lo   = 300.0,
            o_freq_hi   = 5000.0,
        }
    },
}

CreateThread(function()
    for submixName, submix in pairs(ConfigSubmixes) do
        local submixId = CreateAudioSubmix(submixName)
        SetAudioSubmixEffectRadioFx(submixId, 0)
        SetAudioSubmixEffectParamInt(submixId, 0, `default`, 1)
        for key, value in pairs(submix.filters) do
            SetAudioSubmixEffectParamFloat(submixId, 0, GetHashKey(key), value)
        end
        AddAudioSubmixOutput(submixId, 0)
        submixIndicies[submixName] = submixId
    end
end)

AddStateBagChangeHandler("submix", "", function(bagName, _, value)
	local tgtId = tonumber(bagName:gsub('player:', ''), 10)
	if not tgtId then return end
	-- We got an invalid submix, discard we don't care about it
	if value and not submixIndicies[value] then
		return logger.warn("Player %s applied submix %s but it isn't valid",
			tgtId, value)
	end
	-- we don't want to reset submix if the player is talking on the radio
	if not value then
		if not radioData[tgtId] and not callData[tgtId] then
			logger.info("Resetting submix for player %s", tgtId)
			MumbleSetSubmixForServerId(tgtId, -1)
		end
		return
	end
	logger.info("%s had their submix set to %s", tgtId, value)
	MumbleSetSubmixForServerId(tgtId, submixIndicies[value])
end)
