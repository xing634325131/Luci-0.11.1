--[[
Fast Mode
ADD 2014-3-13 @Todaair
]]--

module("luci.controller.todaair.fastmode", package.seeall)

function index()
	entry({"admin", "fastmode", "ap-wds"}, call("ap_wds"), _("Access Point(WDS)"), 1)
	entry({"admin", "fastmode", "repeater"}, template("fastmode/repeater"), _("Repeater"), 2)
	entry({"admin", "fastmode", "repeater-wds"}, template("fastmode/repeater-wds"), _("Repeater(WDS)"), 3)
	entry({"admin", "fastmode", "terminal"}, template("fastmode/terminal"), _("Terminal"), 4)
	entry({"admin", "fastmode", "terminal-wds"}, template("fastmode/terminal-wds"), _("Terminal(WDS)"), 5)
end

function ap_wds()
	luci.template.render("fastmode/ap-wds")
	--[[
	config-wireless
	Add 2014-3-14 @Todaair
	]]--
	uci = luci.model.uci.cursor()
	uci:foreach("wireless","wifi-iface",
		function(section)
			if section[".name"] then
				iface_section=section[".name"]
			end
		end)
	if luci.http.formvalue("cbid.quickwifi.ssid") then
       		quickwifi_ssid = luci.http.formvalue("cbid.quickwifi.ssid") 
     		uci:set("wireless", iface_section,"ssid",quickwifi_ssid) 
	end
	encryption = luci.http.formvalue("cbid.quickwifi.encryption")
	if encryption == "psk-mixed" then
		uci:set("wireless",iface_section,"encryption",encryption)
		if luci.http.formvalue("cbid.quickwifi.key") then
       			quickwifi_key = luci.http.formvalue("cbid.quickwifi.key") 
     			uci:set("wireless",iface_section,"key",quickwifi_key) 
		end
	elseif encryption == "psk" then
		uci:set("wireless",iface_section,"encryption",encryption)
		if luci.http.formvalue("cbid.quickwifi.key") then
       			quickwifi_key = luci.http.formvalue("cbid.quickwifi.key") 
     			uci:set("wireless",iface_section,"key",quickwifi_key) 
		end
	elseif encryption == "none" then
		uci:set("wireless",iface_section,"encryption" ,encryption)
		uci:delete("wireless",iface_section,"key")
	end

	if luci.http.formvalue("cbid.wireless.radio0.channel") then
       		fastmode_channel = luci.http.formvalue("cbid.wireless.radio0.channel") 
     		uci:set("wireless", "radio0","channel",fastmode_channel) 
	end
	if luci.http.formvalue("cbid.wireless.radio0.txpower") then
       		fastmode_txpower = luci.http.formvalue("cbid.wireless.radio0.txpower") 
		if fastmode_txpower == "27" then
			uci:delete("wireless","radio0","txpower")
     		else
			uci:set("wireless", "radio0","txpower",fastmode_txpower) 
		end
	end

	uci:set("wireless",iface_section,"wds","1")  --[[Open WDS]]--
	uci:save("wireless")
	--[[
	config-network
	Add 2014-3-14 @Todaair
	]]--
	if luci.http.formvalue("cbid.fastmode.ipaddr") then
		fastmode_ipaddr = luci.http.formvalue("cbid.fastmode.ipaddr") 
		uci:set("network", "lan", "ipaddr", fastmode_ipaddr) 
	end
	uci:save("network")
	
	if luci.http.formvalue("cbid.fastmode.wds") then
		uci:load("network")
		uci:commit("network")
		uci:load("wireless")
		uci:commit("wireless")
		luci.util.exec("/etc/init.d/network restart")
		luci.sys.call("(env -i /sbin/wifi down; env -i /sbin/wifi up) >/dev/null 2>/dev/null")
	end
end
