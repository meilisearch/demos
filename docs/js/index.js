const MEILI_SEARCH_URL="https://522ca981.getmeili.com/indexes/PYPIPKG/search"
const PYPI_MEILI_PUBLIC_KEY="a16242a5745c22b8dde108c57af383c23c9c36426e98443d5012e4c4354a10de"

var xhttp;

function searchMeili (query) {

    const resultsField = document.getElementById("results-container")
    const responseTimeField = document.getElementById("response-time")

    if (xhttp) {
        xhttp.abort()
    }
    setGetParam("q",query)
    if (query.length == 0) {
        emptyResults(resultsField, responseTimeField)
        return
    }

    xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            emptyResults(resultsField, responseTimeField)
            var html = ""
            results = JSON.parse(this.responseText)
            responseTimeField.innerHTML = ""
            if (results.hits.length > 0) {
                responseTimeField.innerHTML = "Search request processed in " + results.processingTimeMs+ " ms";
                handleResults(results, resultsField)
            }
            else {
                resultsField.innerHTML = "<h1>No results for query \"" + query +"\" :(</h1>"
            }
            resultsField.innerHTML += "<hr>"
        }
    };
    xhttp.open("GET", MEILI_SEARCH_URL + "?q=" + query + "&attributesToHighlight=*", true);
    xhttp.setRequestHeader("X-Meili-API-Key", PYPI_MEILI_PUBLIC_KEY)
    xhttp.send();
}

function handleResults(results, resultsField) {
    var html = ""
    results.hits.forEach( function( item ) {
        console.log(item);
        description = item._formatted.description;
        if (description != undefined && description.length <=1) {
            description = "[No description]"
        }
        html += `
            <div class="pkg-result">
                <div class="result-head">
                    <div class="result-name">
                        ${item._formatted.name}
                    </div>
                    <div class="result-version">
                        ${item.version.toString().substring(0, 10)}
                    </div>
                </div>
                <div class="result-body">
                    
                    <div class="result-description">
                        <div class="result-description-img">
                            <img src="img/cube.png" alt="${item.name}" width="30" />
                        </div>
                        <div class="result-description-content">
                        ${description}
                        </div>
                    </div>
                </div>
            </div>
        `;
    });
    resultsField.innerHTML = html;
}

function emptyResults(resultsField, responseTimeField) {
    resultsField.innerHTML = "";
    responseTimeField.innerHTML ="";
}

function setGetParam(key,value) {
  if (history.pushState) {
    var params = new URLSearchParams(window.location.search);
    params.set(key, value);
    var newUrl = window.location.protocol + "//" + window.location.host + window.location.pathname + '?' + params.toString();
    window.history.pushState({path:newUrl},'',newUrl);
  }
}