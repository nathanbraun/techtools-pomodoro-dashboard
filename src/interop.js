export const flags = ({ env }) => {
  const storedApiUrl = localStorage.getItem('apiUrl');
  const storedLicenseKey = localStorage.getItem('licenseKey');
  return {
    apiUrl: storedApiUrl || null,
    licenseKey: storedLicenseKey || null
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
        case 'LICENSE_KEY':
          localStorage.setItem('licenseKey', data);
          console.log(data);
          return
        default:
          console.warn(`Unhandled outgoing port: "${tag}"`)
      }
    })
  }

}
