const fs = require("fs");
const {patientNameList, diseaseList } = require("./config");

const jsonCreator = async () => {
  const list = [];

  for (let i = 1; i <= 100; i++) {
    const patientRandomNumber = Math.floor(Math.random() * patientNameList.length);
    const diseaseRandomNumber = Math.floor(Math.random() * diseaseList.length);
    const roomNumber = (i % 10) + 1;

    list.push({
      patient: patientNameList[patientRandomNumber],
      id: i,
      description: `${patientNameList[patientRandomNumber]} is in room number ${roomNumber} and is suffering from ${diseaseList[diseaseRandomNumber]}`,
      roomNumber,
      isDoctorAppointed: Math.random() < 0.75,
    });
  }

  fs.writeFileSync("./data.json", JSON.stringify(list), "utf-8");
  console.log("JSON file created");
};

module.exports = jsonCreator;
