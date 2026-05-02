module.exports = [
  'strapi::logger',
  'strapi::errors',
  'strapi::security',
  'strapi::cors',
  'strapi::poweredBy',
  'strapi::query',
  {
    name: 'strapi::body',
    config: {
      formLimit: "256mb",    // Max size for form data
      jsonLimit: "256mb",    // Max size for JSON data
      textLimit: "256mb",
      formidable: {
        maxFileSize: 250 * 1024 * 1024, // 250mb individual file limit (in bytes)
      },
    },
  },
  'strapi::session',
  'strapi::favicon',
  'strapi::public',
  
];
