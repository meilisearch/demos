const fs = require("fs");
const { userNameList, diseaseList } = require("./config");

const jsonCreator = async () => {
  const list = [];

  for (let i = 1; i <= 100; i++) {
    const userRandomNumber = Math.floor(Math.random() * userNameList.length);
    const diseaseRandomNumber = Math.floor(Math.random() * diseaseList.length);
    const roomNumber = (i % 10) + 1;

    list.push({
      user: userNameList[userRandomNumber],
      id: i,
      description: `${userNameList[userRandomNumber]} is in room number ${roomNumber} and is suffering from ${diseaseList[diseaseRandomNumber]}`,
      roomNumber,
      isDoctorAppointed: Math.random() < 0.75,
    });
  }

  fs.writeFileSync("./data.json", JSON.stringify(list), "utf-8");
  console.log("JSON file created");
};

module.exports = jsonCreator;
