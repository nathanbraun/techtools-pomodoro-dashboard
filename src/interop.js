export const flags = ({ env }) => {
  const storedApiUrl = localStorage.getItem('apiUrl');
  const storedLicenseKey = localStorage.getItem('licenseKey');
  console.log(storedLicenseKey);
  return {
    apiUrl: (storedApiUrl !== null) ? storedApiUrl : null,
    licenseKey: (storedLicenseKey !== null) ? storedLicenseKey : null
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
          if (data === null) {
            localStorage.removeItem('apiUrl');
          } else {
            localStorage.setItem('apiUrl', data);
          }
          console.log(data);
          return
        case 'LICENSE_KEY':
          if (data === null) {
            localStorage.removeItem('licenseKey');
          } else {
            localStorage.setItem('licenseKey', data);
          }
          console.log(data);
          return
        default:
          console.warn(`Unhandled outgoing port: "${tag}"`)
      }
    })
  }

}
