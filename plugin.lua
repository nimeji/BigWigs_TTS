-------------------------------------------------------------------------------
-- Module Declaration
--

local sound = BigWigs:GetPlugin("Sounds")
local plugin = BigWigs:NewPlugin("TTS")
if not plugin then return end
plugin.SendMessage = BigWigsLoader.SendMessage

-------------------------------------------------------------------------------
-- Functions
--

local function speak(spell)
	local text = plugin.db.profile[spell] 
	if text == nil then
		return false 
	end

	C_VoiceChat.SpeakText(2, text, Enum.VoiceTtsDestination.LocalPlayback, 2, 75)
	return true
end

--------------------------------------------------------------------------------
-- Hooks
--

plugin.defaultDB = {}

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

-------------------------------------------------------------------------------
-- Initialization
--

function plugin:OnPluginEnable()
	self:RegisterMessage("BigWigs_Voice")
	BigWigsAPI.RegisterVoicePack("tts")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function plugin:BigWigs_Voice(event, module, key, sound, isOnMe)
	if not speak(key) then
		plugin:SendMessage("BigWigs_Sound", module, key, sound) 
	end
end
