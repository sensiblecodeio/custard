exports.datasetMaxSize = (name) ->
  if name == "grandfather"
    return 8000 # 8GB
  else if name == "free"
    return 8 # 8MB
  else
    console.warn "planSize: unknown plan", name
    return 8

