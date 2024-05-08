export const flags = ({ env }) => {
  const storedApiUrl = localStorage.getItem('apiUrl');
  const storedPasskey = localStorage.getItem('passkey');
  const storedTestDataFlag = localStorage.getItem('testDataFlag') !== 'false';

  console.log(storedTestDataFlag);
  return {
    apiUrl: (storedApiUrl !== null) ? storedApiUrl : null,
    passkey: (storedPasskey !== null) ? storedPasskey : "TECHTOOLS1",
    testDataFlag: storedTestDataFlag
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
        case 'TEST_DATA_FLAG':
          if (data === null) {
            localStorage.removeItem('testDataFlag');
          } else {
            localStorage.setItem('testDataFlag', data);
          }
          console.log(data);
          return
        case 'PASSKEY':
          if (data === null) {
            localStorage.removeItem('passkey');
          } else {
            localStorage.setItem('passkey', data);
          }
          console.log(data);
          return
        default:
          console.warn(`Unhandled outgoing port: "${tag}"`)
      }
    })
  }

}
