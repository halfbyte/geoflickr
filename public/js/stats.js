$(function() {

  _.templateSettings = {
    interpolate: /\{\{(.+?)\}\}/g
  };


  var $stats = $('[data-stats-url]')
  var url = $stats.data('stats-url')
  var template = _.template($('#stat-entry').html());
  $.getJSON(url, {}).then(function(data) {
    var max = 0;
    var len = data.tags.length;

    $('#all-entries').text(data.all);
    $('#geocoded-entries').text(data.geocoded);
    var geocodedPercent = (data.geocoded / data.all * 100).toFixed(2);

    $('#geocoded-entries-percent').text(geocodedPercent);
    $('#geocoded-entries-bar').css("width", "" + geocodedPercent + "%")
    $('#tagged-entries').text(data.tagged);
    var taggedPercent = (data.tagged / data.all * 100).toFixed(2)
    $('#tagged-entries-percent').text(taggedPercent);
    $('#tagged-entries-bar').css("width", "" + taggedPercent + "%")
    data.tags.forEach(function(stat, i) {
      var hue = i/len * 180;

      if(stat.count > max) max = stat.count;
      $stats.append(template({tag: stat.tag, count: stat.count, hue: hue }))
    });
    data.tags.forEach(function(stat) {
      $('#tag-' + stat.tag).css("width", "" + (stat.count/max * 100.0) + "%");
    });

  });
})