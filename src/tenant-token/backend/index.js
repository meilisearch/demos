require("dotenv").config();
const express = require("express");
const cors = require("cors");
const { MeiliSearch } = require("meilisearch");
const app = express();

const client = new MeiliSearch({
  host: process.env.MEILI_HOST || "http://localhost:7700",
  apiKey: process.env.MEILI_MASTER_KEY,
});

app.use(cors());

app.get("/", function (req, res) {
  return res.send("Tenant Token demo");
});

app.get("/create-tenant-token", async (req, res) => {
  const { value: patientName } = req.query;

  /* Replace this comment with the API request */

  const { results } = await client.getKeys();
  const apiKey = results.filter((res) => res.name === "Default Search API Key")[0].key;
  const apiKeyUid = results.filter((res) => res.name === "Default Search API Key")[0].uid;

  const payload = {
    tenant_token: {
      filter: `patient = ${patientName}`,
    },
  };

  const expiresAt = new Date(
    new Date().setFullYear(new Date().getFullYear() + 1)
  );

  const tenantToken = client.generateTenantToken(apiKeyUid, payload, {
    apiKey,
    expiresAt,
  });
  return res.json({ token: tenantToken });
});

const port = process.env.PORT || 5001;

app.listen(port, async () => {
  console.log(`Server started at PORT: ${port}`);
});
