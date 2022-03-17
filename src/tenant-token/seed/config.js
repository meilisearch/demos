const MEILISEARCH_CONFIG = {
  HOST: "http://localhost:7700",
  MASTER_KEY: process.env.MEILI_API_KEY,
  INDEX_NAME: "tenant_token",
};
const userNameList = [
  "Zia",
  "Kevin",
  "Charlotte",
  "Tom",
  "John",
  "Mary",
  "Smith",
  "Bill",
  "Mike",
  "Hannah",
  "Seth",
];

const diseaseList = [
  "Diabetes",
  "Covid",
  "Malaria",
  "Dengue",
  "Cold and cough",
  "Typhoid",
];

module.exports = { MEILISEARCH_CONFIG, userNameList, diseaseList };
