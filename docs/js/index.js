const MEILI_SEARCH_URL="https://a86ecd85.getmeili.com/indexes/PYPIPKG/search"
const PYPI_MEILI_PUBLIC_KEY="af44fcf9beb71077c77e64c30ac7089ab4c8499c6f16c278583456e9be816a3e"
function searchMeili (query) {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            var resultsContainer = document.getElementById("results-container")
            resultsContainer.innerHTML ="";
            var html = ""
            results = JSON.parse(this.responseText)

            results.hits.forEach( function( item ) {
                description = item.description;
                if (description.length <=1) {
                    description = "[No description]"
                }
                html = `
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
                `;
                resultsContainer.innerHTML += html;
            });

        }
    };
    xhttp.open("GET", MEILI_SEARCH_URL + "?q=" + query, true);
    xhttp.setRequestHeader("X-Meili-API-Key", PYPI_MEILI_PUBLIC_KEY)
    xhttp.send();
}
