#!/usr/bin/env node

var commander = require('commander'),
    Rsync = require('rsync'),
    fs = require('fs'),
    path = require('path'),
    conf_at = path.join(process.env.HOME, '.mirrorworksrc.json');

if (!fs.existsSync(conf_at)){
    console.log('No configuration file found at ' + conf_at + '.');
    process.exit(1);
}

var conf = JSON.parse(fs.readFileSync(conf_at)),
    pkg = JSON.parse(fs.readFileSync(path.join(__dirname, 'package.json'))),
    version = pkg.version,
    rsync_build = {
        flags: conf.rsync_flags
    };

function err(message) {
    console.log(message);
    process.exit(1);
}

function foreach(callback){
    var args = commander.args.slice(0,-1); // last arg is a command obj (why??)
    // use all reflections if no args were given
    if (args.length === 0)
        for (var i in conf.reflections)
            args.push(conf.reflections[i].name);
    for (var i=0; i<args.length; i++){
        var index = null;
        for (var j in conf.reflections){
            if (conf.reflections[j].name === args[i]) {
                index = j;
                break;
            }
        }
        if (index)
            callback(conf.reflections[index]);
        else
            err("No reflection '" + args[i] + "'");
    }
}

function push() {
    if (commander.hard) rsync_build.set = 'delete';
    foreach(function(reflection){
        var out = '>>>> Pushing ' + reflection.name + ' >>>>\n';
        rsync_build.source = reflection.local;
        rsync_build.destination = reflection.remote;
        Rsync.build(rsync_build).execute(
            function() {console.log(out);},
            function(stdout) {out += stdout;},
            function(stderr) {out += stderr;}
        );
    });
}

function pull() {
    if (commander.hard) rsync_build.set = 'delete';
    foreach(function(reflection){
        var out = '<<<< Pulling ' + reflection.name + ' <<<<\n';
        rsync_build.source = reflection.remote;
        rsync_build.destination = reflection.local;
        Rsync.build(rsync_build).execute(
            function() {console.log(out);},
            function(stdout) {out += stdout;},
            function(stderr) {out += stderr;}
        );
    });
}

function list() {
    console.log(conf.reflections);
}

function stat() {
    console.log('Starting dry run. No changes will be made.');
    rsync_build.flags += 'n';
    pull();
    push();
}

commander
    .version(version)
    .usage('[options...] <command> [reflections...]')
    .option('-x, --hard',  'pushing and pulling deletes extra files');
commander
    .command('push')
    .description('push from local to remote')
    .action(push);
commander
    .command('pull')
    .description('pull from remote to local')
    .action(pull);
commander
    .command('list')
    .description('list reflections')
    .action(list);
commander
    .command('status')
    .description('get status of reflections')
    .action(stat);
commander
    .on('--help', function(){
        console.log('  Reads json configuration file at ' + conf_at + '.');
        console.log('  All reflections will be used when none are specified.');
        console.log('  See the README.md for more information.');
    });
commander.parse(process.argv);
