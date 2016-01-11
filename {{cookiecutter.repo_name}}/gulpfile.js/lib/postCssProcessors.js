module.exports = [
  // Sassy based plugins
  require('postcss-import')({
    glob: true
  }),
  require('postcss-sassy-mixins'),
  require('postcss-advanced-variables'),
  require('postcss-custom-selectors'),
  require('postcss-custom-media'),
  require('postcss-custom-properties'),
  require('postcss-color-function'),
  require('postcss-nested'),
  require('postcss-atroot'),
  require('postcss-property-lookup'),
  require('postcss-selector-matches'),
  require('postcss-selector-not'),
  require('postcss-functions')({
    functions: {
      percentage: function(val1, val2) {
        var number = (val1 / val2) * 100

        return number.toFixed(2) + '%'
      }
    }
  }),
  require('postcss-map')({
    basePath: '{{cookiecutter.package_name}}/assets/css/config',
    maps: ['breakpoints.yaml', 'colors.yaml', 'fonts.yaml', 'grid.yaml', 'misc.yaml']
  }),
  require('postcss-calc'),

  // Niceties
  require('postcss-assets')({
    basePath: '{{cookiecutter.package_name}}/assets/',
    loadPaths: ['img/'],
    baseUrl: '/static/'
  }),
  require('postcss-brand-colors'),
  require('postcss-fakeid'),
  require('postcss-property-lookup'),
  require('postcss-pxtorem'),
  require('postcss-quantity-queries'),
  require('postcss-will-change'),
  require('autoprefixer')({
    browsers: ['> 1%', 'IE 9', 'IE 10', 'last 2 versions']
  }),
];
