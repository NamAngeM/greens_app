module.exports = {
  port: process.env.PORT || 3000,
  ollamaUrl: process.env.OLLAMA_URL || 'http://localhost:11434',
  environment: process.env.NODE_ENV || 'development',
  logLevel: process.env.LOG_LEVEL || 'info',
}; 