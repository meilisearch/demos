require("dotenv").config();
const jsonCreator = require("./json-creator.js");
const meiliSearchSeed = require("./seed.js");

(async () => {
  await jsonCreator();
  await meiliSearchSeed();
})();
