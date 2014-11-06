$(function() {
  $('.filterbutton').click(function() {
    $('#filterform').submit();
  })

  $('.entries').on('click', 'li', function() {
    location.hash=this.id;
  });

  $('[data-uncoded-url]').each(function() {
    var match = location.search.match(/filter=(all|nogps|untagged)/);
    var filter = "all";
    if (match) {
      filter = match[1];
    }
    var filterFunc = function() { return true; }
    if (filter == 'nogps') {

      filterFunc = function(el) { return el.tags.indexOf('nogps') !== -1 }
    } else if (filter == 'untagged') {
      filterFunc = function(el) { return el.tags.indexOf('nogps') === -1 }
    } else {
      filter = "all";
    }
    $('#filter_' + filter).get(0).checked = true;


    var $list = $(this);
    var url = $list.data('uncoded-url');
    var template = _.template($('#uncoded-entry').html());
    $.getJSON(url, {}).then(function(data) {
      $('#uncoded-count').html(data.length);
      var filtered = _(data).filter(filterFunc);
      $('#selected-count').html(filtered.length);
      filtered.forEach(function(entry) {
        $list.append(template(entry));
      });
    });
  });
});