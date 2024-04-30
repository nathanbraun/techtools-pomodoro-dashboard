export const flags = ({ env }) => {
  const storedApiUrl = localStorage.getItem('apiUrl');
  return {
    apiUrl: storedApiUrl || null
  }
}

export const onReady = ({ app, env }) => {
  if (app.ports && app.ports.outgoing) {
    app.ports.outgoing.subscribe(({ tag, data }) => {
      switch (tag) {
        case 'LOG_ERROR':
          console.log(data);
          return
        case 'API_URL':
        localStorage.setItem('apiUrl', data);
          console.log(data);
          return
        default:
          console.warn(`Unhandled outgoing port: "${tag}"`)
      }
    })
  }

}
