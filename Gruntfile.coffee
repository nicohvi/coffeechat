module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    coffee:
      app:
        expand: true
        src: ['public/*.coffee']
        ext: '.js'
    watch:
      app:
        files: 'public/*.coffee'
        tasks: ['coffee']

  # These plugins provide necessary tasks.
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  # Default task.
  grunt.registerTask 'default', ['coffee']