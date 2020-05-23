resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

Discription "Gangwars"

Version "0.1"

ui_page "nui/index.html"

files ({
    "nui/index.html",
    "nui/gulpfile.js",
	"nui/version.json",
	"nui/config.json",
	"nui/dist/first-bundle.js",
	"nui/dist/last-bundle.js",
	"nui/dist/stylesheet.css",
	"nui/js/src/alerter.1.js",
	"nui/js/src/controls.2.js",
	"nui/js/src/init.1.js",
	"nui/js/src/map.1.js",
	"nui/js/src/markers.1.js",
	"nui/js/src/objects.1.js",
	"nui/js/src/socket.1.js",
	"nui/js/src/utils.1.js",
	--"nui/js/src/script.js",
	--"nui/js/src/version-check.2.js",
	"nui/js/vendor/a_jquery-3.3.1.js",
	"nui/js/vendor/b_bootstrap.js",
	"nui/js/vendor/c_bootstrap-notify.js",
	--"nui/js/vendor/d_version_check.js",
	"nui/js/vendor/e_leaflet.markercluster-src.js",
	"nui/style/src/style.css",
	"nui/style/vendor/all.css",
	"nui/style/vendor/bootstrap.css",
	"nui/style/vendor/MarkerCluster.css",
	"nui/style/webfonts/fa-brands-400.ttf",
	"nui/style/webfonts/fa-regular-400.ttf",
	"nui/style/webfonts/fa-solid-900.ttf",
	"nui/style/webfonts/fa-brands-400.eot",
	"nui/style/webfonts/fa-regular-400.eot",
	"nui/style/webfonts/fa-solid-900.eot",
	"nui/style/webfonts/fa-brands-400.svg",
	"nui/style/webfonts/fa-regular-400.svg",
	"nui/style/webfonts/fa-solid-900.svg",
	"nui/style/webfonts/fa-brands-400.woff",
	"nui/style/webfonts/fa-regular-400.woff",
	"nui/style/webfonts/fa-solid-900.woff",
	"nui/style/webfonts/fa-brands-400.woff2",
	"nui/style/webfonts/fa-regular-400.woff2",
	"nui/style/webfonts/fa-solid-900.woff2",
	"nui/images/icons/blips.png",
	"nui/images/icons/blips_texturesheet.png",
	"nui/images/icons/debug.png",
	"nui/images/icons/normal.png",
	"nui/images/tiles/normal/minimap_sea_0_0.png",
	"nui/images/tiles/normal/minimap_sea_0_1.png",
	"nui/images/tiles/normal/minimap_sea_1_1.png",
	"nui/images/tiles/normal/minimap_sea_1_0.png",
	"nui/images/tiles/normal/minimap_sea_2_0.png",
	"nui/images/tiles/normal/minimap_sea_2_1.png",
	"nui/images/tiles/normal/stitched.png"
})

client_script "client.lua"
server_script "server.lua"
server_script '@mysql-async/lib/MySQL.lua'
server_script "live_map.net.dll"
