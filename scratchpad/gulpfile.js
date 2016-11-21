const gulp = require('gulp')
const uglify = require('gulp-uglify')
const rename = require('gulp-rename')
const babel = require('gulp-babel')
const cleanCss = require('gulp-clean-css')
const del = require('del')

gulp.task('default', ['js', 'css'])

gulp.task('watch', ['js', 'css'], () => {
  gulp.watch('src/**/*.js', ['js'])
  gulp.watch('src/**/*.css', ['css'])
})

gulp.task('clean', ['clean:js','clean:css'])
gulp.task('clean:js', () => del('dist/**/*.js'))
gulp.task('clean:css', () => del('dist/**/*.css'))

gulp.task('js', ['clean:js'], () => {
  return gulp.src('src/**/*.js')
    .pipe(babel({ presets:['es2015'] }))
     // handle errors to prevent watch from stopping
    .on('error', function(err) { console.log(err); this.end(); })
    .pipe(uglify())
    .pipe(rename({ suffix:'.min' }))
    .pipe(gulp.dest('dist'))
})

gulp.task('css', ['clean:css'], () => {
  return gulp.src('src/**/*.css')
    .pipe(cleanCss())
    .pipe(rename({ suffix:'.min' }))
    .pipe(gulp.dest('dist'))
})
