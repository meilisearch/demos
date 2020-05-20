var beautify=n=>((Math.log10(n)/3|0)==0)?n:Number((n/Math.pow(10,(Math.log10(n)/3|0)*3)).toFixed(1))+["","K","M","B","T",][Math.log10(n)/3|0];
var source = document.getElementById("entry-template").innerHTML;
var template = Handlebars.compile(source);

function innerText(s) {
  var div = document.createElement('div');
  div.innerHTML = s;
  return div.innerText;
}

function getParam(key) {
  var params = new URLSearchParams(window.location.search);
  return params.get(key);
}

function setGetParam(key,value) {
  if (history.pushState) {
    var params = new URLSearchParams(window.location.search);
    params.set(key, value);
    var newUrl = window.location.protocol + "//" + window.location.host + window.location.pathname + '?' + params.toString();
    window.history.pushState({path:newUrl},'',newUrl);
  }
}

function handleForm() {
  let currentIndex = $('#current-index').val();
  let elem = $(`#gem-${currentIndex}`)[0];
  if (elem) {
    window.open(elem.firstElementChild.href);
  }
  return false;
}

$(document).ready(function () {
  var url = 'https://finding-demos.meilisearch.com';
  var indexUID = 'rubygems';
  var publicKey = '2b902cce4f868214987a9f3c7af51a69fa660d74a785bed258178b96e3480bb3';
  var request;

  Handlebars.registerHelper("formatBigNumber", beautify);
  Handlebars.registerHelper("innerText", innerText);

  amplitude.getInstance().logEvent('page_loaded');
  $("#textSearch").on('input', function () {
    let value = $("#textSearch").val();

    setGetParam('q', value);

    if (request) { request.abort() }

    request = $.ajax({
      url: `${url}/indexes/${indexUID}/search`,
      type: 'GET',
      headers: {
        'X-Meili-API-Key': publicKey
      },
      data: {
        'attributesToHighlight': '*',
        'q': value,
        'limit': 10
      },
      dataType: 'json',
      success: function (data, status) {
        amplitude.getInstance().logEvent('search', {
          'query': data.query,
          'time': data.processingTimeMs
        });
        $("#request-time").text(`${data.processingTimeMs} ms`);
        $("#handlebars-list").empty();
        let out_html = "";
        let len = 0;
        $.each(data.hits, function (_, value) {
          final_value = Object.assign(value, value['_formatted'])
          final_value = Object.assign(final_value, { 'index': len })
          out_html += template(value);
          len += 1;
        });
        $('#rslt-len').val(len);
        $('#current-index').val(0);
        $("#handlebars-list").html(out_html);
        $('#gem-0').css('background-color', '#f7f7f7');
      },
    });
  });

  let query = getParam('q');
  if (query) {
    $("#textSearch").val(query).trigger("input");
  }
});

$(document).keydown(function(e) {
  let indexMax = $('#rslt-len').val() > 0 ? $('#rslt-len').val() - 1 : 0;
  let currentIndex = $('#current-index').val();

  switch(e.which) {
      case 38: // up
      if (currentIndex > 0) {
        $(`#gem-${currentIndex}`).css('background-color', 'white');
        currentIndex = parseInt(currentIndex) - 1;
        $(`#gem-${currentIndex}`).css('background-color', '#f7f7f7');
        $('#current-index').val(currentIndex);
      }
      break;

      case 40: // down
      if (currentIndex < indexMax) {
        $(`#gem-${currentIndex}`).css('background-color', 'white');
        currentIndex = parseInt(currentIndex) + 1;
        $(`#gem-${currentIndex}`).css('background-color', '#f7f7f7');
        $('#current-index').val(currentIndex);
      }
      break;

      default: return; // exit this handler for other keys
  }
  e.preventDefault(); // prevent the default action (scroll / move caret)
});
