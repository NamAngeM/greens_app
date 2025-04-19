const errorHandler = (err, req, res, next) => {
  console.error(`Erreur: ${err.message}`);
  
  res.status(err.statusCode || 500).json({
    status: 'ERROR',
    message: err.message || 'Erreur serveur interne',
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
};

module.exports = errorHandler; 