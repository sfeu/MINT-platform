// My SocketStream 0.3 app

var http = require('http'),
    ss = require('socketstream');

// in app.js
///ss.session.store.use('redis');
ss.publish.transport.use('redis');  // any config can be passed to the second argument

// Define a single-page client called 'platform'
ss.client.define('platform', {
  view: 'platform.jade',
  css:  ['common/libs','platform/platform.styl'],
  code: ['common/libs','platform'],
  tmpl: ['platform']
});

// Define a single-page client called 'monitor'
ss.client.define('monitor', {
  view: 'monitor.jade',
  css:  ['common/libs', 'monitor/libs','monitor/monitor.styl'],
  code: ['common/libs', 'monitor'],
  tmpl: ['monitor']
});

// Serve this client on the root URL
ss.http.route('/', function(req, res){
  res.serveClient('platform');
});

// Serve this client on the monitor URL
ss.http.route('/monitor', function(req, res){
  res.serveClient('monitor');
});

// Code Formatters
ss.client.formatters.add(require('ss-coffee'));
ss.client.formatters.add(require('ss-jade'));
ss.client.formatters.add(require('ss-stylus'));

// Use server-side compiled Hogan (Mustache) templates. Others engines available
//ss.client.templateEngine.use(require('ss-hogan'));

// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env === 'production') ss.client.packAssets();

// Start web server
var server = http.Server(ss.http.middleware);
server.listen(3000);


// Start SocketStream
ss.start(server);