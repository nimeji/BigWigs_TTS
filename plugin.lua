-------------------------------------------------------------------------------
-- Module Declaration
--

local sound = BigWigs:GetPlugin("Sounds")
local plugin = BigWigs:NewPlugin("TTS")
if not plugin then return end
plugin.SendMessage = BigWigsLoader.SendMessage

local voiceOptions = {}
for _, voice in ipairs(C_VoiceChat.GetTtsVoices()) do
	voiceOptions[voice.voiceID] = voice.name
end

plugin.defaultDB = {
	voiceId = C_TTSSettings.GetVoiceOptionID(0),
	volume = 100,
	playbackSpeed = 2,
	testPhrase = "",
}

plugin.pluginOptions = {
	type = "group",
	name = "|TInterface\\AddOns\\BigWigs\\Media\\Icons\\Menus\\Voice:20|t Text to Speech",
	desc = "Text to Speech options",
	get = function (i) return plugin.db.profile[i[#i]] end,
	set = function (i, value) plugin.db.profile[i[#i]] = value end,
	args = {
		voiceId = {
			type = "select",
			name = "Voice",
			order = 1,
			values = voiceOptions,
			width = "full",
		},
		volume = {
			type = "range",
			name = "Volume",
			order = 2,
			min = 0,
			max = 100,
			step = 1,
			width = "full",
		},
		playbackSpeed = {
			type = "range",
			name = "Playback Speed",
			order = 3,
			min = 0,
			max = 10,
			step = 0.1,
			width = "full",
		},
		spacer = {
			type = "header",
			name = " ",
			order = 4,
		},
		testPhrase = {
			type = "input",
			name = "Test",
			desc = "Enter some text to test your settings.",
			order = 5,
			width = 1.5,
		},
		testButton = {
			type = "execute",
			name = "Test",
			order = 6,
			func = function()
				C_VoiceChat.SpeakText(
					plugin.db.profile.voiceId, 
					plugin.db.profile.testPhrase, 
					Enum.VoiceTtsDestination.LocalPlayback, 
					plugin.db.profile.playbackSpeed, 
					plugin.db.profile.volume
				)
			end
		}
	}
}

-------------------------------------------------------------------------------
-- Functions
--

local function speak(spell)
	local text = plugin.db.profile[spell] 
	if text == nil then
		return false 
	end

	C_VoiceChat.SpeakText(
		plugin.db.profile.voiceId, 
		text, 
		Enum.VoiceTtsDestination.LocalPlayback, 
		plugin.db.profile.playbackSpeed, 
		plugin.db.profile.volume
	)
	return true
end

--------------------------------------------------------------------------------
-- Hooks
--

local ttsOptions = {
	name = "Text to Speech",
	type = "input",
	order = 10,
	width = "full",
	set = function(info, value)
		local _, spell = unpack(info.arg)
		plugin.db.profile[spell] = value
		speak(spell)
	end,
	get = function(info)
		local _, spell = unpack(info.arg)
		return plugin.db.profile[spell] or ""
	end,
}

sound.soundOptions.args.tts = ttsOptions

sound.__SetSoundOptions = sound.SetSoundOptions
function sound:SetSoundOptions(boss, spell, flags)
	ttsOptions.arg = { boss, spell }
	return self:__SetSoundOptions(boss, spell, flags)
end

local BigWigsOrig = BigWigs
local BigWigsHook = {}
function BigWigsHook:GetPlugin(pluginName)
    if pluginName == "Sounds" then
        return sound
    end

    return BigWigsOrig:GetPlugin(pluginName)
end

BigWigs = setmetatable(BigWigsHook, { __index = BigWigsOrig, __newindex = function() end, __metatable = false })
-------------------------------------------------------------------------------
-- Initialization
--

function plugin:OnPluginEnable()
	self:RegisterMessage("BigWigs_Voice")
end

BigWigsAPI.RegisterVoicePack("tts")

--------------------------------------------------------------------------------
-- Event Handlers
--

function plugin:BigWigs_Voice(event, module, key, sound, isOnMe)
	if not speak(key) then
		plugin:SendMessage("BigWigs_Sound", module, key, sound) 
	end
end
