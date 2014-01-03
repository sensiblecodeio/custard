nodemailer = require("nodemailer")

#TODO: html email (templates?)

sendGridEmail = (mailOptions, callback) ->
  transport = nodemailer.createTransport 'SMTP',
    service: "SendGrid"
    auth:
      user: process.env.CU_SENDGRID_USER
      pass: process.env.CU_SENDGRID_PASS

  # send mail with defined transport object
  transport.sendMail mailOptions, (err, res) ->
    transport.close()
    if err?
      callback err
    else
      callback null


exports.signUpEmail = (user, token, callback) ->
  mailOptions =
    from: 'hello@scraperwiki.com'
    to: user.email[0]
    subject: "Activate your ScraperWiki account!"
    text: """
    Hi #{user.displayName},

    To activate your ScraperWiki account, please go to:
      https://scraperwiki.com/set-password/#{token}

    Thanks,

    ScraperWiki
    """

  sendGridEmail mailOptions, callback
