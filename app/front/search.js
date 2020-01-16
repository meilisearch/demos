var beautify=n=>((Math.log10(n)/3|0)==0)?n:Number((n/Math.pow(10,(Math.log10(n)/3|0)*3)).toFixed(1))+["","K","M","B","T",][Math.log10(n)/3|0];
var source = document.getElementById("entry-template").innerHTML;
var template = Handlebars.compile(source);

function innerText(s) {
  var div = document.createElement('div');
  div.innerHTML = s;
  return div.innerText;
}

$(document).ready(function () {

  var projectName = '51dcb49b';
  var indexName = 'gems';
  var request;

  Handlebars.registerHelper("formatBigNumber", beautify);
  Handlebars.registerHelper("innerText", innerText);

  $("#textSearch").on('input', function () {
    let value = $("#textSearch").val();

    if (request) { request.abort() }

    request = $.ajax({
      url: `https://${projectName}.getmeili.com/indexes/${indexName}/search`,
      type: 'GET',
      data: {
        'attributesToHighlight': '*',
        'q': value
      },
      dataType: 'json',
      success: function (data, status) {
        $("#request-time").text(`${data.processingTimeMs} ms`);
        $("#handlebars-list").empty();
        let out_html = "";
        $.each(data.hits, function (_, value) {
          final_value = Object.assign(value, value['_formatted'])
          out_html += template(final_value);
        });
        $("#handlebars-list").html(out_html)
      },
    });
  });

});


