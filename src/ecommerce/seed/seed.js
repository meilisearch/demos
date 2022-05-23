require("dotenv").config();
const fs = require("fs");
const { MeiliSearch } = require("meilisearch");

const client = new MeiliSearch({
  host: process.env.NEXT_PUBLIC_MEILI_HOST_NAME,
  apiKey: process.env.NEXT_PUBLIC_MEILI_API_KEY,
});

const index = client.index("products");

const data = require("./data.json");

(async () => {
  await index.updateFilterableAttributes([
    "brand",
    "category",
    "tag",
    "rating",
    "reviews_count",
    "price",
  ]);
  console.log("Filterable Attributes Updated");
  await index.updateSortableAttributes(["reviews_count", "rating", "price"]);
  console.log("Sortable Attributes Updated");
  await index.updateDocuments(data);
  console.log("Documents Updated");
})();
