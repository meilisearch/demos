const MEILI_SEARCH_URL="https://522ca981.getmeili.com/indexes/PYPIPKG/search"
const PYPI_MEILI_PUBLIC_KEY="a16242a5745c22b8dde108c57af383c23c9c36426e98443d5012e4c4354a10de"

var xhttp;
let currentIndex = 0;

function searchMeili (query) {

    const resultsField = document.getElementById("results-container")
    const responseTimeField = document.getElementById("response-time")
    currentIndex = 0

    if (xhttp) {
        xhttp.abort()
    }
    setGetParam("q",query)
    if (query.length == 0) {
        emptyResults(resultsField, responseTimeField)
        resultsField.innerHTML = "<br><h5>Start typing a package name or keyword in the search bar</h5>"
        resultsField.innerHTML += "<img src='./img/python.png'/><hr>"
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
                responseTimeField.innerHTML += " <img src='./img/watch.png' width='15'>";
                handleResults(results, resultsField)
            }
            else {
                resultsField.innerHTML = "<br><h5>No results for query \"" + query +"\""
                resultsField.innerHTML += "<img src='./img/sad.png'/><hr>"
            }
        }
    };
    xhttp.open("GET", MEILI_SEARCH_URL + "?q=" + query + "&attributesToHighlight=*&limit=8", true);
    xhttp.setRequestHeader("X-Meili-API-Key", PYPI_MEILI_PUBLIC_KEY)
    xhttp.send();
}

function handleResults(results, resultsField) {
    var html = ""
    index = 0;
    results.hits.forEach( function( item ) {
        console.log(item);
        description = item._formatted.description;
        version = ""
        if (item.version !== undefined) {
            version = item.version.toString().substring(0, 10)
        }
        if (description != undefined && description.length <=1) {
            description = "[No description]"
        }
        id = "result-" + item.name
        html += `
            <a href="${item.project_url}" target="_blank">
            <div class="pkg-result" id="result-${index}">
                <input id="url-${index}" class="url" type="hidden" value="${item.project_url}" />
                <div class="result-head">
                    <div class="result-name">
                        ${item._formatted.name}
                    </div>
                    <div class="result-version">
                        ${version}
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
            </a>
        `;
        index++;
        resultsField.innerHTML = html;
    });
    selectItem("UP");
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

function handleArrow(event) {

    switch(event.keyCode) {
        case 13:
            event.preventDefault()
            url = document.getElementById('url-'+parseInt(currentIndex)).value
            window.open(url,'_blank');
            break

        case 38:
            event.preventDefault()
            selectItem("UP")
            break

        case 40:
            event.preventDefault()
            selectItem("DOWN")
            break
    }
}

function selectItem(direction) {
    prevSelected = document.getElementById('result-'+parseInt(currentIndex));
    prevSelected.classList.remove('item-selected');
    if (direction == "UP") {
        currentIndex = currentIndex > 0 ? currentIndex -1 : 0;
    } else {
        currentIndex = currentIndex < index -1 ? currentIndex +1 : index -1;
    }
    currentSelected = document.getElementById('result-'+parseInt(currentIndex));
    currentSelected.classList.add('item-selected');
}