nodemailer = require("nodemailer")

#TODO: html email (templates?)
#
exports.signUpEmail = (user, token, callback) ->
  transport = nodemailer.createTransport "sendmail"

  mailOptions =
    from: 'feedback@scraperwiki.com'
    to: user.email[0]
    subject: "Activate your ScraperWiki account!"
    text: """
    Hi #{user.displayName},

    To activate your ScraperWiki account, please go to:
      https://x.scraperwiki.com/set-password/#{token}

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
