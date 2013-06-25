nodemailer = require("nodemailer")

#TODO: html email (templates?)

exports.signUpEmail = (user, token, callback) ->
  transport = nodemailer.createTransport 'SMTP',
    service: "SendGrid"
    auth:
      user: process.env.CU_SENDGRID_USER
      pass: process.env.CU_SENDGRID_PASS

  mailOptions =
    from: 'hello@scraperwiki.com'
    to: user.email[0]
    subject: "Activate your ScraperWiki account!"
    text: """
    Hi #{user.displayName},

    To activate your ScraperWiki account, please go to:
      https://beta.scraperwiki.com/set-password/#{token}

    Ta,

    ScraperWiki
    """

  # send mail with defined transport object
  transport.sendMail mailOptions, (err, res) ->
    transport.close()
    if err?
      callback err
    else
      callback null

exports.dataRequestEmail = (dataRequest, callback) ->
  transport = nodemailer.createTransport 'SMTP',
    service: "SendGrid"
    auth:
      user: process.env.CU_SENDGRID_USER
      pass: process.env.CU_SENDGRID_PASS

  mailOptions =
    from: dataRequest.email
    to: process.env.CU_REQUEST_EMAIL
    subject: "Data Request [ID #{dataRequest.id}] from #{dataRequest.name}"
    text: """
    [ID #{dataRequest.id}] Call back request from #{dataRequest.name}

    Name: #{dataRequest.name}

    Phone: #{dataRequest.phone}

    Email: #{dataRequest.email}

    Description: #{dataRequest.description}

    """

  # send mail with defined transport object
  transport.sendMail mailOptions, (err, res) ->
    transport.close()
    if err?
      callback err
    else
      callback null
