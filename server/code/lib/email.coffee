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
      https://beta.scraperwiki.com/set-password/#{token}

    Ta,

    ScraperWiki
    """

  sendGridEmail mailOptions, callback

exports.dataRequestEmail = (dataRequest, callback) ->
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

  sendGridEmail mailOptions, callback

exports.dataRequestConfirmation = (dataRequest, callback) ->
  mailOptions =
    from: process.env.CU_REQUEST_EMAIL
    to: dataRequest.email
    subject: "Thank you for your ScraperWiki call-back request [ID #{dataRequest.id}]"
    text: """
    Dear #{dataRequest.name},
    
    Thank you for your ScraperWiki call-back request.
    
    Your ticket ID is ##{dataRequest.id}. A member of our Professional Services team will be in touch shortly.
    
    Regards,
    
    ScraperWiki
    """

  sendGridEmail mailOptions, callback
