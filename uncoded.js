$(function() {
  $('[data-uncoded-url]').each(function() {
    var $list = $(this);
    var url = $list.data('uncoded-url');
    var template = _.template($('#uncoded-entry').html());
    $.getJSON(url, {}).then(function(data) {
      $('#uncoded-count').html(data.length);
      data.forEach(function(entry) {
        $list.append(template(entry));
      });
    });
  });
});