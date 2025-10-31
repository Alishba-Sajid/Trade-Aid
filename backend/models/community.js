// models/community.js
import { DataTypes, Model } from "sequelize";
import sequelize from "../config/db.js";

class Community extends Model {}

Community.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    name: { type: DataTypes.STRING, allowNull: false },
    description: { type: DataTypes.TEXT },
    location: {
      type: DataTypes.GEOMETRY("POINT", 4326),
      allowNull: false,
      field: 'geom' // maps JS attribute 'location' to DB column 'geom'
    },
  },
  {
    sequelize,
    modelName: "Community",
    tableName: "communities",
    timestamps: true,
  }
);

export default Community;
