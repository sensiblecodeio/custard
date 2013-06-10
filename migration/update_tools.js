// Run with mongo -u <x> -p <x> <connectionstring> <thisfile>
// Dataset names are tool names, so set the tool field to the name field
db.datasets.find().forEach(
  function (elem) {
    elem.tool = elem.name
    db.datasets.save(elem);
  }
)
