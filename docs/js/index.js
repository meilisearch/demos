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
                html = `
                <div class="pkg-result">
                    ${item.name}
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
