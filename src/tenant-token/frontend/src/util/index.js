import axios from 'axios'
import { MEILISEARCH_CONFIG } from 'config'

const apiHost = MEILISEARCH_CONFIG.API_HOST

export const getTenantToken = async (patientName) => {
  /* Replace this comment with the API request */

  const response = await axios({
    url: `${apiHost}/create-tenant-token`,
    method: 'GET',
    params: {
      value: patientName,
    },
  })

  return response.data.token
}
