require("dotenv").config();
const express = require("express");
const cors = require("cors");
const { MeiliSearch } = require("meilisearch");
const app = express();

const client = new MeiliSearch({
  host: process.env.MEILI_HOST || "http://localhost:7700",
  apiKey: process.env.MEILI_API_KEY || "masterKey",
});

const apiKeyUid = process.env.MEILI_API_KEY_UID;

app.use(cors());

app.get("/", function (req, res) {
  return res.send("Tenant Token demo");
});

app.get("/create-tenant-token", async (req, res) => {
  const { value: patientName } = req.query;

  /* Replace this comment with the API request */

  const { results } = await client.getKeys();
  const apiKey = results[0].key;

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

const port = process.env.PORT || 5000;

app.listen(port, async () => {
  console.log("Checking for an API Key");
  const { results } = await client.getKeys();
  const apiKeyList = results.filter((res) => res.description === "SEARCH");

  if (apiKeyList.length === 0) {
    await client.createKey({
      description: "SEARCH",
      actions: ["search"],
      indexes: ["tenant_token"],
      uid: apiKeyUid,
      expiresAt: "2025-01-01T00:00:00Z",
    });
    console.log("Created API Key");
  }

  console.log(`Server started at PORT: ${port}`);
});
