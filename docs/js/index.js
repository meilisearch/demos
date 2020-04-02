const MEILI_SEARCH_URL="https://a86ecd85.getmeili.com/indexes/PYPIPKG/search"
const PYPI_MEILI_PUBLIC_KEY="af44fcf9beb71077c77e64c30ac7089ab4c8499c6f16c278583456e9be816a3e"

var xhttp;

function searchMeili (query) {

    const resultsField = document.getElementById("results-container")
    const responseTimeField = document.getElementById("response-time")

    setGetParam("q",query)

    console.log(xhttp);

    if (xhttp) {
        console.log("YOOOOOOOOOOOOOOO");
        xhttp.abort()
    }
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
    xhttp.open("GET", MEILI_SEARCH_URL + "?q=" + query, true);
    xhttp.setRequestHeader("X-Meili-API-Key", PYPI_MEILI_PUBLIC_KEY)
    xhttp.send();
}

function handleResults(results, resultsField) {
    results.hits.forEach( function( item ) {
        description = item.description;
        if (description != undefined && description.length <=1) {
            description = "[No description]"
        }
        html = `
        <a href="${item.project_url}">
            <div class="pkg-result">
                <div class="result-head">
                    <div class="result-name">
                        ${item.name.substring(0, 24) + " " + item.version}
                    </div>
                </div>
                <div class="result-body">
                    <div class="result-description">
                        ${description}
                    </div>
                </div>
            </div>
        </a>
        `;
        resultsField.innerHTML += html;
    });
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
