  const express = require('express');
  const app = express()
  const os = require('os')
  const hostname = os.hostname();
  const version = process.env.APP_VERSION
  fetch('https://api.ipify.org?format=json')
    .then(response => response.json())
    .then(data => {
      app.get('/', (req, res) => {
      const response = `Adres IP: ${data.ip}<br>Host: ${hostname}<br>Wersja: ${version}`
      res.send(response)
      });
      app.listen(25, () => {
          console.log("Serwer dziala")
      });
    })
    .catch(error => {
      console.error("Blad: ", error);
    });
