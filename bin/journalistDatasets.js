// Give it an object, it'll return a list of lists
// ordered by the original object's keys
var sortObject = function(object){
  var sortable = []
  for(key in object){
    sortable.push([ key, object[key] ])
  }
  return sortable.sort(function(a, b){
    return a[1] - b[1]
  })
}

var pad = function(thing, length){
  return (String(thing) + Array(length+1).join(' ')).slice(0, length)
}

var frequency = []

print('How many datasets do "journalist" users have?')

var users = db.users.find({accountLevel: "journalist"}).sort({shortName: 1})

users.forEach(function(user){
  var datasets = db.datasets.find({
    user: user.shortName,
    state: {
      $ne: 'deleted'
    }
  })
  var n = datasets.length()
  if(n in frequency){
    frequency[n] = frequency[n] + 1
  } else {
    frequency[n] = 1
  }
})

print('+--------------+-------+------------+')
print('| Num datasets | Users | % of users |')
print('+--------------+-------+------------+')

var frequenciesSorted = sortObject(frequency)

for(key in frequenciesSorted){
  var f = frequency[key] || 0
  var pc = f / users.length()
  print('| ' + pad(key, 12) + ' | ' + pad(f, 5) + ' | ' + pad(pc, 10) + ' |')
}

print('+--------------+-------+------------+')


