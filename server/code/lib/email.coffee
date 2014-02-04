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
  # `user` should be a user object
  # `token` should be a string
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


exports.passwordResetEmail = (userList, callback) ->
  # `userList` should be a list of user objects, with a .token property added.
  if userList.length == 1
    mailOptions =
      from: 'hello@scraperwiki.com'
      to: userList[0].email[0]
      subject: "Reset your ScraperWiki password"
      text: """
      Hi #{userList[0].displayName},

      Someone has requested a password reset for
      your ScraperWiki account.

      If this was you, please reset your password here:
        https://scraperwiki.com/set-password/#{userList[0].token}

      Thanks,

      ScraperWiki
      """
  else
    urlList = []
    for user in userList
      urlList.push("""
                   Username: #{user.shortName}

                   Reset link: https://scraperwiki.com/set-password/#{user.token}
                   """)
    urlList = urlList.join "\n\n"
    mailOptions =
      from: 'hello@scraperwiki.com'
      to: userList[0].email[0]
      subject: "Reset your ScraperWiki password"
      text: """
      Hi #{userList[0].displayName},

      Someone has requested a password reset for
      your ScraperWiki accounts.

      If this was you, please reset your password here:

      #{urlList}

      Thanks,

      ScraperWiki
      """

  sendGridEmail mailOptions, callback
