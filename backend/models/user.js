"use strict";
const bcrypt = require("bcrypt");

module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define("User", {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: DataTypes.STRING,
    email: { type: DataTypes.STRING, unique: true, allowNull: false },
    password: { type: DataTypes.STRING, allowNull: false }
  }, {
    tableName: "users",
    timestamps: true,
    hooks: {
      beforeCreate: async (user) => {
        const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS || 10);
        user.password = await bcrypt.hash(user.password, saltRounds);
      },
      beforeUpdate: async (user) => {
        if (user.changed("password")) {
          const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS || 10);
          user.password = await bcrypt.hash(user.password, saltRounds);
        }
      }
    }
  });

  User.prototype.validPassword = function(password) {
    return bcrypt.compare(password, this.password);
  };

  User.associate = function(models) {
    // associations
  };

  return User;
};
