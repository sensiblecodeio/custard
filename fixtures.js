// To use these, install the mongo fixtures utility
//    npm install pow-mongodb-fixtures -g
// and install mongodb locally, ensure it's runnning!
exports.users = [{
  shortName: 'test',
  email: ['test@example.org'],
  displayName: 'Test Testofferson',
  password: '$2a$10$EWqKC.kk2vYtmkW4fdCk7OxcnvZbd5SXwszHK6LQRlh59PYQK1hBm',
  apikey: 'test',
  isStaff: false,
  sshKeys: [],
  accountLevel: "free",
  canBeReally: ['test'],
  recurlyAccount: "test-2423432",
  acceptedTerms: 1,
},
{
  shortName: 'teststaff',
  email: ['teststaff@example.org'],
  displayName: 'General Test Testington',
  password: '$2a$10$CFjsDLWeS1x5BiX0mLulnOH97vop1KwUmzPnx5NvmZ1oda.LZNXNm',
  apikey: 'teststaff',
  isStaff: true,
  sshKeys: [],
  accountLevel: "free",
  recurlyAccount: "testsdfs-2423432",
  canBeReally: ['teststaff'],
  acceptedTerms: 1
},
{
  shortName: 'ehg',
  email: ['chris@scraperwiki.com'],
  displayName: 'Chris Blower',
  password: '$2a$10$EWqKC.kk2vYtmkW4fdCk7OxcnvZbd5SXwszHK6LQRlh59PYQK1hBm',
  apikey: process.env.COTEST_STAFF_API_KEY,
  isStaff: true,
  sshKeys: [],
  accountLevel: "grandfather-ec2",
  recurlyAccount: "ehg-2423432",
  acceptedTerms: 1,
  canBeReally: ['ehg', 'test'],
  defaultContext: "ehg",
  created: new Date(2012, 0, 1) // Wow! A zero-indexed month!
},
{
  shortName: 'free-trial-user',
  email: ['free-trail-user@scraperwiki.com'],
  displayName: 'Free Trialler',
  password: '$2a$10$EWqKC.kk2vYtmkW4fdCk7OxcnvZbd5SXwszHK6LQRlh59PYQK1hBm',
  apikey: "don't care",
  isStaff: false,
  sshKeys: [],
  accountLevel: "free-trial",
  // 14 * 86400 * 1000 is 14 days later.
  planExpires: new Date(+new Date() + 14 * 86400 * 1000),
  recurlyAccount: "ehg-2234432",
  acceptedTerms: 1,
  canBeReally: ['ehg', 'test'],
  defaultContext: "ehg",
  created: new Date()
},
{
  shortName: 'expired-user',
  email: ['expired-user@scraperwiki.com'],
  displayName: 'Expired Trialler',
  password: '$2a$10$EWqKC.kk2vYtmkW4fdCk7OxcnvZbd5SXwszHK6LQRlh59PYQK1hBm',
  apikey: "really don't care",
  isStaff: false,
  sshKeys: [],
  accountLevel: "free-trial",
  // 2 * 86400 * 1000 is 2 days ago
  planExpires: new Date(+new Date() - 2 * 86400 * 1000),
  recurlyAccount: String(Math.random()).replace('0.', ''), // new recurly account each time
  acceptedTerms: 1,
  canBeReally: ['ehg', 'test'],
  defaultContext: "ehg",
  created: new Date()
},
{
  shortName: 'ickletest',
  email: ['ickletest@example.org'],
  displayName: 'Ickle Test',
  password: '$2a$10$zGJXsNwhOBvze9GDm.jeEuLBX.TciRIKxNXfslxe5TZ.9/fDgpeDu',
  apikey: process.env.COTEST_USER_API_KEY,
  isStaff: false,
  sshKeys: ['a', 'b', 'c'],
  accountLevel: "free",
  recurlyAccount: "ickletest-242363",
  acceptedTerms: 1,
  canBeReally: ['ickletest', 'test', 'ehg'],
  defaultContext: "ickletest"
},
{
  shortName: 'nopassword',
  email: ['ickletest@example.org'],
  displayName: 'Ickle Test',
  apikey: 'nopassowrd',
  isStaff: false,
  sshKeys: ['a', 'b', 'c'],
  accountLevel: "free",
  recurlyAccount: "nopassword-242325",
  acceptedTerms: 1
},
{
  shortName: 'zarino',
  email: ['zarino@scraperwiki.com'],
  displayName: 'Zarino Testington',
  password: '$2a$10$EWqKC.kk2vYtmkW4fdCk7OxcnvZbd5SXwszHK6LQRlh59PYQK1hBm',
  apikey: 'zarino',
  sshKeys: ['d', 'e', 'f'],
  isStaff: false,
  accountLevel: "grandfather-ec2",
  recurlyAccount: "zarino-2423348",
  acceptedTerms: 1
},
{
  shortName: 'mrgreedy',
  email: ['omnomnom@example.com'],
  displayName: 'Mr F Greedy',
  password: '$2a$10$EWqKC.kk2vYtmkW4fdCk7OxcnvZbd5SXwszHK6LQRlh59PYQK1hBm',
  apikey: 'mrgreedy',
  sshKeys: [],
  isStaff: false,
  accountLevel: "free",
  recurlyAccount: "mrgreedy-1045756",
  acceptedTerms: 1
},
{
  shortName: 'mrlazy',
  email: ['test@example.com'],
  displayName: 'Longtime NoSee',
  password: '$2a$10$EWqKC.kk2vYtmkW4fdCk7OxcnvZbd5SXwszHK6LQRlh59PYQK1hBm',
  apikey: 'mrlazy',
  sshKeys: [],
  isStaff: false,
  accountLevel: "free",
  recurlyAccount: "mrlazy-2319852"
},
{
  shortName: 'testersonltd',
  email: ['testersonltd@example.com'],
  displayName: 'Testerson & Sons Ltd',
  password: '$2a$10$EWqKC.kk2vYtmkW4fdCk7OxcnvZbd5SXwszHK6LQRlh59PYQK1hBm',
  apikey: 'testsersonsdf',
  sshKeys: [],
  isStaff: false,
  accountLevel: "large-ec2",
  canBeReally: ['tinat'],
  recurlyAccount: "testersonltd-2319852"
},
{
  shortName: 'tinat',
  email: ['tina@example.com'],
  displayName: 'Tina Testerson NVQ',
  password: '$2a$10$EWqKC.kk2vYtmkW4fdCk7OxcnvZbd5SXwszHK6LQRlh59PYQK1hBm',
  apikey: 'tinat',
  sshKeys: [],
  isStaff: false,
  accountLevel: "free",
  recurlyAccount: "tinat-1045756",
  defaultContext: "testersonltd",
  acceptedTerms: 1
},
{
  shortName: 'mediummary',
  email: ['mary@example.com'],
  displayName: 'Medium Mary',
  password: '$2a$10$EWqKC.kk2vYtmkW4fdCk7OxcnvZbd5SXwszHK6LQRlh59PYQK1hBm',
  apikey: 'mediummary',
  sshKeys: [],
  isStaff: false,
  accountLevel: "medium-ec2",
  recurlyAccount: "mediummary-4837253",
  acceptedTerms: 1
},
{
  shortName: 'largelucy',
  email: ['lucy@example.com'],
  displayName: 'Large Lucy',
  password: '$2a$10$EWqKC.kk2vYtmkW4fdCk7OxcnvZbd5SXwszHK6LQRlh59PYQK1hBm',
  apikey: 'largelucy',
  sshKeys: [],
  isStaff: false,
  accountLevel: "large-ec2",
  recurlyAccount: "largelucy-583734",
  acceptedTerms: 1
},
{
  shortName: 'recentlyUpgraded',
  email: ['recentlyupgraded@example.com'],
  displayName: 'R. Upgraded',
  password: '$2a$10$EWqKC.kk2vYtmkW4fdCk7OxcnvZbd5SXwszHK6LQRlh59PYQK1hBm',
  apikey: 'recentlyUpgraded',
  sshKeys: [],
  isStaff: false,
  accountLevel: "medium-ec2",
  recurlyAccount: "recentlyUpgraded-937492",
  acceptedTerms: 1
}];

