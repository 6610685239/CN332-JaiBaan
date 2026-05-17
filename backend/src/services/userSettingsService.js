const prisma = require('../../db');

const updateUserSettings = async (userId, data) => {
    return await prisma.user.update({
        where: { id: userId },
        data,
    });
};

module.exports = {
    updateUserSettings,
};