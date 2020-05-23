$(function () {
    window.onload = (e) => {
        /* 'links' the js with the Nui message from main.lua */
        window.addEventListener('message', (event) => {
            //document.querySelector("#logo").innerHTML = " "
            var item = event.data;
            if (item !== undefined && item.type === "gangzone") {
                var map = window.Map;

				//L.tileLayer(e.url).addTo(map);

				var bounds1 = convertToMapLeaflet(item.zone.ginfo1, item.zone.ginfo2);
				var bounds2 = convertToMapLeaflet(item.zone.ginfo3, item.zone.ginfo4);
				var bounds = [[bounds1], [bounds2]];

				/*var rect = L.rectangle(bounds, {color: 'blue', weight: 1}).on('click', function (e) {
					// There event is event object
					// there e.type === 'click'
					// there e.lanlng === L.LatLng on map
					// there e.target.getLatLngs() - your rectangle coordinates
					// but e.target !== rect
					console.info(e);
				}).addTo(map);*/
				
				L.rectangle(bounds, {color: "#ff7800", weight: 1}).addTo(map);
				// zoom the map to the rectangle bounds
				map.fitBounds(bounds);
            }
        });
    };
});