exports.tokens = [{
  token: '339231725782156',
  shortName: 'ickletest'
},
{
  token: '102937462019837',
  shortName: 'tinat'
}]

exports.tools = [{
  name: "newdataset",
  public: true,
  type: "importer",
  gitUrl: "https://github.com/scraperwiki/newdataset-tool.git",
  manifest: {
    description: "Create a new, empty dataset",
    displayName: "Code a dataset!",
    color: "#555",
    icon: "https://s3-eu-west-1.amazonaws.com/sw-icons/tool-icon-code.png"
  }
}, {
  name: "test-app",
  public: true,
  type: "importer",
  gitUrl: "https://github.com/scraperwiki/test-app-tool.git",
  manifest: {
    description: "Test app",
    displayName: "Test app",
    color: "#b0df18",
    icon: "https://s3-eu-west-1.amazonaws.com/sw-icons/tool-icon-test.png"
  }
}, {
  name: "test-plugin",
  public: true,
  type: "view",
  gitUrl: "https://github.com/scraperwiki/test-plugin-tool.git",
  manifest: {
    description: "Test plugin",
    displayName: "Test plugin",
    color: "#b0df18",
    icon: "https://s3-eu-west-1.amazonaws.com/sw-icons/tool-icon-test.png"
  }
}, {
  name: "test-push",
  public: true,
  type: "importer",
  gitUrl: "https://github.com/scraperwiki/test-push-tool.git",
  manifest: {
    description: "Test push",
    displayName: "Test push",
    color: "#b0df18",
    icon: "https://s3-eu-west-1.amazonaws.com/sw-icons/tool-icon-test.png"
  }
}, {
  name: "spreadsheet-download",
  public: true,
  type: "view",
  gitUrl: "https://github.com/scraperwiki/spreadsheet-download-tool",
  manifest: {
    description: "Download your dataset as an Excel file",
    displayName: "Download as spreadsheet",
    color: "#029745",
    icon: "https://s3-eu-west-1.amazonaws.com/sw-icons/tool-icon-spreadsheet-upload.png"
  }
}, {
  name: "newview",
  public: true,
  type: "view",
  gitUrl: "git://github.com/scraperwiki/newview-tool.git",
  manifest: {
    description: "Visualise or export your dataset however you'd like. A blank slate. Get creative!",
    displayName: "Code your own view!",
    color: "#555",
    icon: "https://s3-eu-west-1.amazonaws.com/sw-icons/tool-icon-code.png"
  }
}, {
  name: "view-source",
  public: true,
  type: "view",
  gitUrl: "git://github.com/scraperwiki/view-source-tool.git",
  manifest: {
    description: "Find out how to see the code that powers your dataset",
    displayName: "View source"
  }
}, {
  // TODO(frabcus): This tool is now archived, we should change it to datatables-view-tool
  name: "view-data",
  public: true,
  type: "view",
  gitUrl: "git://github.com/scraperwiki/spreadsheet-tool.git",
  manifest: {
    description: "See your data in a spreadsheet. Like it's 1990.",
    displayName: "View data"
  }
}, {
  name: "spreadsheet-upload",
  public: true,
  type: "importer",
  gitUrl: "git://github.com/scraperwiki/spreadsheet-upload-tool.git",
  manifest: {
    description: "Upload an Excel file or CSV",
    displayName: "Upload a spreadsheet",
    color: "#029745",
    icon: "https://s3-eu-west-1.amazonaws.com/sw-icons/tool-icon-spreadsheet-upload.png"
  }
}, {
  name: "free-plan-tool",
  public: false,
  allowedPlans: ["free"],
  type: "importer",
  gitUrl: "git://github.com/scraperwiki/spreadsheet-upload-tool.git",
  manifest: {
    description: "A tool only published for users on the free plan",
    displayName: "Special free user tool",
    color: "#5B8CC8"
  }
}, {
  name: "ickletests-private-tool",
  public: false,
  allowedUsers: ["ickletest"],
  type: "importer",
  gitUrl: "git://github.com/scraperwiki/spreadsheet-upload-tool.git",
  manifest: {
    description: "Mine. All mine.",
    displayName: "Ickletest's private tool",
    color: "#5BC88C"
  }
}, {
  name: "datatables-view-tool",
  public: true,
  type: "view",
  gitUrl: "https://github.com/scraperwiki/datatables-view-tool",
  manifest: {
    description: "Sort, search and page through your data.",
    displayName: "View in a table",
    color: "#f6b730",
    icon: "https://s3-eu-west-1.amazonaws.com/sw-icons/tool-icon-data-table.png"
  }
}, {
  name: "prune-graph",
  public: true,
  type: "view",
  gitUrl: "https://github.com/scraperwiki/prune-graph-tool.git",
  manifest: {
    description: "GRAPH OF THE PRUNES",
    displayName: "Code a prune!"
  }
}, {
  name: "private-tool",
  public: false,
  user: 'testersonltd',
  type: "view",
  gitUrl: "https://github.com/scraperwiki/doesnotexist.git",
  manifest: {
    description: "Super Secret",
    displayName: "Super Secret"
  }
}]

