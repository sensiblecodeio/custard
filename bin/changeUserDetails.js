// execute this by running:
// livemongo bin/changeUserDetails.js

// db = connect("localhost/cu-test")

// TIP: only specify a shortName here
var original = {
  shortName: 'insert-shortname-here'
}

// TIP: only specify fields that need to change
// Pick from: shortName displayName email accountLevel acceptedTerms datasetDisplay isStaff
var replacement = {
  shortName: 'insert-replacement-here',
  displayName: 'insert-replacement-here'
}

if(db.users.find({ shortName: original.shortName }).length() != 1){

  print('No user found with shortName "' + original.shortName + '"')

} else if('shortName' in replacement && db.users.find({ shortName: replacement.shortName }).length() > 0){

  print('User with shortName "' + replacement.shortName + '" already exists. Pick another replacement shortName.')

} else {

  print('Updating user ' + original.shortName + '...')

  // This updates basic user info
  db.users.update({
    shortName: original.shortName
  }, {
    $set: replacement
  })

  // This updates other relational references to
  // the user's shortName, if it has been changed
  if('shortName' in replacement && original.shortName != replacement.shortName){

    print('Updating canBeReally fields in related users...')

    db.users.update({
      canBeReally: original.shortName
    }, {
      $set: {
        "canBeReally.$": replacement.shortName
      }
    }, {
      multi: true
    })

    print('Updating defaultContext fields in related users...')

    db.users.update({
      defaultContext: original.shortName
    }, {
      $set: {
        defaultContext: replacement.shortName
      }
    }, {
      multi: true
    })

    print('Updating boxes owned by ' + original.shortName + '...')

    db.boxes.update({
      users: original.shortName
    }, {
      $set: {
        "users.$": replacement.shortName
      }
    }, {
      multi: true
    })

    print('Updating datasets in ' + original.shortName + ' data hub...')

    db.datasets.update({
      user: original.shortName
    }, {
      $set: {
        user: replacement.shortName,
      }
    }, {
      multi: true
    })

    print('Updating tools created by ' + original.shortName + '...')

    db.tools.update({
      user: original.shortName
    }, {
      $set: {
        user: replacement.shortName
      }
    }, {
      multi: true
    })

    print('Updating tools that ' + original.shortName + ' is able to install...')

    db.tools.update({
      allowedUsers: original.shortName
    }, {
      $set: {
        "allowedUsers.$": replacement.shortName
      }
    }, {
      multi: true
    })

    print('Updating password reset tokens for ' + original.shortName + '...')

    db.tokens.update({
      shortName: original.shortName
    }, {
      $set: {
        shortName: replacement.shortName
      }
    }, {
      multi: true
    })

    print('Removing existing sessions for ' + original.shortName + '...')

    db.sessions.remove({
      session: {
        $regex: '\\"shortName\\":\\"' + original.shortName + '\\"'
      }
    })

  }

  print('Updated.')

}
