fs = require 'fs'
which = require 'which'
{spawn, exec} = require 'child_process'

pkg = JSON.parse fs.readFileSync('./server/package.json')
testCmd = pkg.scripts.test
startCmd = pkg.scripts.start
 
log = (message, explanation) ->
  console.log "message #{explanation or ''}"

# Compiles app.coffee and src directory to the app directory
build = (callback) ->
  options = ['-c','-b', '-o', 'app', 'src']
  cmd = which.sync 'coffee'
  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  coffee.on 'exit', (status) -> callback?() if status is 0

# mocha test
test = (callback) ->
  options = [
    '--compilers'
    'coffee:coffee-script'
    '--colors'
    '--require'
    'should'
  ]
  try
    cmd = which.sync 'mocha'
    spec = spawn cmd, options
    spec.stdout.pipe process.stdout
    spec.stderr.pipe process.stderr
    spec.on 'exit', (status) -> callback?() if status is 0
  catch err
    log err.message
    log 'Mocha is not installed - try npm install mocha -g'

task 'build', ->
  build

task 'test', 'Run Mocha tests', ->
  build -> test

task 'dev', 'start dev env', ->
  # watch_coffee
  options = ['-c', '-b', '-w', '-o', 'server/js', 'server/code']
  cmd = which.sync 'coffee'
  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  log 'Watching coffee files'
  # watch_js
  supervisor = spawn 'node', ['./server/node_modules/supervisor/lib/cli-wrapper.js','-w','server/js','-w','server/template', '-e', 'js|html', 'server/server']
  supervisor.stdout.pipe process.stdout
  supervisor.stderr.pipe process.stderr
  log 'Watching js files and running server'

 
