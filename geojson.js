$(function() {

  $('[data-geojson]').each(function() {
    $map = $(this);
    var map = L.mapbox.map(this, 'halfbyte.id964p7c');
    
    var featureLayer = L.mapbox.featureLayer()
        .loadURL($map.data('geojson'), function(e) {console.log("maybe ready?")} )
        .addTo(map).on('ready', function(e) {
          console.log(e.target);
          map.fitBounds(featureLayer.getBounds());
        });    
  });
});