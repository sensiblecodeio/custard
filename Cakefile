fs = require 'fs'
which = require 'which'
{spawn, exec} = require 'child_process'

pkg = JSON.parse fs.readFileSync('./package.json')
testCmd = pkg.scripts.test
startCmd = pkg.scripts.start
 
log = (message, explanation) ->
  console.log "message #{explanation or ''}"

# Compiles app.coffee and src directory to the app directory
build = (callback) ->
  options = ['-c','-b', '-o', 'server/js', 'server/code']
  cmd = which.sync 'coffee'
  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  coffee.on 'exit', (status) -> callback?() if status is 0

task 'build', ->
  build

task 'test', 'Run unit tests', ->
  console.log process.argv[3..]
  build -> test process.argv[3..]

task 'dev', 'start dev env', ->
  # watch_coffee
  options = ['-c', '-b', '-w', '-o', 'server/js', 'server/code']
  cmd = which.sync 'coffee'
  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  log 'Watching coffee files'
  # watch_js
  supervisor = spawn 'node', ['./node_modules/supervisor/lib/cli-wrapper.js','-w','server/js','-w','server/template', '-e', 'js|html', 'server/server']
  supervisor.stdout.pipe process.stdout
  supervisor.stderr.pipe process.stderr
  log 'Watching js files and running server'

 
