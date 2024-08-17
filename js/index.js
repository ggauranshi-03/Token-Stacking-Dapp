//FUNCTION CALL
loadInitialData("sevenDays");
connectMe("metamask_wallet");
function connectWallet() {}
function openTab(event, name) {
  console.log(name);
  contractCall = name;
  getSelectedTab(name);
  loadInitialData(name);
}
