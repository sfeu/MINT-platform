// My SocketStream 0.3 app

var http = require('http'),
    ss = require('socketstream');

// in app.js
ss.session.store.use('redis');
ss.publish.transport.use('redis');  // any config can be passed to the second argument

// Define a single-page client called 'main'
ss.client.define('main', {
  view: 'app.jade',
  css:  ['libs/reset.css', 'libs/demo_table.css','libs/demo_page.css','libs/jquery-ui.css','app.styl'],
  code: ['libs/jquery.min.js', 'libs/jquery.tmpl.min.js','libs/helpers.js','libs/jquery.dataTables.js','libs/jquery-ui-1.8.22.custom.min.js','app'],
  tmpl: '*'
});

// Serve this client on the root URL
ss.http.route('/', function(req, res){
  res.serveClient('main');
});

// Code Formatters
ss.client.formatters.add(require('ss-coffee'));
ss.client.formatters.add(require('ss-jade'));
ss.client.formatters.add(require('ss-stylus'));

// Use server-side compiled Hogan (Mustache) templates. Others engines available
ss.client.templateEngine.use(require('ss-hogan'));

// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env === 'production') ss.client.packAssets();

// Start web server
var server = http.Server(ss.http.middleware);
server.listen(3000);


// Start SocketStream
ss.start(server);