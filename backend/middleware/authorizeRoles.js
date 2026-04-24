const authorizeRoles = (...allowedRoles) => {
    return (req, res, next) => {
        try {
            const user = req.user;

            if (!user) {
                return res.status(401).json({
                    success: false,
                    message: "Unauthorized. No user found."
                });
            }

            if (!allowedRoles.includes(user.role)) {
                return res.status(403).json({
                    success: false,
                    message: `Access denied for role: ${user.role}`
                });
            }

            next();

        } catch (error) {
            return res.status(500).json({
                success: false,
                message: "Role authorization failed",
                error: error.message
            });
        }
    };
};

module.exports = authorizeRoles;