exports.datasets = [{
  "box": "drj",
  "tool": "just-testing-identd",
  "displayName": "drj",
  "user": "drj",
  "boxServer": "localhost",
  "views": []
}, {
  "box": "bfs",
  "tool": "just-testing-identd",
  "displayName": "bfs",
  "user": "bfs",
  "boxServer": "localhost",
  "views": []
}, {
  "box": "chris",
  "tool": "just-testing-identd",
  "displayName": "chris",
  "user": "chris",
  "boxServer": "localhost",
  "views": []
}, {
  "box": "3006375730",
  "tool": "test-app",
  "displayName": "Cheese",
  "user": "ickletest",
  "boxServer": "localhost",
  "views": [],
  "status": {
    "updated": "2014-01-10T07:20:00.000Z",
    "message": "There was no cheese",
    "type": "error"
  }
}, {
  "box": "3006375731",
  "tool": "test-app",
  "displayName": "Apricot",
  "createdDate": "2013-07-12T09:23:36.113Z",
  "user": "ehg",
  "creatorShortName": "ehg",
  "creatorDisplayName": "Chris Blower",
  "boxServer": "localhost",
  "boxJSON": {
    "publish_token": "6cd21c903b864fe",
    "database": "scraperwiki.sqlite"
  },
  "status": {
    "updated": "2014-01-10T07:20:00.000Z",
    "message": "Fully up to date",
    "type": "ok"
  },
  "views": [{
    "name": "downloader",
    "displayName": "Download a Spreadsheet",
    "box": "4001815731",
    "state": "state",
    "boxServer": "localhost",
    "tool": "spreadsheet-download"
  }]
}, {
  "box": "3006375815",
  "tool": "test-app",
  "displayName": "Prune",
  "createdDate": "2013-07-13T09:23:36.113Z",
  "user": "ehg",
  "creatorShortName": "ehg",
  "creatorDisplayName": "Chris Blower",
  "boxServer": "localhost",
  "views": [{
    "name": "prune-graph",
    "displayName": "Graph of Prunes",
    "box": "4008115731",
    "boxServer": "localhost",
    "state": "state",
    "tool": "prune-graph"
  }, {
    "name": "newview",
    "displayName": "Data Scientist's Report",
    "box": "4028374628",
    "boxServer": "localhost",
    "state": "state",
    "tool": "newview"
  }]
}, {
  "box": "4443057115",
  "tool": "test-app",
  "displayName": "Moldy Peach",
  "createdDate": "2013-07-11T09:23:36.113Z",
  "user": "ehg",
  "creatorShortName": "ehg",
  "creatorDisplayName": "Chris Blower",
  "boxServer": "localhost",
  "views": [],
  "state": "deleted",
  "toBeDeleted": "2013-07-16T12:20:16.000Z"
}, {
  "box": "3006375816",
  "boxServer": "localhost",
  "tool": "test-app",
  "displayName": "Kittens",
  "user": "zarino",
  "views": [{
    "name": "table1",
    "displayName": "View in a Table",
    "boxServer": "localhost",
    "box": "400857239",
    "state": "state",
    "tool": "test-plugin"
  }],
  "status": {
    "updated": "2013-03-12T08:23:00.000Z",
    "message": "Fully up to date",
    "type": "ok"
  }
}, {
  "box": "3006375818",
  "tool": "test-app",
  "displayName": "Puppies",
  "user": "zarino",
  "boxServer": "localhost",
  "views": [],
  "status": {
    "updated": "2013-03-12T07:20:00.000Z",
    "message": "Fully up to date",
    "type": "ok"
  }
}, {
  "box": "3006375819",
  "tool": "test-app",
  "displayName": "Piglets",
  "user": "zarino",
  "boxServer": "localhost",
  "views": [],
  "status": {
    "updated": "2013-01-10T10:23:00.000Z",
    "message": "No piglets detected",
    "type": "error"
  }
}, {
  "box": "3006375821",
  "tool": "test-app",
  "boxServer": "localhost",
  "displayName": "Chicks",
  "user": "zarino",
  "views": []
}, {
  "box": "3006375823",
  "tool": "test-app",
  "boxServer": "localhost",
  "displayName": "Bobcats",
  "user": "zarino",
  "views": []
}, {
  "box": "2416349265",
  "boxServer": "localhost",
  "tool": "spreadsheet-upload",
  "displayName": "My Spreadsheet",
  "user": "zarino",
  "views": []
}, {
  "box": "1057304856",
  "boxServer": "localhost",
  "tool": "test-app",
  "displayName": "Hamburger",
  "user": "mrgreedy",
  "views": []
}, {
  "box": "3046586739",
  "tool": "test-app",
  "boxServer": "localhost",
  "displayName": "Fries",
  "user": "mrgreedy",
  "views": []
}, {
  "box": "4057690375",
  "tool": "test-app",
  "boxServer": "localhost",
  "displayName": "Cola",
  "user": "mrgreedy",
  "views": []
}, {
  "box": "4057690376",
  "tool": "test-app",
  "boxServer": "localhost",
  "displayName": "Deleted and cleaned",
  "user": "mrgreedy",
  "views": [],
  "toBeDeleted": null,
  "state": "deleted"
}, {
  "box": "4057690377",
  "tool": "test-app",
  "boxServer": "localhost",
  "displayName": "Deleted not cleaned 1",
  "user": "mrgreedy",
  "views": [],
  "toBeDeleted": new Date(1978, 3, 16),
  "state": "deleted"
}, {
  "box": "4057690378",
  "tool": "test-app",
  "boxServer": "localhost",
  "displayName": "Deleted not cleaned 2",
  "user": "mrgreedy",
  "views": [],
  "toBeDeleted": new Date(1978, 3, 16),
  "state": "deleted"
}, {
  "box": "4057690379",
  "tool": "test-app",
  "boxServer": "localhost",
  "displayName": "Deleted in future",
  "user": "mrgreedy",
  "views": [],
  "toBeDeleted": new Date(3000, 3, 16),
  "state": "deleted"
}, {
  "box": "3006375746",
  "tool": "newdataset",
  "displayName": "Old Dataset",
  "createdDate": "2013-07-29T10:00:00.000Z",
  "user": "recentlyUpgraded",
  "creatorShortName": "recentlyUpgraded",
  "creatorDisplayName": "R. Upgraded",
  "boxServer": "free-server",
  "views": [{
    "name": "newview",
    "displayName": "New View",
    "box": "7462840283",
    "boxServer": "medium-server",
    "tool": "newview"
  }]
}]

exports.boxes = [{
  "users": ['ehg'],
  "name": "3006375731",
  "uid": 4678,
  "server": "localhost",
  "boxJSON": {
    "publish_token": "6cd21c903b864fe",
    "database": "scraperwiki.sqlite"
  }
}, {
  "users": ['ehg'],
  "name": "3006375815",
  "uid": 5678
}]
