var gulp = require('gulp'),
    less = require('gulp-less'),
    replace = require('gulp-replace'),
    cssMin = require('gulp-minify-css'),
    outRoot = './web/resources/';

gulp.task('default', ['jq', 'bs:less', 'bs:fonts']);

gulp.task('jq', function() {
  return gulp.src('./node_modules/jquery/dist/*')
    .pipe(gulp.dest(outRoot + 'js'));
});

gulp.task('bs:less', function() {
  var customVars = __dirname + '/web/resources/less/variables.less',
      oldImport = '@import "variables.less";',
      newImport = '@import "' + customVars + '";';
  return gulp.src('./node_modules/bootstrap/less/bootstrap.less')
    .pipe(replace(oldImport, newImport))
    .pipe(less())
    .pipe(gulp.dest(outRoot + 'css'));
});

// TODO add this to default when node is updated
gulp.task('bs:min', ['bs:less'], function() {
  return gulp.src(outRoot + 'css/bootstrap.css')
    .pipe(cssMin)
    .pipe(gulp.dest(outRoot + 'css'));
});

gulp.task('bs:fonts', function() {
  return gulp.src('./node_modules/bootstrap/fonts/*')
    .pipe(gulp.dest(outRoot + 'fonts'));
});

