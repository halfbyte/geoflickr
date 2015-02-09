$(function() {

  $('[data-geojson]').each(function() {

    $map = $(this);
    var mapId = $map.data('mapbox-id');
    var mapboxAccessToken = $map.data('mapbox-access-token');
    L.mapbox.accessToken = mapboxAccessToken;

    var map = L.mapbox.map(this, mapId);


    var heat = L.heatLayer([], { max: 0.1});
    var featureLayer = L.mapbox.featureLayer()
        .loadURL($map.data('geojson'), function(e) {console.log("maybe ready?")} )
        .on('ready', function(e) {
          map.fitBounds(featureLayer.getBounds());
          featureLayer.eachLayer(function(l) {
            heat.addLatLng(l.getLatLng());
          });
        });
    map.on('zoomend', function() {
      var zoom = map.getZoom();
      if (zoom >= 14) {
        if (map.hasLayer(heat)) map.removeLayer(heat);
        if (!map.hasLayer(featureLayer)) map.addLayer(featureLayer);

      } else {
        if (map.hasLayer(featureLayer)) map.removeLayer(featureLayer);
        if (!map.hasLayer(heat)) map.addLayer(heat);

      }
      console.log("ZOOM", map.getZoom());
    })
  });
});