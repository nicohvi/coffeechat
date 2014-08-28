(function() {
  module.exports = function(grunt) {
    grunt.initConfig({
      coffee: {
        app: {
          expand: true,
          src: ['**/*.coffee'],
          ext: '.js'
        }
      },
      watch: {
        app: {
          files: '**/*.coffee',
          tasks: ['coffee']
        }
      }
    });
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
    return grunt.registerTask('default', ['coffee']);
  };

}).call(this);
