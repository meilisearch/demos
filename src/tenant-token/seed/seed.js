const { MeiliSearch } = require("meilisearch");
const { MEILISEARCH_CONFIG } = require("./config");

const client = new MeiliSearch({
  host: MEILISEARCH_CONFIG.HOST,
  apiKey: MEILISEARCH_CONFIG.MASTER_KEY,
});

const index = client.index(MEILISEARCH_CONFIG.INDEX_NAME);

const meiliSearchSeed = async () => {
  await index.delete();

  const dataList = require("./data.json");
  await index.addDocuments(dataList);

  console.log(
    `Document added to the Meilisearch instance: ${MEILISEARCH_CONFIG.HOST}`
  );

  await index.updateFilterableAttributes(["user", "isDoctorAppointed"]);
  console.log("Filterable attribute updated");

  await index.updateSearchableAttributes(["user", "description", "roomNumber"]);
  console.log("Searchable attribute updated");
};

module.exports = meiliSearchSeed;
