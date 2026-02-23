// Karma configuration file, see link for more information
// https://karma-runner.github.io/1.0/config/configuration-file.html

module.exports = function (config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine', '@angular-devkit/build-angular'],
    plugins: [
      require('karma-jasmine'),
      require('karma-chrome-launcher'),
      require('karma-browserstack-launcher'),
      require('karma-jasmine-html-reporter'),
      require('karma-sonarqube-reporter'),
      require('karma-coverage'),
    ],
    client: {
      jasmine: {
        // you can add configuration options for Jasmine here
        // the possible options are listed at https://jasmine.github.io/api/edge/Configuration.html
        // for example, you can disable the random execution with `random: false`
        // or set a specific seed with `seed: 4321`
      },
      clearContext: false, // leave Jasmine Spec Runner output visible in browser
    },
    jasmineHtmlReporter: {
      suppressAll: true, // removes the duplicated traces
    },
    customLaunchers: {
      ChromiumHeadlessCI: {
        base: 'ChromiumHeadless',
        flags: ['--no-sandbox'],
      },
    },
    sonarqubeReporter: {
      basePath: require('path').join(__dirname, './src'),
      outputFolder: require('path').join(__dirname, './coverage/das_admin_tool'),
      reportName: (_metadata) => 'sonarqube.xml',
    },
    coverageReporter: {
      dir: require('path').join(__dirname, './coverage/das_admin_tool'),
      subdir: '.',
      reporters: [
        {type: 'html'},
        {type: 'text-summary'},
        {type: 'lcovonly'},
        {type: 'cobertura'},
      ],
    },
    reporters: ['progress', 'kjhtml'],
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: true,
    browsers: ['Chrome'],
    singleRun: false,
    restartOnFileChange: true,
  });
};
