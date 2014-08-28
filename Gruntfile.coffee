module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    coffee:
      app:
        expand: true
        src: ['public/*.coffee']
        ext: '.js'
    mochaTest:
      test:
        options:
          reporter: 'spec'
          require: ['coffee-script/register', 'should', 'util']
        src: ['test/*.coffee']
    watch:
      app:
        files: 'public/*.coffee'
        tasks: ['coffee']
      test:
        files: ['*.coffee', 'lib/*.coffee']
        tasks: ['mochaTest']

  # These plugins provide necessary tasks.
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-mocha-test'

  # Default task.
  grunt.registerTask 'default', ['coffee']
