const express = require('express')
const axios = require('axios')
const btoa2 = require('btoa')
const qs = require('qs')

const app = express()
const port: Number = 3000

const CLIENT_ID: String = "21ec911ab7df44a19f570f851bfc9104"
const CLIENT_SECRET: String = ""
const REDIRECT_URI: String = "CustomWidgets://spotify-login-callback"

const creds = btoa2(`${CLIENT_ID}:${CLIENT_SECRET}`)

app.get('/', (req, res) => res.send('Hello World!'))

app.get('/authorize', (req, res) => {
    if(req.query.auth_code) {
        let auth_code = req.query.auth_code

        let data = {
            grant_type: "authorization_code",
            code: auth_code,
            redirect_uri: REDIRECT_URI,
            client_id: CLIENT_ID,
            client_secret: CLIENT_SECRET
        }

        let headers = {
            headers: {
                "Accept": "application/json",
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        }

        axios.post("https://accounts.spotify.com/api/token", qs.stringify(data), headers).then(
            async (response) => {
                console.log(response.data)
                res.status(200).json(response.data)
            },

            (error) => {
                console.log(error)
                res.status(400).send('Failure!')
            }
            
            )
    }

    else {
        res.status(400).send('Failure!')
    }
})

app.get('/refresh', (req, res) => {
    if(req.query.refresh_token) {
        let refresh_token = req.query.refresh_token

        let data = {
            grant_type: "refresh_token",
            refresh_token: refresh_token
        }

        let headers = {
            headers: {
                "Authorization": `Basic ${creds}`
            }
        }

        axios.post("https://accounts.spotify.com/api/token", qs.stringify(data), headers).then(
            async (response) => {
                console.log(response.data)
                res.status(200).json(response.data)
            },

            (error) => {
                console.log(error)
                res.status(400).send('Failure!')
            }
        )
    }

    else {
        res.status(400).send('Failure!')
    }
})



app.listen(port, () => console.log(`Example app listening at http://localhost:${port}`))